.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
AppendText proto StringAddr:DWORD,Text:DWORD

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
buffer db 512 dup(?)

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
	pop eax
	pop ebx
	pop ecx
	pop edx
	ret
AppendText endp

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
			;.ELSEIF  ax==IDM_UPDATETEXT
				;invoke 
			.ELSE
				invoke DestroyWindow,hWnd
			.ENDIF
		.ELSEIF lParam>0 && lParam<=9
			;输入处理	
				invoke GetWindowText,hwndEdit,ADDR buffer,512
				;给lParam加'0'使其转换为字符
				push eax;
				mov eax,lParam;
				add eax,48;
				mov lParam,eax;
				pop eax;
				invoke AppendText,ADDR buffer,lParam
				invoke SetWindowText,hwndEdit,ADDR buffer
		.ELSEIF lParam == '+' || lParam == '-' || lParam == '*' || lParam == '/' || lParam == 10
			.IF lParam == 10
				;把0转换为字符
				push eax;
				mov eax,lParam;
				add eax,38;
				mov lParam,eax;
				pop eax;
				invoke AppendText,ADDR buffer,lParam
				invoke SetWindowText,hwndEdit,ADDR buffer
			.ELSE
				invoke AppendText,ADDR buffer,lParam
				invoke SetWindowText,hwndEdit,ADDR buffer
			.ENDIF
		.ELSE
			;按钮函数回调区域
			.IF ax==1
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,1
				.ENDIF
			.ELSEIF ax==2
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,2
				.ENDIF
			.ELSEIF ax==3
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,3
				.ENDIF
			.ELSEIF ax==4
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,4
				.ENDIF
			.ELSEIF ax==5
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,5
				.ENDIF
			.ELSEIF ax==6
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,6
				.ENDIF
			.ELSEIF ax==7
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,7
				.ENDIF
			.ELSEIF ax==8
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,8
				.ENDIF
			.ELSEIF ax==9
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,9
				.ENDIF
			.ELSEIF ax==0
				shr eax,16
				.IF ax==BN_CLICKED
					invoke SendMessage,hWnd,WM_COMMAND,IDM_APEENDTEXT,10
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


end start
