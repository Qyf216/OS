### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
#### 练习0：填写已有实验
本实验依赖实验1/2。请把你做的实验1/2的代码填入本实验中代码中有“LAB1”,“LAB2”的注释相应部分。

#### 练习1：理解基于FIFO的页面替换算法（思考题）
描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
 - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

答：
当程序访问不对应物理内存页帧的虚拟内存地址时，CPU抛出Page Fault异常，该异常在kern/trap/trap.c的exception_handler()函数里进行分发，分配给pgfault_handler进行处理，其又会调用kern/mm/vmm.c的do_pgfault()函数进行处理。
1.do_pgfault()函数首先会调用find_vma(mm, addr)函数，查看访问的地址是否合法。find_vma(mm, addr)函数的实现方法是在mm_struct结构体（当前进程对应的结构体）中寻找目标addr是否在其管辖的vma中，首先通过mm->mmap_cache访问最近一次访问过的vma，查看addr是否在其中，若不在，遍历vma链表（mmap_list）查找。
2.do_pgfault中，确认地址合法后，调用get_pte(mm->pgdir, addr, 1)函数，在进程的页表中为该地址查找页表项，若不存在该页表项，则创建一个，其传入的参数分别为进程的页表地址、缺页的地址（虚拟地址）、参数1表示没有则创建。
3.get_pte函数中，涉及到alloc_page()函数，用于分配一个物理页面，当需要创建不存在的页表项时，为其提供空间。在alloc_page()函数中，首先使用pmm_manager->alloc_pages(n)来尝试分配n个连续的物理页面（pmm_manager是页面管理器），若分配成功，则返回一个指向物理页面的指针page。若不成功，说明没有多余的物理页用来分配，此时使用swap_out函数换出页面。
4.get_pte函数中，获得物理页面后，会使用set_page_ref(page, 1)函数增加物理页的映射数量、uintptr_t pa = page2pa(page)将page转化为物理地址、memset(KADDR(pa), 0, PGSIZE)将物理地址的页帧初始化为0。
5.get_pte函数中，而后会调用pte_create(page2ppn(page), PTE_U | PTE_V)函数构建页表项，并最后返回一个页表项。
6.do_pgfault函数中，得到页表项后，先判断其是否为0，若为0，则说明该页没有被分配过，调用pgdir_alloc_page(mm->pgdir, addr, perm)函数分配。该函数的功能是为一个虚拟地址addr在页目录pgdir中分配一个物理页面，并设置相应的映射关系。
7.pgdir_alloc_page函数中，调用了alloc_page分配物理页面，而后调用了page_insert函数将新分配的页面插入页表中，建立虚拟地址到物理页面的映射关系。
8.page_insert函数中，调用了get_pte函数获得地址的页表项指针，检查页表项是否有效，若有效，检查是否映射的是当前物理页，若不是，则调用page_remove_pte函数释放原来映射的物理页，再调用pte_create映射当前物理页。
9.page_insert函数中，最后会调用tlb_invalidate(pgdir, la)函数，清空tlb，因为我们改变了页表。
10.pgdir_alloc_page函数中，而后会检查是否开启了页面换出机制，若开启，则调用swap_map_swappable(check_mm_struct, la, page, 0)函数将页面page标记为可换出的，并将其添加到换出算法的数据结构中，即mm_struct结构体中维护的pra_list_head链表。注意，swap_map_swappable函数实际上调用的是结构体struct swap_manager *sm（其中sm = &swap_manager_fifo）中的函数sm->map_swappable(mm, addr, page, swap_in)。
11.do_pgfault函数中，如果页表项不是0，则判断是否开启页面换出机制，若开启，则调用swap_in(mm, addr, &page)函数将指定地址addr的页面从交换分区中加载到内存中，并将加载到的页面存储在ptr_result中。
12.swap_in函数会调用alloc_page为result分配一个物理内存，并调用swapfs_read函数将页表项*ptep中记录的交换区索引对应的页面数据从磁盘读入到内存页面result。swapfs_read函数内部调用的是我们模拟的磁盘提供的接口函数ide_read_secs。
13.alloc_page中可能会调用swap_out函数换出页面，其中会调用swap_out_victim函数选择要换出的页面，其选择方法是fifo，即选择可换出页面链表的头部节点作为换出页面。而后，会调用swapfs_write将页面信息写入磁盘。由于改变了页表，使用tlb_invalidate清空快表。
14.do_pgfault函数中，最后会调用page_insert和swap_map_swappable完成页表更新与页面交换。



#### 练习2：深入理解不同分页模式的工作原理（思考题）
get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

