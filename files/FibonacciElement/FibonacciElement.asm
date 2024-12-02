// init
// set @SP
@256
D=A
@SP
M=D
// set @LCL
@300
D=A
@LCL
M=D
// set @ARG
@400
D=A
@ARG
M=D
// set @THIS
@3000
D=A
@THIS
M=D
// set @THAT
@3010
D=A
@THAT
M=D
// call Sys.init
// push return-address
@FibonacciElement.Sys.init$ret.1
D=A
@SP
A=M
M=D
@SP
M=M+1
// push LCL
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
// push ARG
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THIS
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THAT
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
// ARG = SP - n - 5
@SP
D=M
@5
D=D-A
@ARG
M=D
// LCL = SP
@SP
D=M
@LCL
M=D
// goto function
@FibonacciElement.Sys.init
0;JMP
// (return-address)
(FibonacciElement.Sys.init$ret.1)

// function Main.fibonacci 1
(FibonacciElement.Main.fibonacci)
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@TRUE111
D;JLT
@SP
A=M
M=0
@END111
0;JMP
(TRUE111)
@SP
A=M
M=-1
(END111)
@SP
M=M+1
// if-goto N_LT_2
@SP
M=M-1
A=M
D=M+1
@FibonacciElement.Main.fibonacci$N_LT_2
D;JEQ
// goto N_GE_2
@FibonacciElement.Main.fibonacci$N_GE_2
0;JMP
// label N_LT_2               // if n < 2 returns n
(FibonacciElement.Main.fibonacci$N_LT_2)
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// return
// endFRAME = LCL
@LCL
D=M
@R13
M=D
// RETaddr = *(endFRAME - 5)
@5
A=D-A
D=M
@R14
M=D
// *ARG = pop()
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
// SP = ARG + 1
@ARG
D=M+1
@SP
M=D
// THAT = *(endFRAME - 1)
@R13
M=M-1
A=M
D=M
@THAT
M=D
// THIS = *(endFRAME - 2)
@R13
M=M-1
A=M
D=M
@THIS
M=D
// ARG = *(endFRAME - 3)
@R13
M=M-1
A=M
D=M
@ARG
M=D
// LCL = *(endFRAME - 4)
@R13
M=M-1
A=M
D=M
@LCL
M=D
// goto RETaddr
@R14
A=M
0;JMP
// label N_GE_2               // if n >= 2 returns fib(n - 2) + fib(n - 1)
(FibonacciElement.Main.fibonacci$N_GE_2)
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M-D
@SP
M=M+1
// call Main.fibonacci 1  // computes fib(n - 2)
// push return-address
@FibonacciElement.Main.fibonacci$ret.1
D=A
@SP
A=M
M=D
@SP
M=M+1
// push LCL
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
// push ARG
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THIS
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THAT
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
// ARG = SP - n - 5
@SP
D=M
@6
D=D-A
@ARG
M=D
// LCL = SP
@SP
D=M
@LCL
M=D
// goto function
@FibonacciElement.Main.fibonacci
0;JMP
// (return-address)
(FibonacciElement.Main.fibonacci$ret.1)
// push argument 0
@0
D=A
@ARG
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M-D
@SP
M=M+1
// call Main.fibonacci 1  // computes fib(n - 1)
// push return-address
@FibonacciElement.Main.fibonacci$ret.2
D=A
@SP
A=M
M=D
@SP
M=M+1
// push LCL
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
// push ARG
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THIS
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THAT
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
// ARG = SP - n - 5
@SP
D=M
@6
D=D-A
@ARG
M=D
// LCL = SP
@SP
D=M
@LCL
M=D
// goto function
@FibonacciElement.Main.fibonacci
0;JMP
// (return-address)
(FibonacciElement.Main.fibonacci$ret.2)
// add                    // returns fib(n - 1) + fib(n - 2)
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=D+M
@SP
M=M+1
// return
// endFRAME = LCL
@LCL
D=M
@R13
M=D
// RETaddr = *(endFRAME - 5)
@5
A=D-A
D=M
@R14
M=D
// *ARG = pop()
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
// SP = ARG + 1
@ARG
D=M+1
@SP
M=D
// THAT = *(endFRAME - 1)
@R13
M=M-1
A=M
D=M
@THAT
M=D
// THIS = *(endFRAME - 2)
@R13
M=M-1
A=M
D=M
@THIS
M=D
// ARG = *(endFRAME - 3)
@R13
M=M-1
A=M
D=M
@ARG
M=D
// LCL = *(endFRAME - 4)
@R13
M=M-1
A=M
D=M
@LCL
M=D
// goto RETaddr
@R14
A=M
0;JMP
// function Sys.init 0
(FibonacciElement.Sys.init)
// push constant 4
@4
D=A
@SP
A=M
M=D
@SP
M=M+1
// call Main.fibonacci 1
// push return-address
@FibonacciElement.Main.fibonacci$ret.3
D=A
@SP
A=M
M=D
@SP
M=M+1
// push LCL
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
// push ARG
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THIS
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
// push THAT
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
// ARG = SP - n - 5
@SP
D=M
@6
D=D-A
@ARG
M=D
// LCL = SP
@SP
D=M
@LCL
M=D
// goto function
@FibonacciElement.Main.fibonacci
0;JMP
// (return-address)
(FibonacciElement.Main.fibonacci$ret.3)
// label END
(FibonacciElement.Sys.init$END)
// goto END  // loops infinitely
@FibonacciElement.Sys.init$END
0;JMP
