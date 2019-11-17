;================================================================================================
; 文件：kernel_386_lib.asm
; 作用：Flyanx系统内核内核库文件
; 作者： Flyan
; 联系QQ： 1341662010
;================================================================================================
; 导入和导出

; 导入头文件
%include "asmconst.inc"

; 导入变量
extern  display_position    ; 显示位置（不同于光标哦）
extern  level0_func         ; 导入提权函数

;================================================================================================
; 库函数开始
[SECTION .lib]

; 导出库函数
global  copy_msg
global  phys_copy
global  disp_str
global  disp_color_str
global  out_byte
global  in_byte
global  out_word
global  in_word
global  enable_irq
global  disable_irq
global  interrupt_lock
global  interrupt_unlock
global  level0

;*===========================================================================*
;*				copy_msg					     *
;*              复制消息
;*===========================================================================*
;* 本例程来源于MINIX
;* 尽管用phys_copy就可以完成消息的拷贝（在下面），然而这是一个更快的专门过程
;* copy_msg被用作消息拷贝的目的
;* 函数原型：copy_msg (int src,phys_clicks src_clicks,vir_bytes src_offset,
;*                 		phys_clicks dst_clicks, vir_bytes dst_offset );
;* 各参数意义：
;* source: 发送者的进程号，它将被拷贝到接收者缓冲区的m_source域
;* src_clicks: 源数据的段基地址
;* dst_clicks: 目的地的段基址
;* src_offset: 源数据的偏移
;* dst_offset: 目的地的偏移
;* 使用块和偏移指定源和目标的方式比phys_copy所用的32位物理地址更加的高效。

CM_ARGS equ 4 + 4 + 4 + 4 + 4     ; 用于到达复制的参数堆栈的栈顶
align 16        ; 对齐16位，下面的每个例程都有
copy_msg:
    cld
    push esi
    push edi
    push ds
    push es

    mov eax, SELECTOR_KERNEL_DS
    mov ds, ax
    mov es, ax

    mov esi, [esp + CM_ARGS + 4]        ; 源数据块
    shl esi, CLICK_SHIFT
    add esi, [esp + CM_ARGS + 4 + 4]          ; 源数据偏移
    mov edi, [esp + CM_ARGS + 4 + 4 + 4]      ; 目的地块
    shl edi, CLICK_SHIFT
    add edi, [esp + CM_ARGS + 4 + 4 + 4 + 4]    ; 目的地偏移

    mov eax, [esp + CM_ARGS]        ; 发送者的进程槽号
    stos                            ; 将发送者的进程槽号复制到目标消息
    add esi, 4                      ; 不要复制第一个字
    mov ecx, MSG_SIZE - 1           ; 记住，第一个字不算进去
    rep
    movsw                            ; 复制消息

    pop es
    pop ds
    pop edi
    pop esi
    ret                             ; 就这些了！
;*===========================================================================*
;*				phys_copy				     *
;*===========================================================================*
;* 本例程来源于MINIX
; PUBLIC void phys_copy(phys_bytes source, phys_bytes destination,
;			phys_bytes bytecount);
;* 将物理内存中任意处的一个数据块拷贝到任意的另外一处 *
;* 函数调用原型：phys_copy(source_address, destination_address, bytes) *
;* 参数中的两个地址都是绝对地址，也就是地址0确实表示整个地址空间的第一个字节， *
;* 并且三个参数均为无符号长整数 *
PC_ARGS     equ     4 + 4 + 4 + 4   ; 用于到达复制的参数堆栈的栈顶
align 16
phys_copy:
    cld
    push esi
    push edi
    push es

    mov eax, SELECTOR_KERNEL_DS
    mov es, ax

    ; 获得所有参数
    mov esi, [esp + PC_ARGS]
    mov edi, [esp + PC_ARGS + 4]
    mov eax, [esp + PC_ARGS + 4 + 4]

    cmp eax, 10         ; 避免小的数导致的对齐开销
    jb phys_cp_small
    mov ecx, esi        ; 对齐源数据，希望目标也一样
    neg ecx
    and ecx, 3          ; 计数对齐
    sub eax, eax
    rep
    movsb
    mov ecx, eax
    shr ecx, 2          ; 双字计数
    rep
    movsd
    and eax, 3
phys_cp_small:
    xchg ecx, eax    ; 余
    rep
    movsb

    pop es
    pop edi
    pop esi
    ret
;================================================================================================
;                  void disp_str(char * info);	显示一个黑底白字的字符串
align 16
disp_str:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8]          ; 得到字符串信息
    mov edi, [display_position]  ; 得到显示位置
    mov ah, 0Fh                 ; 设置显示属性：黑底白字
