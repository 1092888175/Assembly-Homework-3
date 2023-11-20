.data
DATA: 
    .ascii "1975","1976","1977","1978","1979","1980","1981"
    .ascii "1982","1983","1984","1985","1986","1987","1988"
    .ascii "1989","1990","1991","1992","1993","1994","1995" 

    .4byte 16,22,382,1356,2390,8000,16000
    .4byte 24486,50065,97479,140417,197514,345980,590827
    .4byte 803530,1183000,1843000,2759000,3753000,4649000,5937000

    .short 3,7,9,13,28,38,130
    .short 220,476,778,1001,1442,2258,2793
    .short 4037,5635,8226,11542,14430,15257,17800

TABLE:
    .zero 336
.text
.globl _start

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
    movq $21,%rcx
    leaq DATA,%rsi
    leaq TABLE,%rdi
.L1:
    pushq %rcx
    negq %rcx
    addq $21,%rcx
    movl (%rsi,%rcx,4),%ebx
    movl %ebx,(%rdi)
    movl 84(%rsi,%rcx,4),%ebx
    movl %ebx,5(%rdi)
    movw 168(%rsi,%rcx,2),%bx
    movw %bx,10(%rdi)
    movw 84(%rsi,%rcx,4),%ax
    movw 86(%rsi,%rcx,4),%dx
    idivw 168(%rsi,%rcx,2)
    movw %ax,13(%rdi)
    addq $16,%rdi
    popq %rcx
LOOP .L1
    movq $21,%rcx
    leaq TABLE,%rbx
.L2:
    pushq %rcx
    movq %rbx,%rdi
    movq $4,%rsi
    call _print_string

    movq $32,%rdi
    call _print_char

    movl 5(%rbx),%edi
    call _print_num

    movq $32,%rdi
    call _print_char

    movw 10(%rbx),%di
    call _print_num

    movq $32,%rdi
    call _print_char

    movw 13(%rbx),%di
    call _print_num

    movq $10,%rdi
    call _print_char

    addq $16,%rbx
    popq %rcx
LOOP .L2
.done:
    movq $60,%rax
    movq $0,%rdi
    syscall

