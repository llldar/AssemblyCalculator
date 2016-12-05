.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD		;主窗口过程
AppendText proto StringAddr:DWORD,Text:DWORD	;用于在字符串末尾添加字符
CalProc proto ExpAddr:DWORD						;计算器的中缀表达式处理过程
getEndChar proto StringAddr:DWORD 				;获取末尾字符，返回的 值 存在eax中
setEndChar proto StringAddr:DWORD,Text:DWORD	;设置末尾字符
isOperator proto chr:DWORD						;是否运算符，传入值
atoi proto ExpAddr:DWORD						;用于把文字转换为数字
itoa proto num:DWORD,StringAddr:DWORD			;用于把数字转换为文字
scrollToOpt proto ExpAddr:DWORD					;找到下一个符号
optcmp proto StkAddr:DWORD,opt:DWORD 			;用于符号间的优先级比较
calculate proto op1:DWORD,op2:DWORD,opt:DWORD	;实际的运算处理
promptError proto 								;错误提示
MessageBoxA proto :DWORD,:DWORD,:DWORD,:DWORD
MessageBox equ <MessageBoxA> 					;用于显示错误消息

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data
temp 	db 0
ClassName db "SimpleWinClass",0
AppName  db "计算器",0
MenuName db "FirstMenu",0
ButtonClassName db "button",0
errorwinTittle db "错误提示",0
errorMsg db "发生错误",0
ButtonText1 db "1",0
ButtonText2 db "2",0
ButtonText3 db "3",0
ButtonText4 db "4",0
ButtonText5 db "5",0
ButtonText6 db "6",0
ButtonText7 db "7",0
ButtonText8 db "8",0
ButtonText9 db "9",0
ButtonText0 db "0",0
ButtonTextAdd db "+",0
ButtonTextSub db "-",0
ButtonTextMul db "*",0
ButtonTextDiv db "/",0
ButtonTextEqu db "=",0
ButtonTextClr db "AC",0


EditClassName db "edit",0
TestString db "Wow! I'm in an edit box now",0

.data?
hInstance HINSTANCE ?
hInstance1 HINSTANCE ?
hInstance2 HINSTANCE ?
hInstance3 HINSTANCE ?
hInstance4 HINSTANCE ?
hInstance5 HINSTANCE ?
hInstance6 HINSTANCE ?
hInstance7 HINSTANCE ?
hInstance8 HINSTANCE ?
hInstance9 HINSTANCE ?
hInstance0 HINSTANCE ?
hInstanceAdd HINSTANCE ?
hInstanceSub HINSTANCE ?
hInstanceMul HINSTANCE ?
hInstanceDiv HINSTANCE ?
hInstanceEqu HINSTANCE ?
hInstanceClr HINSTANCE ?

CommandLine LPSTR ?
ButtonOne HWND ?
ButtonTwo HWND ?
ButtonThree HWND ?
ButtonFour HWND ?
ButtonFive HWND ?
ButtonSix HWND ?
ButtonSeven HWND ?
ButtonEight HWND ?
ButtonNine HWND ?
ButtonZero HWND ?
ButtonAdd HWND ?
ButtonSub HWND ?
ButtonMul HWND ?
ButtonDiv HWND ?
ButtonEqu HWND ?
ButtonClr HWND ?
hwndEdit HWND ?
;输入表达式缓冲区
buffer db 512 dup(?)
;数字栈
oprs db 512 dup(?)
;符号栈
opts db 512 dup(?)
;结果存储区域
result db 128 dup(?)

.const

EditID equ 10

ButtonAddID equ 11
ButtonSubID equ 12
ButtonMulID equ 13
ButtonDivID equ 14
ButtonEquID equ 15
ButtonClrID equ 16

IDM_HELLO equ 1
IDM_CLEAR equ 2
IDM_GETTEXT equ 3
IDM_EXIT equ 4
IDM_UPDATETEXT equ 5
IDM_APEENDTEXT equ 6

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_BTNFACE+1
	mov   wc.lpszMenuName,OFFSET MenuName
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	;创建主窗口
	INVOKE CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,215,300,NULL,NULL,\
           hInstance,NULL
	mov   hwnd,eax
	INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
	INVOKE UpdateWindow, hwnd

	;消息处理循环
	.WHILE TRUE
                INVOKE GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                INVOKE TranslateMessage, ADDR msg
                INVOKE DispatchMessage, ADDR msg
	.ENDW
	mov     eax,msg.wParam
	ret
WinMain endp


