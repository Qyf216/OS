#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static size_t total_size;          // 总的物理页面数量n
static size_t full_tree_size;      // 根据 n 的值计算完全二叉树的大小，根节点的大小，确保是2的幂次
static size_t record_area_size;    // 储存树节点信息所需的页数
static size_t real_tree_size;      // 实际可用于构建伙伴系统完全二叉树的页面数量,考虑了记录区域所占用的空间
static size_t *record_area;        // 指向记录二叉树的状态信息区域的指针，length[]
static struct Page *physical_area; // 物理内存区域的指针
static struct Page *allocate_area; // 用于分配的内存区域的指针

#define TREE_ROOT (1)
#define LEFT_CHILD(a) ((a) << 1)
#define RIGHT_CHILD(a) (((a) << 1) + 1)
#define PARENT(a) ((a) >> 1)
#define NODE_LENGTH(a) (full_tree_size / POWER_ROUND_DOWN(a)) //节点的size
#define NODE_BEGINNING(a) (POWER_REMAINDER(a) * NODE_LENGTH(a))              // 实际在内存的索引开始
#define NODE_ENDDING(a) ((POWER_REMAINDER(a) + 1) * NODE_LENGTH(a))          // 
#define BUDDY_BLOCK(a, b) (full_tree_size / ((b) - (a)) + (a) / ((b) - (a)))  // 根据在实际内存中的索引计算节点序号
#define BUDDY_EMPTY(a) (record_area[(a)] == NODE_LENGTH(a)) //还没被分配

#define OR_SHIFT_RIGHT(a, n) ((a) | ((a) >> (n)))
#define ALL_BIT_TO_ONE(a) (OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(a, 1), 2), 4), 8), 16))
#define POWER_REMAINDER(a) ((a) & (ALL_BIT_TO_ONE(a) >> 1)) //2的幂返回0，不是则保留 a 中不是2的幂的那些位
#define POWER_ROUND_UP(a) (POWER_REMAINDER(a) ? (((a)-POWER_REMAINDER(a)) << 1) : (a))
#define POWER_ROUND_DOWN(a) (POWER_REMAINDER(a) ? ((a)-POWER_REMAINDER(a)) : (a))


/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
//物理地址转成虚拟地址
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })



static void 
buddy_init(void){
    list_init(&free_list);
    nr_free = 0;
}


static void 
buddy_init_memmap(struct Page *base, size_t n){
    assert(n > 0);
    struct Page *p;
    for (p = base; p < base + n; p++)
    {
        assert(PageReserved(p));
        p->flags = p->property = 0;
    }

    total_size = n;
    if (n < 512)
    {
        full_tree_size = POWER_ROUND_UP(n - 1);
        record_area_size = 1;
    }
    else
    {
        full_tree_size = POWER_ROUND_DOWN(n);
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
        if (n > full_tree_size + (record_area_size << 1))
        {
            full_tree_size <<= 1;
            record_area_size <<= 1;
        }
    }
    //计算实际可用于构建伙伴系统完全二叉树的页面数量,考虑记录区域所占用的空间
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;

    physical_area = base;
    record_area = KADDR(page2pa(base));//KADDR 用于将物理地址转换为虚拟地址
    allocate_area = base + record_area_size;
    memset(record_area, 0, record_area_size * PGSIZE);

    nr_free += real_tree_size;//全局空闲页面
    size_t block = TREE_ROOT;//当前节点
    size_t real_subtree_size = real_tree_size;//真实大小,就是这个节点所能分配的内存
    size_t full_subtree_size = full_tree_size;//size,
    record_area[block] = real_subtree_size;//length[index]=真实大小

    //将实际可用的页面数量分配到树的节点中,从根节点开始到所有页面都被分完或达到树的叶子节点
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size)
    {
        full_subtree_size >>= 1;
        if (real_subtree_size > full_subtree_size)
        {
            struct Page *page = &allocate_area[NODE_BEGINNING(block)];
            page->property = full_subtree_size;
            list_add(&(free_list), &(page->page_link));
            set_page_ref(page, 0);
            SetPageProperty(page);
            record_area[LEFT_CHILD(block)] = full_subtree_size;
            real_subtree_size -= full_subtree_size;
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
            block = RIGHT_CHILD(block);
        }
        else
        {
            record_area[LEFT_CHILD(block)] = real_subtree_size;
            record_area[RIGHT_CHILD(block)] = 0;
            block = LEFT_CHILD(block);
        }
    }
    //构建完全二叉树后剩余的页面
    if (real_subtree_size > 0)
    {
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
        page->property = real_subtree_size;
        set_page_ref(page, 0);
        SetPageProperty(page);
        list_add(&(free_list), &(page->page_link));
    }
}


static struct Page *buddy_allocate_pages(size_t n)
{
    assert(n > 0);
    struct Page *page;
    size_t block = TREE_ROOT;
    size_t length = POWER_ROUND_UP(n);//需要分配的页面数量

