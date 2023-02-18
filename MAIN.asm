       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  DECNUM,PRVTIM,DSPPOS,CURINT     "
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP

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
* Init Timer
*
       BL   @INTTIM 
*
* Display CRU ticks for 60 VDP interrupts
*
       LI   R0,17
       MOV  R0,@PRVTIM
       LI   R0,4*40+2
       MOV  R0,@DSPPOS
       CLR  @CURINT
*
* Record CRU Timer value
       BL   @GETTIM
       MOV  R2,@PRVTIM
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
* Display ticks since last interrupt
       BL   @GETTIM
       MOV  @PRVTIM,R0
       S    R2,R0
       MOV  R2,@PRVTIM
       ANDI R0,>3FFF
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

*
* Private Method:
* Initialize Timer
*
INTTIM 
       CLR  R12         CRU base of the TMS9901 
       SBO  0           Enter timer mode 
       LI   R1,>3FFF    Maximum value
       INCT R12         Address of bit 1 
       LDCR R1,14       Load value 
       DECT R12         There is a faster way (see http://www.nouspikel.com/ti99/titechpages.htm) 
       SBZ  0           Exit clock mode, start decrementer 
       RT

*
* Private Method:
* Get Time from CRU
* Output: R2
*
GETTIM CLR  R12 
       SBO  0           Enter timer mode 
       STCR R2,15       Read current value (plus mode bit)
       SBZ  0
       SRL  R2,1        Get rid of mode bit
       ANDI R2,>3FFF
       RT