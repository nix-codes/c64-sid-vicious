; =============================================================================
; Definitions
; =============================================================================

; -----------------------------------------------------------------
; Kernal routines used
; -----------------------------------------------------------------
k_chrout            = $ffd2                            ; Kernal routine to output a single character (typically to the screen)

; -----------------------------------------------------------------
; our virtual 16-bit registers in the zero page
; -----------------------------------------------------------------
r0                  = $fb
r1                  = $fd

; -----------------------------------------------------------------
; General macros
; -----------------------------------------------------------------

; -----------------------------------------------------------------
; load_addr: loads an address into an Rx register
;
; parameters:
;   1: Rx register
;   2: the address to store in the register
; -----------------------------------------------------------------
defm                load_addr
                    pha
                    lda       #</2                     
                    sta       /1                       
                    lda       #>/2                     
                    sta       /1+1                     
                    pla
endm



; =============================================================================
; BASIC loader:
; 1 SYS4096
; which will load our main program at address $1000 (4096)
; =============================================================================
*= $0801                                          ; BASIC memory start address
                    byte      $0b,$08             ; pointer to next instruction line: $080b
                    byte      1,0                 ; 1
                    byte      $9e                 ; SYS
                    byte      "4096",0            ; 4096
                    byte      0,0                 ; end-of-program marker



; =============================================================================
; Main
; =============================================================================
*=$1000
                    jsr       print_nl                 
                    load_addr r0,message               
                    jsr       print                    
                    jsr       create_loading_bars_effect


; -----------------------------------------------------------------
; create_loading_bars_effect: changes the border color multiple times per second,
;                             creating the typical "loading" effect.
; -----------------------------------------------------------------
create_loading_bars_effect
@loop               inc       $d020
repeat              150
                    nop
endrepeat
                    jmp       @loop                    




; -----------------------------------------------------------------
; print_nl: Prints a new line in the current cursor position.
;
; destroys:
;            A
; -----------------------------------------------------------------
print_nl            lda       #$0d
                    jsr       k_chrout                 
                    rts


; -----------------------------------------------------------------
; print: Prints a null-terminated string in the current cursor position.
;
; receives:
;            R0: address of the string
; returns :
;             Y: length of the string
; destroys:
;             A
; -----------------------------------------------------------------
print               ldy       #0
@read_char          lda       (r0),y
                    beq       @end                     
                    jsr       k_chrout                 
                    iny
                    jmp       @read_char               
@end                rts




; =============================================================================
; Data
; =============================================================================
message
                    text      "preparing audio and video clips...",0