.1:
    lodsb
    test al, al
    jz  .2
    cmp al, 0Ah     ; 回车？
    jnz .3
    push eax
    mov eax, edi
    mov bl, 160
    div bl
    and eax, 0FFh
    inc eax
    mov bl, 160
    mul bl
    mov edi, eax
    pop eax
    jmp .1
.3:
    mov [gs:edi], ax    ; 将显示文字放到显存中
    add edi, 2
    jmp .1
.2:
    mov [display_position], edi  ; 更新显示位置

    pop ebp
    ret

;================================================================================================
;                  void disp_color_str(char * string, int color);	显示有颜色属性的字符串
align 16
disp_color_str:
    push	ebp
	mov	ebp, esp

	mov	esi, [ebp + 8]	; pszInfo
	mov	edi, [display_position]
	mov	ah, [ebp + 12]	; color
.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

.2:
	mov	[display_position], edi

	pop	ebp
	ret
;================================================================================================
;                  void out_byte(port_t port, U8_t value) ;	向端口输出数据
align 16
out_byte:
    mov	edx, [esp + 4]		; port
	mov	al, [esp + 4 + 4]	; value
	out	dx, al
	nop	; 一点延迟
	nop
	ret

;================================================================================================
;                  PUBLIC U8_t in_byte(port_t port);	从端口拿取数据
align 16
in_byte:
    mov	edx, [esp + 4]		; port
	xor	eax, eax
	in	al, dx
	nop	; 一点延迟
	nop
	ret

;*===========================================================================*
;*				out_word				     *
;*===========================================================================*
;* PUBLIC void out_word(Port_t port, U16_t value);
;* 写一个字到某个i/o端口上 *
align 16
out_word:
    mov edx, [esp + 4]      ; 得到端口
    mov eax, [esp + 4 + 4]  ; 得到值
    out dx, ax              ; 输出一个字
    ret

;*===========================================================================*
;*				in_word					     *
;*===========================================================================*
; PUBLIC U16_t in_word(port_t port);
;* 读一个字从某个i/o端口并返回它 *
align 16
in_word:
    mov edx, [esp + 4]      ; 端口
    xor eax, eax
    in ax, dx               ; 读一个字
    ret

;================================================================================================
;                  void disable_irq(int intRequest);	关闭一个特定的中断
align 16
disable_irq:
    mov ecx, [esp + 4]		; get param --> intRequest
	pushf
	cli
	mov ah, 1
	rol ah, cl				; ah = (1 << (intRequest % 8))
	cmp cl, 8
	jae disable_8			; disable intRequest >= 8 at the slave 8259
disable_0:
	in al, INT_M_CTLMASK
	test al, ah
	jnz dis_already			; already disabled?
	or al, ah
	out INT_M_CTLMASK, al	; set bit at master 8259
	popf
	mov eax, 1				; disabled by this function
	ret
disable_8:
	in al, INT_S_CTLMASK
	test al, ah
	jnz dis_already			; already disabled?
	or al, ah
	out INT_S_CTLMASK, al	; set bit at slave 8259
	popf
	mov eax, 1				; disable by this function
	ret
dis_already:
	popf
	xor eax, eax			; already disabled
	ret

;================================================================================================
;                  void enable_irq(int intRequest);	启用一个特定的中断
align 16
enable_irq:
    mov ecx, [esp + 4]		; get intRequest
	pushf
	cli
	mov ah, ~1
	rol ah, cl				; ah = ~(1 << (intRequest % 8))
	cmp cl, 8
	jae enable_8			; enable intRequest >= 8 at the slave 8259
enable_0:
	in al, INT_M_CTLMASK
	and al, ah
	out INT_M_CTLMASK, al	; clear bit at master 8259
	popf
	ret
enable_8:
	in al, INT_S_CTLMASK
	and al, ah
	out INT_S_CTLMASK, al	; clear bit at slave 8259
	popf
	ret

;================================================================================================
;                  interrupt_lock	锁中断
align 16
interrupt_lock:
    cli
	ret

;================================================================================================
;                  interrupt_unlock	解锁中断
align 16
interrupt_unlock:
    sti
    ret

;================================================================================================
;                  void level0(void (*func)(void))	解锁中断
; 将任务提权到最高特权级 - 0级
; 它主要用于这样的操作，如复位CPU、或访问PC的ROM BIOS例程。
align 16
level0:
    mov eax, [esp + 4]
    mov [level0_func], eax
    int LEVEL0_VECTOR
    ret

;================================================================================================

