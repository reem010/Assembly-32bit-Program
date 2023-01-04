# To compile this assembly program on windows:
# gcc -O3 -o code.exe code.s
# After running the program, enter a positive integer and press Enter
# The program should output (1 + 1/1) + (2 + 1/4) + (3 + 1/9) + (4 + 1/16) + ... + (n + 1/(n^2)).

.intel_syntax noprefix  # use the intel syntax, not AT&T syntax. do not prefix registers with %

.section .data        # memory variables
outputMessage: .asciz "Enter n: " #string terminated by 0 that will be used for scanf parameter
input: .asciz "%d"    # string terminated by 0 that will be used for scanf parameter
output: .asciz "The sum is: %f\n"     # string terminated by 0 that will be used for printf parameter

n: .int 0             # the variable n which we will get from user using scanf
res: .double 0.0      # the variable s=1/1+1/2+1/3+...+1/n that will be calculated by the program and will be printed by printf, s is initialized to 0
one: .double 1.0      # the variable 1 used in calculations
r: .double 1.0        # the variable r used in calculations (starts at 1 ends at n)

.section .text     # instructions
.globl _main       # make _main accessible from external

_main:             # the label indicating the start of the program
push OFFSET outputMessage # push to stack the parameter to print
call _printf       #print message "Enter n: "
push OFFSET n      # push to stack the second parameter to scanf (the address of the integer variable n)
push OFFSET input  # push to stack the first parameter to scanf
call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
add esp, 12        # pop the above three parameters from the stack (the esp register keeps track of the stack top, 8=2*4 bytes popped as param was 4 bytes)

mov ecx, n         # ecx <- n (the number of iterations)
loop1:
# the following 4 instructions increase res by r+(1/r^2)
fld qword ptr one            # push 1 to the floating point stack
fdiv qword ptr r             # pop the floating point stack top (1), divide it over r and push the result (1/r)
fdiv qword ptr r             # pop the floating point stack top (1/r), divide it over r and push the result (1/r^2)
fadd qword ptr r             # pop the floating point stack top (1/r^2), add it to r and push the result r+(1/r^2)
fadd qword ptr res            # pop the floating point stack top (1/r^2), add it to res, and push the result (res+(1/r^2))
fstp qword ptr res            # pop the floating point stack top (res+(1/r^2)) into the memory variable res

# the following 3 instructions increase r by 1   
fld qword ptr r              # push 1 to the floating point stack
fadd qword ptr one           # pop the floating point stack top (1), add it to r and push the res (r+1)
fstp qword ptr r             # pop the floating point stack top (r+1) into the memory variable r

loop loop1        # ecx -=1 , then goto loop1 only if ecx is not zero

push [res+4]         # push to stack the high 32-bits of the second parameter to printf (the double at label res)
push res             # push to stack the low 32-bits of the second parameter to printf (the double at label res)
push OFFSET output   # push to stack the first parameter to printf
call _printf         # call printf
add esp, 12          # pop the three parameters

ret                  # end the main function