AppendText proc StringAddr:DWORD,Text:DWORD
	push eax
	push ebx
	push ecx
	push edx
	mov eax,StringAddr
	mov ebx,Text
	xor ecx,ecx
	mov dl,[eax]
	.WHILE dl != 0
		add eax,1
		mov dl,[eax]
	.ENDW
	mov [eax],bl
	add eax,1
	mov [eax],cl
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
AppendText endp

;获取末尾字符
getEndChar proc StringAddr:DWORD
	push ecx
	push edx
	mov eax,StringAddr
	mov dl,[eax]
	.WHILE dl !=0
		add eax,1
		mov dl,[eax]
	.ENDW
	mov ecx,eax
	sub ecx,1
	mov dl,[ecx]
	xor eax,eax
	mov al,dl
	pop edx
	pop ecx
	ret 	
	;返回值存储在eax中
getEndChar endp

;设置末尾字符
setEndChar proc StringAddr:DWORD,Text:DWORD
	push ebx
	push edx
	mov eax,StringAddr
	mov ebx,Text
	mov dl,[eax]
	.WHILE dl != 0
		add eax,1
		mov dl,[eax]
	.ENDW
	sub eax,1
	mov [eax],bl
	pop edx
	pop ebx
	ret
setEndChar endp

;检测字符是否运算符 注意要传字符值，而非地址
isOperator proc chr:DWORD
	.IF chr == '+' || chr == '-' || chr == '*' || chr == '/'
		mov eax,1
	.ELSE
		mov eax,0
	.ENDIF
	ret
isOperator endp

atoi proc ExpAddr:DWORD
	push ebx
	push ecx
	push edx
	xor ecx,ecx
	xor edx,edx
	mov ebx,ExpAddr
	invoke scrollToOpt,ebx
	mov ecx,eax
	xor eax,eax
	.WHILE ebx < ecx
		mov dl,[ebx]
		sub dl,'0'
		;实现eax乘以10
		push ebx
		mov ebx,eax
		sal eax,3
		sal ebx,1
		add eax,ebx
		pop ebx

		add eax,edx
		add ebx,1
	.ENDW
	pop edx
	pop ecx
	pop ebx
	ret
	;返回值存储在eax中
atoi endp

itoa proc num:DWORD,StringAddr:DWORD
	push ebx
	push ecx
	push edx
	xor edx,edx
	xor ecx,ecx
	mov eax,num

	;检测正负
	sar eax,31
	.IF eax == 0
		;正数或0的情况
		;计算位数
		mov ebx,10
		;本身就是0
		.IF eax == 0
			mov ecx,1
		.ENDIF
		.WHILE eax != 0
			idiv ebx
			add ecx,1
			xor edx,edx
		.ENDW
		xor edx,edx

		mov eax,num
		mov ebx,StringAddr
		;结果字符串后边补0
		add ebx,ecx
		mov edx,0
		mov [ebx],dl
		sub ebx,1

		.WHILE ecx > 0
			push ebx
			mov ebx,10
			xor edx,edx
			idiv ebx
			add edx,'0'
			pop ebx
			;写入字符串
			mov [ebx],dl
			sub ebx,1
			sub ecx,1
		.ENDW
	.ELSE
		;负数的情况
		mov ebx,eax;存储全1的mask
		mov eax,num
		sub eax,1
		xor eax,ebx;反向
		push eax
		mov ebx,10
		;下面类似正数部分
		.WHILE eax != 0
		    xor edx,edx
			idiv ebx
			add ecx,1
		.ENDW
		xor edx,edx
		add ecx,1;多一个地方存负号

		pop eax
		mov ebx,StringAddr
		;结果字符串后边补0
		add ebx,ecx
		mov edx,0
		mov [ebx],dl
		sub ebx,1

		.WHILE ecx > 1
			push ebx
			mov ebx,10
			xor edx,edx
			idiv ebx
			add edx,'0'
			pop ebx
			;写入字符串
			mov [ebx],dl
			sub ebx,1
			sub ecx,1
		.ENDW

		;最前面加一个负号
		mov dl,'-'
		mov [ebx],dl
		sub ebx,1
		sub ecx,1

	.ENDIF
	pop edx
	pop ecx
	pop ebx
	ret
itoa endp

scrollToOpt proc ExpAddr:DWORD
	;如果有符号则移动至符号处，移动到结尾为止

	push ebx
	push ecx
	xor eax,eax
	xor ecx,ecx
	mov ebx,ExpAddr
	mov cl,[ebx]
	;一上来就是结尾
	.IF cl == 0
		mov eax,1
	.ENDIF
	;找到下一个符号
	.WHILE eax != 1
		add ebx,1
		mov cl,[ebx]
		invoke isOperator,ecx
		.IF cl == 0
			mov eax,1
		.ENDIF
	.ENDW
	mov eax,ebx
	pop ecx
	pop ebx
	ret
	;返回值存储在eax中	