1. get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

    - RISC-V 中 Sv32 使⽤了⼆级⻚表，Sv39 使⽤了三级⻚表，Sv48 使⽤四级⻚表。ucore实验中使⽤的是Sv39模式，⻚表被分为了：PDX1、PDX0和PTX。get_pte 中的两段相似的代码分别对应于在第三、第⼆级⻚表（PDX1，PDX0）的查找/创建过程。

    -  `get_pte` 函数的三个参数：页目录表的基地址 `pgdir`，需要映射的线性地址 `la`，以及一个布尔值 `create` 决定未找到时是否要分配新的页表项

    - ⾸先通过 `PDX1(la)` 宏计算线性地址 `la` 的第一级页目录索引并找到对应的页目录项，接着检查是否有效。若不可⽤则根据 create 的值决定是否调⽤ alloc_page() 分配新的页表页，若可⽤则继续寻找下⼀级⽬录。获取第二级页目录项` pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];`通过 `PDE_ADDR(*pdep1)` 获取第一级页目录项指向的页表的物理地址，然后计算线性地址 `la` 的第二级页目录索引，并获取对应的页目录项指针。接着检查是否有效。 最后返回最低一级页表项的内核虚拟地址`&((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];`

    - get_pte函数的⽬标是从虚拟地址找到pte的地址，所以⾸先 会使⽤pgdir（指向PDX1）找到PDX0的地址，然后再通过PDX0找到PTX的地址，由于⻚表的索引特性，这就导致了这两段代码的 结构⾮常相似。最后通过PTX(la)索引就得到了pte的地址。

2. 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

   - 将页表项的查找和分配合并在一个函数里的写法不太好，代码中未考虑分配失败的情况，如果分配失败可能会导致程序出现错误。将这两个功能拆开成两个函数进行实现。

   - **pte_lookup(mm, addr)**：

     - 这个函数将只负责查找给定地址的页表项。
     - 如果页表项存在，则返回其指针；如果不存在，则返回 `NULL`。
     - 这样做的好处是，调用者可以明确知道页表项是否已经存在，从而根据需要决定是否进行分配。

     **pte_alloc(mm, addr)**：

     - 这个函数专门负责分配新的页表项。
     - 如果分配成功，返回新分配的页表项的指针；如果失败，返回错误码。
     - 这种方式使得错误处理更加明确，调用者可以根据返回的错误码进行相应的错误处理。



#### 练习3：给未被映射的地址映射上物理页（需要编程）
补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

1. 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

   - 页表项的flags：

     - **存在位（P）**：页表项中的V位（Valid）表示页表项是否有效。如果一个页表项无效，那么指向的物理页不在内存中，必须先创建或从磁盘调入内存后才能使用。这对于页替换算法来说非常重要，因为它需要识别哪些页不在内存中，以便进行换入换出操作。
     - **读写标志（R/W）**：页目录项和页表项中的R/W位（Read/Write）表示页面是否可以被写入。这个标志对于页替换算法来说很重要，因为它可以防止写入那些不允许修改的页面，同时也可以用来确定页面是否被修改过（脏页）。
     - **用户/超级用户标志（U/S）**：U/S位（User/Supervisor）表示页面是否可以被用户模式访问。这个标志对于页替换算法来说有助于确定页面的访问权限，从而在进行页面换出时能够正确处理权限问题。
     - **访问位（A）**：A位（Accessed）由处理器设置，用来指示页表项所指向的页是否被访问过。这个位可以被操作系统用来监视页的使用频率，作为页替换算法中选择哪些页面换出的依据之一。
     - **脏位（D）**：D位（Dirty）由处理器设置，用来指示页表项所指向的页是否被写过数据。这个位对于页替换算法来说非常重要，因为它可以帮助识别哪些页面被修改过，从而在换出页面时将这些页面写回到磁盘。
     - **全局位（G）**：G位（Global）如果设置，表示页是全局的，它将在高速缓存中一直保存。这个位对于页替换算法来说有助于确定页面是否应该长期保留在内存中，避免不必要的换出。

     这些组成部分为ucore实现页替换算法提供了必要的信息和控制机制，使得操作系统能够有效地管理内存，优化页面的换入换出过程。通过合理利用这些标志位，ucore可以设计出高效且适应不同内存访问模式的页替换策略。

