.486
.model flat,stdcall
option casemap :none
include drd.inc
includelib drd.lib
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
includelib msvcrt.lib
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
.data

howtoplay BYTE "howtoplay.bmp",0
howtoplaystruct Img <0,0,0,0>
gameover BYTE "gameover.bmp",0
gameoverstruct Img <0,0,0,0>
start BYTE "start.bmp",0
startstruct Img <0,0,0,0>
surface BYTE "surface.bmp",0
surfacestruct Img <0,0,0,0>
soundfile db "music.wav",0
ball BYTE "ball.bmp",0
ballstruct Img <0,0,0,0>
xball DWORD 370
yball DWORD 300
ballkoter DWORD 50
xangle DWORD 1
yangle DWORD 1
xsurf DWORD 280
ysurf DWORD 450 
black DWORD 0
screenwdth DWORD 800
screenheght DWORD 600
surfacewdth DWORD 300
surfaceheght DWORD 20
playscreen proto
right proto
left proto
ballmovement proto
main proto
over proto
helpscreen proto
game proto
.code
X macro args:VARARG
	asm_txt TEXTEQU <>
	FORC char,<&args>
		IFDIF <&char>,<!\>
			asm_txt CATSTR asm_txt,<&char>
		ELSE
			asm_txt
			asm_txt TEXTEQU <>
		ENDIF
	ENDM
	asm_txt
endm
over PROC
push eax
invoke drd_pixelsClear, black
invoke drd_imageLoadFile,offset gameover,offset gameoverstruct
invoke drd_imageDraw,offset gameoverstruct,0,0
invoke drd_flip

overloop:
invoke drd_processMessages
X invoke GetAsyncKeyState, VK_R\ cmp eax,0 \ jne startagain 

jmp overloop

startagain:
pop eax
invoke playscreen
ret
over ENDP



ballmovement PROC

pusha

X mov eax, screenwdth\ sub eax,ballkoter \ cmp xball,eax \ jge screencollisionright

after_right:

X mov eax,yball\add eax,ballkoter \cmp eax,ysurf\jge surfacecollision

after_surface:

X mov eax,0\cmp yball,eax\je screencollisionup

after_up:

X mov eax,0 \ cmp xball,eax \ je screencollisionleft

after_left:

jmp exit

surfacecollision:
mov eax,xball
cmp eax,xsurf
;
jb after
mov ebx,xsurf
add ebx,240
cmp eax,ebx
;
jg after
mov yangle,-1
jmp after_surface
;

after:
jmp startagain
jmp after_surface

screencollisionup:
mov yangle,1
jmp after_up
;

screencollisionright:	
mov xangle,-1
jmp after_right
;

screencollisionleft:
mov xangle,1
jmp after_left
;

startagain:
invoke over

exit:
mov eax,xangle
add xball,eax
mov eax,yangle
add yball,eax
popa
ret
ballmovement ENDP

game PROC
push eax
processloop:
invoke drd_processMessages
invoke drd_pixelsClear, black
invoke ballmovement
invoke drd_imageLoadFile,offset surface,offset surfacestruct
invoke drd_imageLoadFile,offset ball,offset ballstruct
invoke drd_imageDraw,offset surfacestruct,xsurf,ysurf
invoke drd_imageDraw,offset ballstruct,xball,yball
invoke drd_flip

X invoke GetAsyncKeyState, VK_RIGHT \ cmp eax,0 \ jne invokeright 
X invoke GetAsyncKeyState, VK_LEFT \ cmp eax,0 \ jne invokeleft 
;

jmp processloop

invokeright:
invoke right
jmp processloop

invokeleft:
invoke left
jmp processloop
pop eax
ret
game ENDP

helpscreen PROC
push eax
invoke drd_pixelsClear, black
invoke drd_imageLoadFile,offset howtoplay,offset howtoplaystruct
invoke drd_imageDraw,offset howtoplaystruct,0,0
invoke drd_flip
loophelp:
invoke drd_processMessages
X invoke GetAsyncKeyState, VK_SPACE \ cmp eax,0 \ jne playgame
jmp loophelp

playgame:
pop eax
invoke game
ret

helpscreen ENDP

playscreen PROC
push eax
mov eax,370
mov xball,eax
mov eax,300
mov yball,eax
mov eax,1
mov xangle,eax
mov yangle,eax
mov eax, 280
mov xsurf,eax
mov eax,450
mov ysurf,eax

invoke PlaySound,addr soundfile,NULL,SND_ASYNC
invoke drd_imageLoadFile,offset start,offset startstruct
invoke drd_imageDraw,offset startstruct,0,0
invoke drd_flip

startloop:
invoke drd_processMessages
X invoke GetAsyncKeyState, VK_H \ cmp eax,0 \ jne help
X invoke GetAsyncKeyState, VK_SPACE \ cmp eax,0 \ jne startgame
jmp startloop

help:
invoke helpscreen

startgame:
invoke game
pop eax
ret
playscreen ENDP

right PROC

push eax
X cmp xsurf, 555 \ jge exit
;

invoke drd_pixelsClear, black
add xsurf,1
invoke drd_imageLoadFile,offset surface,offset surfacestruct
invoke drd_imageLoadFile,offset ball,offset ballstruct
invoke drd_imageDraw,offset surfacestruct,xsurf,ysurf
invoke drd_imageDraw,offset ballstruct,xball,yball
invoke drd_flip
;

exit:
pop eax
ret
right ENDP


left PROC

push eax
X cmp xsurf,5 \ jbe exit
; 
invoke drd_pixelsClear, black
sub xsurf,1
invoke drd_imageLoadFile,offset surface,offset surfacestruct
invoke drd_imageLoadFile,offset ball,offset ballstruct
invoke drd_imageDraw,offset surfacestruct,xsurf,ysurf
invoke drd_imageDraw,offset ballstruct,xball,yball
invoke drd_flip
;

exit:
pop eax
ret
left ENDP


main PROC

invoke drd_init,screenwdth,screenheght,0

invoke playscreen

ret

main ENDP

end main