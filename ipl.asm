; haribote-ipl
; TAB = 4

CYLS	EQU	10		; どこまで読み込むか

	ORG	0x7c00
	
; 標準的なFAT12フォーマットフロッピーディスクのための記述

	JMP	entry
	DB	0x90
	DB	"HARIBOTE"	; ブートセクタの名前
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
	DB	"HARIBOTEOS "	; ディスクの名前(11バイト)
	DB	"FAT12   "	; フォーマットの名前(8バイト)
	TIMES	18	DB	0

; プログラム本体

entry:
	MOV	AX, 0		; レジスタ初期化
	MOV	SS, AX
	MOV	SP, 0x7c00
	MOV	DS, AX

; ディスクを読む

	MOV	AX, 0x0820
	MOV	ES, AX
	MOV	CH, 0		; シリンダ0
	MOV	DH, 0		; ヘッダ0
	MOV	CL, 2		; セクタ2
readloop:
	MOV	SI, 0		; 失敗回数を数えるレジスタ
retry:
	MOV	AH, 0x02	; ディスク読み込み
	MOV	AL, 1		; 1セクタ
	MOV	BX, 0
	MOV	DL, 0x00	; Aドライブ
	INT	0x13		; ディスクBIOS呼び出し
	JNC	next		; エラーが起きなければnextへ
	ADD	SI, 1		; SIに1を足す
	CMP	SI, 5		; SIを5と比較
	JAE	error		; SI >= 5 だったらerrorへ
	MOV	AH, 0x00
	MOV	DL, 0x00	; Aドライブ
	INT	0x13		; ドライブのリセット
	JMP	retry
next:
	MOV	AX, ES
	ADD	AX, 0x0020	; アドレスを0x200進める
	MOV	ES, AX
	ADD	CL, 1
	CMP	CL, 18
	JBE	readloop	; CL <= 10 だったらreadloopへ
	MOV	CL, 1
	ADD	DH, 1
	CMP	DH, 2
	JB	readloop	; DH < 2 だったらreadloopへ
	MOV	DH, 0
	ADD	CH, 1
	CMP	CH, CYLS
	JB	readloop	; CH < CYLS だったらreadloopへ
	
; 読み終わったけどとりあえずやることないので寝る

fin:
	HLT
	JMP	fin

error:
	MOV	SI, msg
putloop:
	MOV	AL, [SI]
	ADD	SI, 1
	CMP	AL, 0
	JE	fin
	MOV	AH, 0x0e
	MOV	BX, 15
	INT	0x10		; ビデオBIOS呼び出し
	JMP	putloop
msg:
	DB	0x0a, 0x0a	; 改行を2つ
	DB	"load error"
	DB	0x0a
	DB	0

	TIMES	0x7dfe-0x7c00-($-$$)	DB	0

	DB	0x55, 0xaa