2. 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
   - 缺⻚异常是指CPU访问的虚拟地址时, MMU没有办法找到对应的物理地址映射关系，或者与该物理⻚的访问权不⼀致⽽发⽣的异常。
   - 在 kern_init 中初始化物理内存后调⽤ idt_init 初始化中断描述表，将寄存器 sscratch 赋值为0表⽰现在执⾏的是内核代码；将 异常向量地址 stvec 设置为 &__alltraps 并将 sstatus 设置为内核可访问⽤⼾内存。 出现⻚访问异常时，trapframe 结构体中的相关寄存器被修改，按照⼀般异常处理的流程（⻅lab1，中断⼊⼝点），产⽣异常的指 令地址会存⼊ sepc 寄存器，访问的地址存⼊ stval ，并且根据设置的 stvec 进⼊操作系统的异常处理过程。于是 kern/trap/trap.c 的 exception_handler() 被调⽤，根据 trapframe *tf->cause（也就是scause）的值 CAUSE_LOAD_PAGE_FAULT /CAUSE_STORE_PAGE_FAULT调⽤ pgfault_handler 进⾏进⼀步处理。这里的异常处理程序会把Page Fault分发给`kern/mm/vmm.c`的`do_pgfault()`函数并尝试进行页面置换。

3. 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

   sv39 分⻚机制下，每⼀个⻚表所占⽤的空间刚好为⼀个⻚的⼤⼩。在处理缺⻚时，如果⼀个虚拟地址对应的⼆级、三级⻚表项（⻚ ⽬录项）不存在，则会为其分配⼀个⻚，当第⼀级⻚表项没有设置过时也会分配⼀个⻚（主要体现在上⽂的 get_pte 中）。此 外，当⼀个⻚⾯被换出时，他所对应的⻚⾯会被释放，当⼀个⻚⾯被换⼊或者新建时，会分配⼀个⻚⾯。所以，对于本实验中缺⻚ 机制所处理和分配的所有⻚⽬录项、⻚表项，都对应于 pages 数组中的⼀个⻚，但是 pages 中的⻚并不⼀定会全部使⽤。

#### 练习4：补充完成Clock页替换算法（需要编程）
通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。
请在实验报告中简要说明你的设计实现过程。
实现过程主要补充三个函数，clock_init_mm、clock_map_swappable和clock_swap_out_victim，它们在fifo中也有对应的实现，其功能分别为初始化pra_list_head链表（用于索引该进程中所有可以替换的页面的链表）并将其作为mm私有成员指针的指向；将可交换的页面放入pra_list_head链表尾部，并将visited设为1，表示访问过该页面；选出要被替换出去的页面，通过curr指针遍历链表，若遇到访问过的页面（visited为1）则将其设为0，若遇到未访问的页面（visited为0），则选中其为要替换出去的页面，并将其从链表中删除。具体实现如下：
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: YOUR CODE*/ 
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾 
    list_add_before(&pra_list_head, entry);
    // 将页面的visited标志置为1，表示该页面已被访问
    page->visited = 1;
    return 0;
}
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
       struct Page *page = le2page(curr_ptr, pra_page_link);
        // 检查当前页面是否已被访问
        if (page->visited == 0) {
            // 如果未被访问，则选择该页面为需要换出的页面
            *ptr_page = page;
            // 从页面链表中删除
            cprintf("curr_ptr %p\n", curr_ptr);
            list_entry_t *temp=curr_ptr;
            list_del(curr_ptr);
            curr_ptr = list_next(temp);
            if (curr_ptr == head) {
                curr_ptr = list_next(curr_ptr);  // 防止死循环
            }
            return 0;
        } else {
            // 如果已被访问，则清除访问标记，并移动到下一个页面
            page->visited = 0;
            curr_ptr = list_next(curr_ptr);
            if (curr_ptr == head) {
                curr_ptr = list_next(curr_ptr);  // 防止死循环
            }
        }
    }
    return 0;
}

请回答如下问题：
 - 比较Clock页替换算法和FIFO算法的不同。
 答：二者的主要不同之处在于上述三个函数的实现，对于clock页替换算法，需要额外维护一个curr_ptr指针，用于每次选择页面的遍历，此外，还需要维护page结构体中的visited数值，用于记录页面上一轮的访问情况。在初始化函数中，将curr_ptr初始指向链表头部；在插入可交换页面函数中，需要同时检查curr_ptr是否为空，同时将刚刚插入的页面设置为已访问；在选择换出页面函数中，使用curr_ptr遍历链表，并选出第一个未被访问的也页面，并将其从链表中删除。对于fifo，只需维护一个可交换页面的链表，每次在尾部插入，头部删除即可，每次选择链表头的页面为换出页面，遵循先进先出原则。

#### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）
如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

#### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）
challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。



