 lst off

 org $300

*
* loresshow:0C00.0FFF ($400)
* framedata:1000.6BFF ($5C00)
*
* buffer18 :6C00.7DFF ($1200 one track)
* rw18.d000:7E00.82FF ($500 moved to aux ramcard)
*

BbundID = $AD

loresshow = $c00
buffer18 = $6c00

rw18 = $d000
rw18temp = $7e00

slot = $FD
track = $FE
lastrack = $FF

startrack = 12 ;last 6 sectors here

* 13,14,15,16,17 (5 full tracks here)

errcode = 0

start jsr $e74c ;get slot#
 txa
 asl
 asl
 asl
 asl

 sta $C009 ;aux zpage, ramcard
 sta slot

 bit $C083
 bit $C083

* Move rw18 to its home

 ldx #>rw18temp
 ldy #>rw18
 lda #5
 jsr movedata

* Now we can use rw18

 jsr rw18
 db 7,BbundID

 jsr rw18
 db 0,5,1 ;drive on

 jsr rw18 ;seek to startrack
 db 2,1,startrack

* handle special track with

 jsr rw18
 db 3 ;read in original data
 db >buffer18
 lda #1
 bcs :error

* update last 6 sectors

 ldx #>loresshow
 ldy #>buffer18+$C00
 lda #6
 jsr movedata

* write it back out

 jsr rw18
 db 5 ;writesequ
 db >buffer18
 lda #2
 bcs :error

* write out rest of data...

 lda #>loresshow+$600
:wloop sta :buf

 inc track

 jsr rw18
 db 5 ;writesequ
:buf db $11
 lda #2
 bcs :error

 lda :buf
 adc #$12
 cmp #>loresshow+$600+{5*$1200}
 bne :wloop

 lda #0

:error pha
 jsr rw18
 db 1 ;drive off
 pla

 sta $C008
 bit $C081
 sta errcode
 rts

*------------------------------------------------- movedata
*
* Move data: x:source, y:dest, a:length
*

movedata stx :src+2
 sty :dst+2
 tax

 ldy #0
:loop
:src lda $1100,y
:dst sta $1100,y
 iny
 bne :loop

 inc :src+2
 inc :dst+2

 dex
 bne :loop

 rts

*------------------------------------------------- EOF
