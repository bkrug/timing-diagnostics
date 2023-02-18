       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  DECNUM,PRVTIM,DSPPOS,CURINT     "
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP

********@*****@*********************@**************************
*--------------------------------------------------------------
* Cartridge header
*--------------------------------------------------------------
* Since this header is not absolutely positioned at >6000,
* it is important to include '-a ">6000"' in the xas99.py
* command when linking files into a cartridge.
       BYTE  >AA,1,1,0,0,0
       DATA  PROG1
       BYTE  0,0,0,0,0,0,0,0      
*
PROG1  DATA  0
       DATA  BEGIN
       BYTE  P1MSGE-P1MSG
P1MSG  TEXT  'TIMING DIAGNOSTIC'
P1MSGE
SPACE  TEXT  ' '
       EVEN
       
*
* Addresses
*
       COPY 'CPUADR.asm'
ROWLNG EQU  40

*
* Header Text
*
HDR   

*
* Runable code
*
BEGIN
       LWPI WS
       LI   R10,STACK
*
       LIMI 0
*
* Set to Text Mode
*
       LI   R0,>01F0
       BL   @VDPREG
       LI   R0,>07FD
       BL   @VDPREG       
*
* Variable initialization routines
*
       BL   @GROMCR              Copy pattern definitions from GROM to VRAM
*
* Display Header
*
       BL   @DSPINT
*
* Display CRU ticks for 60 VDP interrupts
*
       LI   R0,17
       MOV  R0,@PRVTIM
       LI   R0,4*40+2
       MOV  R0,@DSPPOS
       CLR  @CURINT
*
VDPLP
* Let R0 = most recently read VDP time
       MOVB @VINTTM,R0
* Turn on VDP interrupts
       LIMI 2
* Wait for VDP interupt
WAITLP CB   @VINTTM,R0
       JEQ  WAITLP
* Turn off interrupts so we can write to VDP
       LIMI 0
* Display current interrupt
       INC  @CURINT
       MOV  @CURINT,R0
       BL   @NUMASC
*
       MOV  @DSPPOS,R0
       BL   @VDPADR
       LI   R0,DECNUM
       AI   R0,3
       LI   R1,2
       BL   @VDPWRT
* Write space
       MOVB @SPACE,@VDPWD
       NOP
       MOVB @SPACE,@VDPWD
* Display meaningless number
       LI   R0,7
       A    @PRVTIM,R0
       MOV  R0,@PRVTIM
       BL   @NUMASC
*
       LI   R0,DECNUM
       LI   R1,5
       BL   @VDPWRT
* Move DSPPOS to next row
       MOV  @DSPPOS,R0
       AI   R0,ROWLNG
       CI   R0,24*40
       JL   VDP1
* Is this third column?
       CI   R0,24*40+26
       JH   JMP
* No, next Colum
       AI   R0,-20*40+13
       JMP  VDP1
VDP1   MOV  R0,@DSPPOS
       JMP  VDPLP
JMP    JMP  JMP
       END