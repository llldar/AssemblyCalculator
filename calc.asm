.386

.MODEL flat, c
includelib msvcrt.lib

printf PROTO arg1:Ptr BYTE, printlist:VARARG
scanf  PROTO arg2:Ptr BYTE, inputlist:VARARG

.DATA
    nl EQU 0Ah
    fmt_input   BYTE "%c %d %d",0
    fmt_output  BYTE "%s",0
    fmt_output2 BYTE "opt:%c opr1:%d opr2:%d",nl,0
    fmt_output3 BYTE "result: %d",nl,0
    msg_version BYTE "Assembly Calculator v0.1",nl,0
    msg_author  BYTE "Written by Nathaniel Lin.",nl,0
    msg_usage   BYTE "Usage: OPR OP1 OP2",nl,0
    msg_example BYTE "Example: + 1 2",nl,0
    msg_error   BYTE "Invalid Expression!",nl,0

    label1      BYTE "addition",nl,0
    label2      BYTE "subtraction",nl,0
    label3      BYTE "multiplication",nl,0
    label4      BYTE "division",nl,0

    operator DWORD ?
    operand1 SDWORD 0
    operand2 SDWORD 0
    result   SDWORD 0
    remain   SDWORD 0

.CODE
start:
        invoke printf, ADDR fmt_output, ADDR msg_version
        invoke printf, ADDR fmt_output, ADDR msg_author 
        invoke printf, ADDR fmt_output, ADDR msg_usage 
        invoke printf, ADDR fmt_output, ADDR msg_example 
        invoke scanf, ADDR fmt_input, ADDR operator, ADDR operand1,ADDR operand2 

        cmp operator,'+'
        je  addition
        cmp operator,'-'
        je  subtraction
        cmp operator,'*'
        je  multiplication
        cmp operator,'/'
        je  division
        jmp error

error:
    invoke printf,ADDR fmt_output, ADDR msg_error
    jmp quit

addition:
    invoke printf,ADDR fmt_output, ADDR label1
    mov eax,operand1
    add eax,operand2
    mov result,eax
    jmp res

subtraction:
    invoke printf,ADDR fmt_output, ADDR label2
    mov eax,operand1
    sub eax,operand2
    mov result,eax
    jmp res

multiplication:
    invoke printf,ADDR fmt_output, ADDR label3
    mov eax,operand1
    imul operand2
    mov result,eax
    jmp res

division:
    invoke printf,ADDR fmt_output, ADDR label4
    xor edx,edx
    mov eax,operand1
    mov ebx,operand2
    idiv ebx
    mov result,eax
    mov remain,edx
    jmp res

res:
    invoke printf, ADDR fmt_output3,result
quit: 
    RET
end start
