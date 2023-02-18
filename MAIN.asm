       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  DECNUM,PRVTIM,DSPPOS            "
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
* Set to Text Mode
*
       LI   R0,>01D0
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
* Test Number-to-ASCII conversion
*
       LI   R0,17
       MOV  R0,@PRVTIM
       LI   R0,4*40+2
       MOV  R0,@DSPPOS
*
VDPLP  LI   R0,7
       A    @PRVTIM,R0
       MOV  R0,@PRVTIM
       BL   @NUMASC
*
       MOV  @DSPPOS,R0
       BL   @VDPADR
       LI   R0,DECNUM
       LI   R1,5
       BL   @VDPWRT
*
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