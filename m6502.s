; These startup and serial I/O routines are a modified version
; of G. Searle's from 2013.
;
; They been altered to work with the R6551P
;
; I've also stumped out the necessary Kernel functions to get things running.
;
; This will run on a 6502 machine similar to the breadboard 6502 created by Ben
; Eater.  It expects:
;
;
;  RAM: 0000 - 3FFFF
;  I/O: 4000 - 7FFFF
;  ROM: 8000 - FFFFF
;
;
; In the I/O memory block the Rockwell R65C51P1 needs to be at address $5000.
; I've tested the following chips R6551AP, R65C51P2, R65C51P1 and the
; W65C51N6TPG.  The WDC version ; will need a different MONCOUT routine due to
; the hardward bug.
;
;
; -Jeremy English jhe@jeremyenglish.org
;

ACIA := $5000
ACIAData := ACIA+0
ACIAStatus := ACIA+1
ACIACmd := ACIA+2
ACIAControl := ACIA+3

.segment "IOHANDLER"
.org $FA00

m6502_main:

    ;; jhe: I don't have the irq line connected off of the uart.  So interrupts
    ;;      are turned off.  And you will not be able to reset from basic.
    lda #$1f            ; n-8-1 19200 baud
    sta ACIAControl
    lda #$0B            ; No parity, no echo, no interrupts.
    sta ACIACmd
    jsr COLD_START       ; Let's get started

TO_UPPER:
    cmp #$61
    bcs TU_CHK_Z
    rts
TU_CHK_Z:
    cmp #$7b
    bcc TU_ADJ_CASE
    rts
TU_ADJ_CASE:
    sec
    sbc #$20
    rts

MONCOUT:
	PHA
SerialOutWait:
	LDA	ACIAStatus      ;get status
    and #$10            ;mask transmit buffer status flag
	beq	SerialOutWait   ;loop until we've sent the char
	PLA                 ;restore A
	STA	ACIAData        ;send it
	RTS

MONRDKEY:
	LDA	ACIAStatus  ; get the status
	AND	#$08        ; is the receiver buffer full
	beq	MONRDKEY    ; wait for the input
	LDA	ACIAData    ; yes, get the character
    jsr TO_UPPER    ; I'm tired of forgetting to hit caps lock
	RTS

;; MONISCNTC:
;; 	JSR	MONRDKEY
;; 	BCC	NotCTRLC ; If no key pressed then exit
;; 	CMP	#3
;; 	BNE	NotCTRLC ; if CTRL-C not pressed then exit
;; 	SEC		; Carry set if control C pressed
;; 	RTS
;; NotCTRLC:
;; 	CLC		; Carry clear if control C not pressed
;; 	RTS
;; 

deadbeaf:
    rti

;; Nothing is implemented for logical files since the system does not have that
;; concept at this time.

;.org $FFC0 ;; OPEN
;;Open a logical file
.segment "OPEN"
rts

;.org $FFC3 ;; 
;;Close a logical file
;;I'm just returning since we do not have logical files
.segment "CLOSE"
rts

;.org $FFC6 ;; 
;;Open a channel for input
.segment "CHKIN"
rts

;.org $FFC9 ;; 
;;Open a channel for output
.segment "CHKOUT"
rts 

;.org $FFCC ;; 
;;Clear I/O channel
.segment "CLRCH"
rts

;.org $FFCF ;; 

;;Get a character from the input channel.  For this system the input channel
;;will always be the UART.

.segment "CHRIN"
jsr MONRDKEY
rts

;.org $FFD2
;;Outpt a character to a channel (the uart)
.segment "CHROUT"
jsr MONCOUT
rts

;.org $FFD5;; 
;;The system does not have any input devices yet
.segment "LOAD"
rts

;.org $FFD8;; 
;;The system does not have any output devices yet
.segment "SAVE"
rts

;.org $FFDB;; 
;.segment "VERIFY"
;rts

;.org $FFDE;; 
;;We don't really have any system commands
.segment "SYS"
rts

;.org $FFE1;; 
.segment "ISCNTC"
rts

;.org $FFE4;; 
;;Treat the same as CHRIN
.segment "GETIN"
jsr MONRDKEY
rts

;.org $FFE7;; 
;;Close all channels
.segment "CLALL"
rts

.segment "VECTS"
.org $FFFA
	.word	deadbeaf    ; NMI 
	.word	m6502_main	; RESET 
	.word	deadbeaf	; IRQ 

