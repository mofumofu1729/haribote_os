; hello-os
; TAB = 4

	ORG	0x7c00

; プログラム本体

entry:
	MOV	AX, 0
	MOV	SS, AX
	MOV	SP, 0x7c00
	MOV	DS, AX
	MOV	ES, AX

	MOV	SI, msg
putloop:
	MOV	AL, [SI]
	ADD	SI, 1
	CMP	AL, 0
	JE	fin
	MOV	AH, 0x0e	; 1文字表示
	MOV	BX, 15		; カラーコード
	INT	0x10		; ビデオBIOS呼びだし
	JMP	putloop
fin:
	HLT
	JMP	fin

; メッセージ部分
msg:	
	DB	0x0a, 0x0a	; 改行を二つ
	DB	"hello, world"
	DB	0x0a
	DB	0

