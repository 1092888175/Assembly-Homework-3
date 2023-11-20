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
# 在数据段中定义DATA开头的一段
DATA: 
    # 以字符串形式存储，每个字符占一字节
    .ascii "1975","1976","1977","1978","1979","1980","1981"
    .ascii "1982","1983","1984","1985","1986","1987","1988"
    .ascii "1989","1990","1991","1992","1993","1994","1995" 
    # 以数字形式存储，每个数字占4字节
    .4byte 16,22,382,1356,2390,8000,16000
    .4byte 24486,50065,97479,140417,197514,345980,590827
    .4byte 803530,1183000,1843000,2759000,3753000,4649000,5937000
    # 以数字形式存储，每个数字占2字节
    .short 3,7,9,13,28,38,130
    .short 220,476,778,1001,1442,2258,2793
    .short 4037,5635,8226,11542,14430,15257,17800
# 在数据段中定义TABLE开头的一段
TABLE:
    .zero 336


.text
.globl _start
# 声明一个打印字符串的函数，需要两个参数
_print_string:
.PSini:
	# 创建新栈，保存原栈
	pushq %rbp
	movq %rsp,%rbp
.PS0:
	# 将字符串的首地址和要打印的长度赋给参数2和参数3
	movq %rsi,%rdx
	movq %rdi,%rsi
.PS1:
	# 将调用号和文件描述符赋给%rax和参数1
	movq $1,%rax
	movq $1,%rdi
	syscall
.PSdone:
	# 还原栈，返回	 
	popq %rbp
	ret

# 定义一个用于输出单个字符的函数，需要一个参数
_print_char:
.PCini:
    pushq %rbp
    movq %rsp,%rbp
.PC0:
    # 将存储于rdi中的要输出的字符压入栈
    pushq %rdi
.PC1:
    movq $1,%rax
    movq $1,%rdi
    # 输出栈顶元素
    movq %rsp,%rsi
    movq $1,%rdx
    syscall
    popq %rdi
.PCdone:
    popq %rbp
    ret

# 声明一个以十进制格式打印数字的函数，需要一个参数
_print_num:
.PNini:
	# 创建新栈，保存原栈
	pushq %rbp
	movq %rsp,%rbp
.PN0:
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
	je .PNdone
    movq $1,%rax
	movq $1,%rdi
	movq %rsp,%rsi
	movq $1,%rdx
	syscall
	popq %rdx
	jmp .PN2
.PNdone:
	# 还原栈，返回	 
	popq %rbp
	ret

_start:
    # 一共21年，循环21次
    movq $21,%rcx
    # 将DATA段的地址存到rsi中
    leaq DATA,%rsi
    # 将TABLE段的地址存到rdi中
    leaq TABLE,%rdi
.L1:
    # 存储循环变量
    pushq %rcx
    # 循环变量取负加21，得到当前的偏移年数
    negq %rcx
    addq $21,%rcx
    # 取第一个数组中的年份填充到Table偏移0处
    movl (%rsi,%rcx,4),%ebx
    movl %ebx,(%rdi)
    # 取第二个数组(相较DATA段偏移84字节)中的总收入填充到Table偏移5处
    movl 84(%rsi,%rcx,4),%ebx
    movl %ebx,5(%rdi)
    # 取第三个数组(偏移168字节)中的公司雇员数填充到Table偏移10处
    movw 168(%rsi,%rcx,2),%bx
    movw %bx,10(%rdi)
    # 取第二个数组中的总收入的高端到dx，低段到ax，组成dx:ax用于16位除法
    movw 84(%rsi,%rcx,4),%ax
    movw 86(%rsi,%rcx,4),%dx
    # 总收入除以公司雇员数得平均收入，商存储到ax
    idivw 168(%rsi,%rcx,2)
    # 将平均收入填充到Table偏移13处
    movw %ax,13(%rdi)
    # rdi移动到下一年的开头位置
    addq $16,%rdi
    popq %rcx
LOOP .L1
    # 循环21次输出结果
    movq $21,%rcx
    # 将TABLE首地址存储到rbx
    leaq TABLE,%rbx
.L2:
    # 压栈保存rcx
    pushq %rcx
    # 输出存储于每一行开头四位的年份字符串
    movq %rbx,%rdi
    movq $4,%rsi
    call _print_string
    # 输出空格
    movq $32,%rdi
    call _print_char
    # 输出存储于每一行偏移5位置的总收入
    movl 5(%rbx),%edi
    call _print_num
    # 输出空格
    movq $32,%rdi
    call _print_char
    # 输出存储于每一行偏移10位置的雇员数
    movw 10(%rbx),%di
    call _print_num
    # 输出空格
    movq $32,%rdi
    call _print_char
    # 输出存储于每一行偏移位置13的平均收入
    movw 13(%rbx),%di
    call _print_num
    # 每一行输出一个换行
    movq $10,%rdi
    call _print_char
    # 地址加16，移动到下一行
    addq $16,%rbx
    # 恢复rcx
    popq %rcx
LOOP .L2
.done:
    # 程序结束
    movq $60,%rax
    movq $0,%rdi
    syscall