scrollToOpt endp

optcmp proc StkAddr:DWORD,opt:DWORD
	;注意要传入操作符栈顶的地址,opt为操作符的值
	push ebx
	push ecx
	mov ebx,StkAddr
	mov ecx,[ebx]

	.IF opt == '*' || opt == '/'
		.IF  ecx == '*' || ecx == '/'
			xor eax,eax
		.ELSE
			;优先级更高的情况
			mov eax,1
		.ENDIF
	.ELSE
		.IF  ecx == '*' || ecx == '/'
			xor eax,eax
		.ELSE
			xor eax,eax
		.ENDIF
	.ENDIF

	pop ecx
	pop ebx
	ret
	;返回值存储在eax中
optcmp endp

promptError proc
	push eax
	push ebx
	push ecx
	push edx
	invoke MessageBox,NULL,ADDR errorMsg,ADDR errorwinTittle,MB_OK
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
promptError	endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	;创建窗口时的初始化动作
	.ELSEIF uMsg==WM_CREATE
		;添加文本框
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\
                        ES_AUTOHSCROLL,\
                        30,30,165,30,hWnd,EditID,hInstance,NULL
		mov  hwndEdit,eax
		invoke SetFocus, hwndEdit
		;添加按钮
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText1,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        30,210,30,30,hWnd,1,hInstance1,NULL
		mov  ButtonOne,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText2,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        75,210,30,30,hWnd,2,hInstance2,NULL
		mov  ButtonTwo,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText3,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        120,210,30,30,hWnd,3,hInstance3,NULL
		mov  ButtonThree,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText4,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        30,165,30,30,hWnd,4,hInstance4,NULL
		mov  ButtonFour,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText5,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        75,165,30,30,hWnd,5,hInstance5,NULL
		mov  ButtonFive,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText6,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        120,165,30,30,hWnd,6,hInstance6,NULL
		mov  ButtonSix,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText7,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        30,120,30,30,hWnd,7,hInstance7,NULL
		mov  ButtonSeven,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText8,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        75,120,30,30,hWnd,8,hInstance8,NULL
		mov  ButtonEight,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText9,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        120,120,30,30,hWnd,9,hInstance9,NULL
		mov  ButtonNine,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText0,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        75,75,30,30,hWnd,0,hInstance0,NULL
		mov  ButtonZero,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextAdd,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        165,165,30,30,hWnd,ButtonAddID,hInstanceAdd,NULL
		mov  ButtonAdd,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextSub,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        165,120,30,30,hWnd,ButtonSubID,hInstanceSub,NULL
		mov  ButtonSub,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextMul,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        165,75,30,30,hWnd,ButtonMulID,hInstanceMul,NULL
		mov  ButtonMul,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextDiv,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        120,75,30,30,hWnd,ButtonDivID,hInstanceDiv,NULL
		mov  ButtonDiv,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextEqu,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        165,210,30,30,hWnd,ButtonEquID,hInstanceEqu,NULL
		mov  ButtonEqu,eax
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextClr,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        30,75,30,30,hWnd,ButtonClrID,hInstanceClr,NULL
		mov  ButtonClr,eax

	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.IF lParam==0
			;指令处理区域
			.IF ax==IDM_CLEAR
				invoke SetWindowText,hwndEdit,NULL
			.ELSEIF  ax==IDM_GETTEXT
				invoke GetWindowText,hwndEdit,ADDR buffer,512
				invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
			.ELSEIF  ax==IDM_UPDATETEXT
				invoke GetWindowText,hwndEdit,ADDR buffer,512
				invoke CalProc,ADDR buffer
				invoke itoa,eax,ADDR result
				invoke SetWindowText,hwndEdit,ADDR result
			.ELSE
				invoke DestroyWindow,hWnd
			.ENDIF
		;数字处理
		.ELSEIF lParam>='0' && lParam<='9'
			;输入处理	
				invoke GetWindowText,hwndEdit,ADDR buffer,512
				invoke AppendText,ADDR buffer,lParam
				invoke SetWindowText,hwndEdit,ADDR buffer
		;符号处理
		.ELSEIF lParam == '+' || lParam == '-' || lParam == '*' || lParam == '/'
			;如果前面有符号:
			invoke GetWindowText,hwndEdit,ADDR buffer,512
			invoke getEndChar,ADDR buffer
			invoke isOperator,eax
			.IF eax == 1
				invoke setEndChar,ADDR buffer,0
			.ENDIF
			invoke AppendText,ADDR buffer,lParam
			invoke SetWindowText,hwndEdit,ADDR buffer
		.ELSE
			;按钮函数回调区域
			.IF ax==1
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'1'
				.ENDIF
			.ELSEIF ax==2
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'2'
				.ENDIF
			.ELSEIF ax==3
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'3'
				.ENDIF
			.ELSEIF ax==4
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'4'
				.ENDIF
			.ELSEIF ax==5
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'5'
				.ENDIF
			.ELSEIF ax==6
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'6'
				.ENDIF
			.ELSEIF ax==7
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'7'
				.ENDIF
			.ELSEIF ax==8
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'8'
				.ENDIF
			.ELSEIF ax==9
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'9'
				.ENDIF
			.ELSEIF ax==0
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'0'
				.ENDIF
			.ELSEIF ax==ButtonAddID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'+'
				.ENDIF
			.ELSEIF ax==ButtonSubID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'-'
				.ENDIF
			.ELSEIF ax==ButtonMulID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'*'
				.ENDIF
			.ELSEIF ax==ButtonDivID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,'/'
				.ENDIF
			.ELSEIF ax==ButtonEquID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_UPDATETEXT,0
				.ENDIF
			.ELSEIF ax==ButtonClrID
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_CLEAR,0
				.ENDIF
			.ENDIF
		.ENDIF
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp

