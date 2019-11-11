/* Copyright (C) 2007 Free Software Foundation, Inc.
 * See the copyright notice in the file /usr/LICENSE.
 * Created by flyan on 2019/11/9.
 * QQ: 1341662010
 * QQ-Group:909830414
 * gitee: https://gitee.com/flyanh/
 *
 * flyanx所需的常量定义
 *
 * 其他地方也有const.h头文件，而在这里的常量定义，都是在系统中一个以上的部分被用到的，
 * 其他的const.h一般是局部常量。
 *
 * 大量的定义来源于minix。
 */
#ifndef _FLYANX_CONST_H
#define _FLYANX_CONST_H

#ifndef CHIP
#error CHIP is not defined
#endif

/* EXTERN 被定义为extern，带上这个关键字，说明一个变量是全局的，并且该变量需要在头文件中声明 */
#define EXTERN        extern	/* used in *.h files */
/* PRIVATE是static的同义词，带上它的变量或函数将只在它所在当前文件中可见，所以可称为私有(PRIVATE) */
#define PRIVATE       static	/* PRIVATE x limits the scope of x */
/* 带上PUBLIC，将是公有，可以被其他文件所看到 */
#define PUBLIC					/* PUBLIC is the opposite of PRIVATE */
/* FORWARD，一些编译器要求它是静态static的 */
#define FORWARD       static	/* some compilers require this to be 'static' */

#define TRUE               1	/* 布尔值：真 */
#define FALSE              0	/* 布尔值：假*/

#define HZ	          	60		/* 时钟频率（可在IBM-PC上设置的软件） */
#define BLOCK_SIZE      1024	/* 磁盘块中的字节量 */
#define SUPER_USER      0	    /* 超级用户！ */

#define MAJOR	           8	/* 主设备 = (dev>>MAJOR) & 0377 */
#define MINOR	           0	/* 次设备 = (dev>>MINOR) & 0377 */

#define NULL     ((void *)0)	/* 空指针 */

/* 其他 */
#define BYTE            0377	/* 8位字节的掩码 */
#define READING            0	/* 复制数据给用户 */
#define WRITING            1	/* 从用户那复制数据 */
#define NO_NUM        0x8000	/* 用作panic()的数值参数 */
#define NIL_PTR   (char *) 0	/* 一般且有用的表达，空指针 */
#define HAVE_SCATTERED_IO  1	/* scattered I/O is now standard > 分散的I/O现在是标准配置 */

/* 功能宏 */
/**
 * 取两数最大最小值，用简单的宏来实现
 **/
#define MAX(a, b)   ((a) > (b) ? (a) : (b))
#define MIN(a, b)   ((a) < (b) ? (a) : (b))

/* 系统任务数量 @TODO 未确定 */
#define NR_TASKS    (0)

#endif //_FLYANX_CONST_H