    //循环直到找到大小合适的块,结束条件length = record_area[block] && length = NODE_LENGTH(block)
    while (length <= record_area[block] && length < NODE_LENGTH(block))
    {
        size_t left = LEFT_CHILD(block);
        size_t right = RIGHT_CHILD(block);
        if (BUDDY_EMPTY(block))//该块是空闲的，将其分裂成两个子块
        {
            size_t begin = NODE_BEGINNING(block);
            size_t end = NODE_ENDDING(block);
            size_t mid = (begin + end) >> 1;
            list_del(&(allocate_area[begin].page_link));
            allocate_area[begin].property >>= 1;
            allocate_area[mid].property = allocate_area[begin].property;
            record_area[left] = record_area[block] >> 1;
            record_area[right] = record_area[block] >> 1;
            list_add(&free_list, &(allocate_area[begin].page_link));
            list_add(&free_list, &(allocate_area[mid].page_link));
            block = left;
        }//如果当前块不为空，根据请求的大小选择左子块或右子块
        else if (length & record_area[left])//因为都是2的幂，结果非0表示大小满足
            block = left;
        else if (length & record_area[right])
            block = right;
        else if (length <= record_area[left])
            block = left;
        else if (length <= record_area[right])
            block = right;
    }
    if (length > record_area[block])
        return NULL;

    page = &(allocate_area[NODE_BEGINNING(block)]);
    list_del(&(page->page_link));
    record_area[block] = 0;
    nr_free -= length; 

    //回溯，调整父节点length
    while (block != TREE_ROOT)
    {
        block = PARENT(block);
        record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
    }
    return page;
}



static void 
buddy_free_pages(struct Page *base, size_t n){
    assert(n > 0);
    struct Page *p = base;
    size_t length = POWER_ROUND_UP(n);
    size_t begin = (base - allocate_area);
    size_t end = begin + length;
    size_t block = BUDDY_BLOCK(begin, end);//要释放的内存所在的树节点索引

    for (; p != base + n; p++)
    {
        assert(!PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }

    base->property = length;
    list_add(&free_list, &(base->page_link));
    nr_free += length;

    record_area[block] = length;

    //合并伙伴块
    while (block != TREE_ROOT)
    {
        block = PARENT(block);
        size_t left = LEFT_CHILD(block);
        size_t right = RIGHT_CHILD(block);

        //对于每个父节点，检查其左右子节点是否都为空。
        //如果都为空，则将这两个块合并为一个更大的块
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right))
        {
            size_t lbegin = NODE_BEGINNING(left);
            size_t rbegin = NODE_BEGINNING(right);
            list_del(&(allocate_area[lbegin].page_link));
            list_del(&(allocate_area[rbegin].page_link));
            record_area[block] = record_area[left] << 1;
            allocate_area[lbegin].property = record_area[left] << 1;
            list_add(&free_list, &(allocate_area[lbegin].page_link));
        }
        else//如果不是都为空，则更新父节点的记录区域，反映左右子节点的空闲块大小
            record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
    }
}


static size_t
buddy_nr_free_pages(void)
{
    return nr_free;
}

//验证buddy system内存管理的分配和释放操作是否正确
static void 
alloc_check(void){
    size_t total_size_store = total_size;
    struct Page *p;
    for (p = physical_area; p < physical_area + 1026; p++)
        SetPageReserved(p);
    buddy_init();
    buddy_init_memmap(physical_area, 1026);//预留1026个物理页面,初始化

    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = NULL;
    //分配四页内存，并验证它们是连续的
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    assert((p3 = alloc_page()) != NULL);
    assert(p0 + 1 == p1);
    assert(p1 + 1 == p2);
    assert(p2 + 1 == p3);
    //验证分配的页面引用计数为0
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0 && page_ref(p3) == 0);
    //验证分配的页面物理地址有效
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);
    assert(page2pa(p3) < npage * PGSIZE);
    //遍历空闲列表，验证分配是否成功
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
    {
        p = le2page(le, page_link);
        assert(buddy_allocate_pages(p->property) != NULL);
    }
    //尝试再次分配一页内存，并断言由于内存耗尽而分配失败
    assert(alloc_page() == NULL);
    //释放之前分配的页面，并检查空闲页面计数 nr_free 是否正确
    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);
    //再次分配一页和两页内存，并断言分配的页面是连续的
    assert((p1 = alloc_page()) != NULL);
    assert((p0 = alloc_pages(2)) != NULL);
    assert(p0 + 2 == p1);
    //尝试再次分配一页内存，并断言由于内存耗尽而分配失败
    assert(alloc_page() == NULL);
    free_pages(p0, 2);
    free_page(p1);
    free_page(p3);
    //分配四页内存，并断言分配的页面是之前释放的页面
    assert((p = alloc_pages(4)) == p0);
    //尝试再次分配一页内存，并断言由于内存耗尽而分配失败。同时断言当前的空闲页面计数为 0
    assert(alloc_page() == NULL);
    assert(nr_free == 0);
    for (p = physical_area; p < physical_area + total_size_store; p++)
        SetPageReserved(p);
    buddy_init();
    buddy_init_memmap(physical_area, total_size_store);
}


const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_allocate_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = alloc_check,
};