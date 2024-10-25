#include <slub.h>
#include <list.h>
#include <defs.h>
#include <string.h>
#include <stdio.h>

struct slab_t
{
    int ref;
    struct kmem_cache_t *cachep;
    uint16_t inuse;
    int16_t free;
    list_entry_t slab_link;
};

#define SIZED_CACHE_NUM 8
#define SIZED_CACHE_MIN 16
#define SIZED_CACHE_MAX 2048

#define le2slab(le, link) ((struct slab_t *)le2page((struct Page *)le, link))
#define slab2kva(slab) (page2kva((struct Page *)slab))

static list_entry_t cache_chain;
static struct kmem_cache_t cache_cache;
static struct kmem_cache_t *sized_caches[SIZED_CACHE_NUM];
static char *cache_cache_name = "cache";
static char *sized_cache_name = "sized";

static void *
kmem_cache_grow(struct kmem_cache_t *cachep)
{
    struct Page *page = alloc_page();
    void *kva = page2kva(page);
    struct slab_t *slab = (struct slab_t *)page;
    slab->cachep = cachep;
    slab->inuse = slab->free = 0;
    int16_t *bufctl = kva;
    for (int i = 1; i < cachep->num; i++)
        bufctl[i - 1] = i;
    bufctl[cachep->num - 1] = -1;
    void *buf = bufctl + cachep->num;
    if (cachep->ctor)
        for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
            cachep->ctor(p, cachep, cachep->objsize);
    list_add(&(cachep->slabs_free), &(slab->slab_link));
    return slab;
}

static void
kmem_slab_destroy(struct kmem_cache_t *cachep, struct slab_t *slab)
{
    struct Page *page = (struct Page *)slab;
    int16_t *bufctl = page2kva(page);
    void *buf = bufctl + cachep->num;
    if (cachep->dtor)
        for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
            cachep->dtor(p, cachep, cachep->objsize);
    page->property = page->flags = 0;
    list_del(&(page->page_link));
    free_page(page);
}

static int
kmem_sized_index(size_t size)
{
    size_t rsize = ROUNDUP(size, 2);
    if (rsize < SIZED_CACHE_MIN)
        rsize = SIZED_CACHE_MIN;
    int index = 0;
    for (int t = rsize / 32; t; t /= 2)
        index++;
    return index;
}

#define TEST_OBJECT_LENTH 2046
#define TEST_OBJECT_CTVAL 0x22
#define TEST_OBJECT_DTVAL 0x11

static const char *test_object_name = "test";

struct test_object
{
    char test_member[TEST_OBJECT_LENTH];
};

static void
test_ctor(void *objp, struct kmem_cache_t *cachep, size_t size)
{
    char *p = objp;
    for (int i = 0; i < size; i++)
        p[i] = TEST_OBJECT_CTVAL;
}

static void
test_dtor(void *objp, struct kmem_cache_t *cachep, size_t size)
{
    char *p = objp;
    for (int i = 0; i < size; i++)
        p[i] = TEST_OBJECT_DTVAL;
}

static size_t
list_length(list_entry_t *listelm)
{
    size_t len = 0;
    list_entry_t *le = listelm;
    while ((le = list_next(le)) != listelm)
        len++;
    return len;
}

static void
check_kmem()
{

    assert(sizeof(struct Page) == sizeof(struct slab_t));

    size_t fp = nr_free_pages();

    struct kmem_cache_t *cp0 = kmem_cache_create(test_object_name, sizeof(struct test_object), test_ctor, test_dtor);
    assert(cp0 != NULL);
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0);

    struct test_object *p0, *p1, *p2, *p3, *p4, *p5;
    char *p;
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
    p = (char *)p4;
    for (int i = 0; i < sizeof(struct test_object); i++)
        assert(p[i] == TEST_OBJECT_CTVAL);
    assert((p5 = kmem_cache_zalloc(cp0)) != NULL);
    p = (char *)p5;
    for (int i = 0; i < sizeof(struct test_object); i++)
        assert(p[i] == 0);
    assert(nr_free_pages() + 3 == fp);
    assert(list_empty(&(cp0->slabs_free)));
    assert(list_empty(&(cp0->slabs_partial)));
    assert(list_length(&(cp0->slabs_full)) == 3);
    kmem_cache_free(cp0, p3);
    kmem_cache_free(cp0, p4);
    kmem_cache_free(cp0, p5);
    assert(list_length(&(cp0->slabs_free)) == 1);
    assert(list_length(&(cp0->slabs_partial)) == 1);
    assert(list_length(&(cp0->slabs_full)) == 1);
    assert(kmem_cache_shrink(cp0) == 1);
    assert(nr_free_pages() + 2 == fp);
    assert(list_empty(&(cp0->slabs_free)));
    p = (char *)p4;
    for (int i = 0; i < sizeof(struct test_object); i++)
        assert(p[i] == TEST_OBJECT_DTVAL);
    kmem_cache_free(cp0, p0);
    kmem_cache_free(cp0, p1);
    kmem_cache_free(cp0, p2);
    assert(kmem_cache_reap() == 2);
    assert(nr_free_pages() == fp);
    kmem_cache_destroy(cp0);

    assert((p0 = kmalloc(2048)) != NULL);
    assert(nr_free_pages() + 1 == fp);
    kfree(p0);
    assert(kmem_cache_reap() == 1);
    assert(nr_free_pages() == fp);

    cprintf("check_kmem() succeeded!\n");
}

struct kmem_cache_t *
kmem_cache_create(const char *name, size_t size,
                  void (*ctor)(void *, struct kmem_cache_t *, size_t),
                  void (*dtor)(void *, struct kmem_cache_t *, size_t))
{
    assert(size <= (PGSIZE - 2));
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
    if (cachep != NULL)
    {
        cachep->objsize = size;
        cachep->num = PGSIZE / (sizeof(int16_t) + size);
        cachep->ctor = ctor;
        cachep->dtor = dtor;
        memcpy(cachep->name, name, CACHE_NAMELEN);
        list_init(&(cachep->slabs_full));
        list_init(&(cachep->slabs_partial));
        list_init(&(cachep->slabs_free));
    }
    return cachep;
}

