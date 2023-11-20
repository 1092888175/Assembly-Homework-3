# 在Linux X86-64汇编中，系统调用由syscall指令调用
# 在%rax寄存器中存储系统调用编号
# 在%rdi，%rsi，%rdx寄存器分别存放移送给系统调用的第一、二、三个参数
# 系统调用的返回值存储在%rax寄存器中
# 在本次作业中使用到的系统调用表如下
#   %rax    System Call     %rdi            %rsi            %rdx
#   1       sys_write       unsigned int fd const char* buf size_t count
#   60      sys_exit        int error_code

# X86-64 Linux 中各寄存器的保存要求
# Caller Save：%rax %rcx %rdx %rsp %rsi %rdi %r8 %r9 %r10 %r11
# Callee Save：%rbx %rbp %r12 %r13 %r14 %r15

.data
msg:    .ascii "WHAT IS THE DATE"
len:    .quad len-msg


.text
.globl _start

_get_char:
    pushq %rbp
    movq %rsp,%rbp

    subq $8,%rsp

    movq $0,%rax
    movq $0,%rdi
    movq %rsp,%rsi
    movq $1,%rdx
    syscall
    movq (%rsp),%rax
    addq $8,%rsp

    popq %rbp
    ret

_print_char:
    pushq %rbp
    movq %rsp,%rbp

    pushq %rdi
    movq $1,%rax
    movq $1,%rdi
    movq %rsp,%rsi
    movq $1,%rdx
    syscall
    popq %rdi

    popq %rbp
    ret

# 声明一个打印字符串的函数，需要两个参数
_print_string:
	# 创建新栈，保存原栈
	pushq %rbp
	movq %rsp,%rbp
	# 将字符串的首地址和要打印的长度赋给参数2和参数3
	movq %rsi,%rdx
	movq %rdi,%rsi
	# 将调用号和文件描述符赋给%rax和参数1
	movq $1,%rax
	movq $1,%rdi
	syscall
	# 还原栈，返回	 
	popq %rbp
	ret

_get_num:
    pushq %rbp
    movq %rsp,%rbp

    subq $8,%rsp
    movq $0,(%rsp)
.GN0:
    call _get_char
    cmpq $48,%rax
    jl .GN0
    cmpq $57,%rax
    jg .GN0

.GN1:
    cmpq $48,%rax
    jl .GN2
    cmpq $57,%rax
    jg .GN2
    subq $48,%rax
    movq %rax,%rcx
    movq (%rsp),%rax
    imulq $10,%rax
    addq %rcx,%rax
    movq %rax,(%rsp)
    call _get_char
    jmp .GN1
.GN2:
    movq (%rsp),%rax
    addq $8,%rsp
.GNDone:
    popq %rbp
    ret
    
# 声明一个以十进制格式打印数字的函数，需要一个参数
_print_num:
	# 创建新栈，保存原栈
	pushq %rbp
	movq %rsp,%rbp

	movq %rdi,%rax	# 将要打印的数从参数1赋值给%rax
.PN1:
	# 不停将%rax除10，将余数转换成ascii压栈
	cmpq $0,%rax
	jle .PN2
	movq $0,%rdx
	movq $10,%rdi
	idivq %rdi
	addq $48,%rdx
	pushq %rdx
	jmp .PN1

.PN2:
	# 不停地输出栈中的元素，直到栈为空
	cmp %rsp,%rbp
	je .PNDone
    movq $1,%rax
	movq $1,%rdi
	movq %rsp,%rsi
	movq $1,%rdx
	syscall
	popq %rdx
	jmp .PN2

.PNDone:
	# 还原栈，返回	 
	popq %rbp
	ret
	
_start:
    leaq msg,%rdi
    movq len,%rsi
    call _print_string
    movq $10,%rdi
    call _print_char
    movq $7,%rdi
    call _print_char

    call _get_num
    pushq %rax
    call _get_num
    pushq %rax
    call _get_num
    pushq %rax

    movq (%rsp),%rdi
    call _print_num
    movq $45,%rdi
    call _print_char
    movq 16(%rsp),%rdi
    call _print_num
    movq $45,%rdi
    call _print_char
    movq 8(%rsp),%rdi
    call _print_num
    movq $10,%rdi
    call _print_char

.done:
    movq $60,%rax
    movq $0,%rdi
    syscall