calculate proc op1:DWORD,op2:DWORD,opt:DWORD
	push ebx
	push ecx 
	push edx
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	.IF opt == '+'
		mov eax,op1
    	add eax,op2
	.ELSEIF opt == '-'
		mov eax,op1
    	sub eax,op2
	.ELSEIF opt == '*'
		mov eax,op1
		imul op2
	.ELSEIF opt == '/'
		mov eax,op1
		mov ebx,op2
		.IF ebx == 0
			invoke promptError
			mov ebx,1
		.ENDIF
		idiv ebx
	.ELSE
		invoke promptError
	.ENDIF
	pop edx
	pop ecx
	pop ebx
	;返回值存储在eax中
	ret
calculate endp

;计算过程
CalProc proc ExpAddr:DWORD
	push ebx;存数字栈顶
	push ecx;存符号栈顶
	push edx;存表达式的进度指针
	mov ebx,offset oprs
	mov ecx,offset opts
	mov edx,ExpAddr 

	.WHILE edx != 0
		invoke atoi,edx
		;推入数字栈
		mov [ebx],eax
		add ebx,4

		invoke scrollToOpt,edx
		mov edx,eax
		xor eax,eax
		mov al,[edx]
		invoke isOperator,eax
		.IF eax == 1
			mov al,[edx]
			;与栈顶符号比较
			invoke optcmp,ecx,eax
			.IF eax == 0
				;一直弹出到同级别或栈空为止
				.WHILE ecx > offset opts && eax == 0
					sub ecx,4
					push ecx
					push edx

					;弹出一个操作符两个数字进行计算
					
					mov eax,[ecx]

					sub ebx,4
					mov ecx,[ebx]
					sub ebx,4
					mov edx,[ebx]

					;由于堆栈的反向原因，操作数顺序交换
					invoke calculate,edx,ecx,eax
					;结果数字回栈
					mov [ebx],eax
					add ebx,4

					pop edx
					pop ecx
					.IF ecx > offset opts
						invoke optcmp,ecx,eax
					.ENDIF
				.ENDW
			.ENDIF
				;将当前操作符压栈
				mov al,[edx]
				mov [ecx],eax
				add ecx,4
				add edx,1
			
		.ELSE
			;到达末尾
			;结果加载到eax中
			mov eax,[ebx]
			xor edx,edx
		.ENDIF
	.ENDW
	
	;处理栈中剩下的数字和符号
	;出一个符号，两个数字进行计算
	.WHILE ecx > offset opts
		sub ecx,4
		push ecx
		push edx

		mov eax,[ecx]
		sub ebx,4
		mov ecx,[ebx]
		sub ebx,4
		mov edx,[ebx]
		;由于堆栈的反向原因，操作数顺序交换
		invoke calculate,edx,ecx,eax
		;结果数字回栈
		mov [ebx],eax
		add ebx,4
		pop edx
		pop ecx
	.ENDW

	;最终结果
	sub ebx,4
	mov eax,[ebx]
	pop edx
	pop ecx
	pop ebx
	;返回值存储在eax中
	ret
CalProc endp



end start
