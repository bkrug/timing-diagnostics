       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  GROMCR                          Ref from GROM
       REF  DSPINT                          Ref from DISPLAY
       REF  VDPREG                          Ref from VDP

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
JMP    JMP  JMP
       END