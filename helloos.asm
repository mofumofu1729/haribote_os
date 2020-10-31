; hello-os
; TAB = 4

	ORG	0x7c00
	
; 標準的なFAT12フォーマットフロッピーディスクのための記述

	JMP	entry
	DB	0x90
	DB	"HELLOIPL"	; ブートセクタの名前
	DW	512		; 1セクタの大きさ
	DB	1		; クラスタの大きさ
	DB	1		; FATがどこから始まるか
	DB	2		; FATの個数
	DW	224		; ルートディレクトリ領域の大きさ
	DW	2880		; このドライブの大きさ
	DW	0xf0		; メディアのタイプ
	DW	9		; FAT領域の長さ
	DW	18		; 1トラックに幾つのセクタがあるか
	DW	2		; ヘッドの数
	DD	0		; パーティションをつかっていないので0
	DD	2880		; このドライブの大きさをもう一度書く
	DB	0, 0, 0x29
	DD	0xffffffff	; (多分)ボリュームシリアル番号
	DB	"HELLO-OS   "	; ディスクの名前(11バイト)
	DB	"FAT12   "	; フォーマットの名前(8バイト)
	RESB	18
	
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

	RESB	0x1fe-($-$$)

	DB	0x55, 0xaa

; 以下はブートセクタ以外の部分の記述

	DB	0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
	RESB	4600
	DB	0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
	RESB	1469432
