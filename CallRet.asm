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
# 提示语
msg:    .ascii "WHAT IS THE DATE"
# 提示语长度
len:    .quad len-msg


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

# 声明一个用于输出单个字符的函数，需要一个参数
_print_char:
.PCini:
    pushq %rbp
    movq %rsp,%rbp
.PC0:
    pushq %rdi
.PC1:
    movq $1,%rax
    movq $1,%rdi
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

# 声明一个读入单个字符的函数，返回读入的字符
_get_char:
.GCini:
    pushq %rbp
    movq %rsp,%rbp
.GCpre:
    # 在栈中预留输入用的空间
    subq $8,%rsp
.GC0:
    movq $0,%rax
    movq $0,%rdi
    # 输入的字符存储到栈顶
    movq %rsp,%rsi
    movq $1,%rdx
    syscall
    # 将输入的字符放到rax中返回
    movq (%rsp),%rax
    addq $8,%rsp
.GCdone:
    popq %rbp
    ret
# 声明一个读入一个整形数的函数，返回读入的整形数
_get_num:
.GNini:
    pushq %rbp
    movq %rsp,%rbp
.GNpre:
    # 在栈中预留位置用于存放生成的整形数
    subq $8,%rsp
    movq $0,(%rsp)
.GN0:
    # 不断读入，直到读到的数在ascii码‘0’到‘9’之间
    call _get_char
    cmpq $48,%rax
    jl .GN0
    cmpq $57,%rax
    jg .GN0
.GN1:
    # 不断读入，直到读入的数不在ascii码‘0’到‘9’之间
    cmpq $48,%rax
    jl .GN2
    cmpq $57,%rax
    jg .GN2
    # 读入的数减去48得到真实数字
    subq $48,%rax
    # 输入数移动到rcx，将之前的数移动到rax
    movq %rax,%rcx
    movq (%rsp),%rax
    # 之前的数乘10
    imulq $10,%rax
    # 将读入的数加到之前的数中
    addq %rcx,%rax
    # 得到的新数压栈
    movq %rax,(%rsp)
    call _get_char
    jmp .GN1
.GN2:
    # 返回读入的数字
    movq (%rsp),%rax
    addq $8,%rsp
.GNDone:
    popq %rbp
    ret
# 主函数入口
_start:
    # 将提示语的地址赋给rdi，提示语的长度赋给rsi，调用函数输出
    leaq msg,%rdi
    movq len,%rsi
    call _print_string
    # 输出换行
    movq $10,%rdi
    call _print_char
    # 输出响铃
    movq $7,%rdi
    call _print_char
    # 读入三个数组，按顺序压栈，栈顶是日期，下一个是月份，最后是年份
    call _get_num
    pushq %rax
    call _get_num
    pushq %rax
    call _get_num
    pushq %rax
    # 输出位于栈顶的日期
    movq (%rsp),%rdi
    call _print_num
    # 输出短横线
    movq $45,%rdi
    call _print_char
    # 输出位于栈底(相对栈顶偏移16)的年份
    movq 16(%rsp),%rdi
    call _print_num
    # 输出短横线
    movq $45,%rdi
    call _print_char
    # 输出栈第二个元素(相对栈顶偏移8)的月份
    movq 8(%rsp),%rdi
    call _print_num
    # 输出换行
    movq $10,%rdi
    call _print_char
.done:
    # 程序结束
    movq $60,%rax
    movq $0,%rdi
    syscall
