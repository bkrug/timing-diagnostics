       DEF  DSPINT,DSPENV
*
       REF  VDPADR,VDPWRT                   Ref from VDP

HEAD1  TEXT 'Below is the number of CRU ticks '
       TEXT 'per VDP interrupt.'
HEAD2  TEXT 'Expect 782 ticks in 60hz region and '
       TEXT '938 ticks in 50hz region.'
HEAD0
       EVEN

ROWLNG EQU  40

* Header above each menu
MHEAD  DATA HEAD1,HEAD2
MHEAD0 DATA HEAD0

       COPY 'CPUADR.asm'

*
* Public Method:
* Write key selections to screen
*
DSPINT
       DECT R10
       MOV  R11,*R10
* Clear screen
       CLR  R0
       BL   @VDPADR
       LI   R1,24*40
       LI   R2,>2000
DSP1   MOVB R2,@VDPWD
       DEC  R1
       JNE  DSP1
* Let R2 = List of lines to display
* Let R3 = End of list of lines
* Let R4 = position of next line on screen
       LI   R2,MHEAD
       LI   R3,MHEAD0
       LI   R4,2
       BL   @DSPMNU
*
       MOV  *R10+,R11
       RT

*
* Private Method:
* Display a menu or menu header
*
DSPMNU DECT R10
       MOV  R11,*R10
*
       AI   R4,-ROWLNG
* Set next position
MSGLP  AI   R4,ROWLNG
       MOV  R4,R0
       BL   @VDPADR
* Write next message
       MOV  *R2+,R0
       MOV  *R2,R1
       S    R0,R1
       BL   @VDPWRT
* Did we reach end of menu?
       C    R2,R3
       JL   MSGLP
* Yes, return
       MOV  *R10+,R11
       RT