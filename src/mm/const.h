/* Copyright (C) 2007 Free Software Foundation, Inc. 
 * See the copyright notice in the file /usr/LICENSE.
 * Created by flyan on 2019/11/30.
 * QQ: 1341662010
 * QQ-Group:909830414
 * gitee: https://gitee.com/flyanh/
 *
 * 内存管理器所需要的常量
 */
#ifndef _MM_CONST_H
#define _MM_CONST_H

#define printf  printl  /* printf用的是低等级打印printl */

/* 所有派生（fork）的进程将使用PROCS_BASE之上的内存
 *
 * 注意：请确保PROCS_BASE的值高于任何缓冲区，例如文件系统缓冲区，
 * 内存管理器缓冲区等等。
 * 现在它们缓冲区的长度为：0xB00000(11MB)
 */
#define FREE_BASE                   0xB00000            /* 可以安全使用的内存空间物理地址：11M */
#define PROCS_BASE_CLICK            (FREE_BASE >> CLICK_SHIFT)
#define KERNEL_BASE                 0x1000              /* 内核挂载点（基址） */

/* 由alloc_mem()函数返回，用于告诉调用者，内存不足，无法完成分配。 */
#define NO_MEM  ((phys_clicks) 0)

/* 起源进程的进程号 */
#define ORIGIN_PID      0

#endif //_MM_CONST_H
