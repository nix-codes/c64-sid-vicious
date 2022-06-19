; =============================================================================
; Definitions
; =============================================================================

; -----------------------------------------------------------------
; our virtual 16-bit registers in the zero page
; -----------------------------------------------------------------
r0                  = $02
r1                  = $04
r2                  = $06
r3                  = $08
r4                  = $0a


; -----------------------------------------------------------------
; memory map
; -----------------------------------------------------------------
ram_color_line_1    = $d800
ram_color_line_2    = ram_color_line_1 + (40 * 1)
ram_color_line_3    = ram_color_line_1 + (40 * 2)
ram_color_line_4    = ram_color_line_1 + (40 * 3)
ram_color_line_5    = ram_color_line_1 + (40 * 4)
ram_color_line_6    = ram_color_line_1 + (40 * 5)
ram_color_line_7    = ram_color_line_1 + (40 * 6)
ram_color_line_8    = ram_color_line_1 + (40 * 7)
ram_color_line_9    = ram_color_line_1 + (40 * 8)
ram_color_line_10   = ram_color_line_1 + (40 * 9)
ram_color_line_11   = ram_color_line_1 + (40 *10)
ram_color_line_12   = ram_color_line_1 + (40 *11)
ram_color_line_13   = ram_color_line_1 + (40 *12)
ram_color_line_14   = ram_color_line_1 + (40 *13)
ram_color_line_15   = ram_color_line_1 + (40 *14)
ram_color_line_16   = ram_color_line_1 + (40 *15)
ram_color_line_17   = ram_color_line_1 + (40 *16)
ram_color_line_18   = ram_color_line_1 + (40 *17)
ram_color_line_19   = ram_color_line_1 + (40 *18)
ram_color_line_20   = ram_color_line_1 + (40 *19)
ram_color_line_21   = ram_color_line_1 + (40 *20)
ram_color_line_22   = ram_color_line_1 + (40 *21)
ram_color_line_23   = ram_color_line_1 + (40 *22)
ram_color_line_24   = ram_color_line_1 + (40 *23)
ram_color_line_25   = ram_color_line_1 + (40 *24)

; -----------------------------------------------------------------
; Kernal routines used
; -----------------------------------------------------------------
k_clear_screen      = $e544
k_chrout            = $ffd2                            ; Kernal routine to output a single character (typically to the screen)



; -----------------------------------------------------------------
; General macros
; -----------------------------------------------------------------

; -----------------------------------------------------------------
; load_addr: loads a given address into a given Rx register.
;
; parameters:
;              1: the Rx register to use
;              2: the address to store in the Rx register provided in 1
; -----------------------------------------------------------------
defm                load_addr
                    pha
                    lda       #</2                     
                    sta       /1                       
                    lda       #>/2                     
                    sta       /1+1                     
                    pla
endm


; -----------------------------------------------------------------
; jsr_rx: jumps to a subroutine whose address is given in an Rx register.
;
; parameters:
;              1: Rx register containing the address
; destroys:
;             R3
; -----------------------------------------------------------------
defm                jsr_rx
                    sta       r3                       ; save A, as we'll need to use it
                    lda       #>@callback_return-1     ; put the callback return address on the stack
                    pha                                ; since we use RTS for this trick, address needs to...
                    lda       #<@callback_return-1     ; ...be decremented by 1. MSB needs to be pushed first.
                    pha

                    lda       /1+1                     ; by convention the function pointer will be passed
                    pha                                ; in an Rx register
                    lda       /1                       
                    pha

                    lda       r3                       ; restore A
                    rts                                ; trick the processor to call the function by using RTS
@callback_return
endm


; -----------------------------------------------------------------
; print_nl: Prints a new line in the current cursor position.
;
;
; destroys:
;            A
; -----------------------------------------------------------------
defm                print_nl
                    lda       #$0d                     
                    jsr       k_chrout                 
endm





; =============================================================================
; BASIC loader:
; 10 SYS (4096)
; =============================================================================
*=$0801
                    byte      $0E, $08, $0A, $00, $9E, $20, $28
                    byte      $34, $30, $39, $36, $29, $00, $00, $00


; =============================================================================
; Main
; =============================================================================
*=$1000
                    jsr       k_clear_screen           
                    jsr       init_raster_handler      
                    jsr       install_raster_irq       

                    load_addr r0,credits_text_1        
                    jsr       print_lines              
                    ldx       #50                      
                    jsr       wait_long                

                    load_addr r0,credits_text_2        
                    jsr       print_lines              
                    ldx       #50                      
                    jsr       wait_long                

                    load_addr r0,credits_text_3        
                    jsr       print_lines              

                    jmp       *                        




; -----------------------------------------------------------------
; install_raster_irq: Installs our custom raster routine for performing
;                     color cycling.
; -----------------------------------------------------------------
install_raster_irq
                    sei                                ; set interrupt disable flag

                    ldy       #$7f                     ; $7f = %01111111
                    sty       $dc0d                    ; Turn off CIAs Timer interrupts ($7f = %01111111)
                    sty       $dd0d                    ; Turn off CIAs Timer interrupts ($7f = %01111111)
                    lda       $dc0d                    ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
                    lda       $dd0d                    ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed

                    lda       #$01                     ; Set Interrupt Request Mask...
                    sta       $d01a                    ; ...we want IRQ by Rasterbeam (%00000001)

                    lda       $d011                    ; Bit#0 of $d011 indicates if we have passed line 255 on the screen
                    and       #$7f                     ; it is basically the 9th Bit for $d012
                    sta       $d011                    ; we need to make sure it is set to zero

                    lda       #<raster_handler         ; point IRQ Vector to our custom irq routine
                    ldx       #>raster_handler         
                    sta       $314                     ; store in $314/$315
                    stx       $315                     

                    lda       #$00                     ; trigger first interrupt at row zero
                    sta       $d012                    

                    cli                                ; clear interrupt disable flag
                    rts



; -----------------------------------------------------------------
; init_raster_handler: initialize our raster handler routine
; -----------------------------------------------------------------
init_raster_handler
                    lda       #cycle_color_seq_1_len - 1; starting index for color seq 1
                    sta       r1                        ; we store it on the LSB of R1
                    lda       #cycle_color_seq_2_len - 1; starting index for color seq 2
                    sta       r1+1                      ; we store it on the MSB of R1
                    rts


; -----------------------------------------------------------------
; raster_handler: Performs color cycling on the screen.
; -----------------------------------------------------------------
raster_handler      dec       $d019                    ; acknowledge IRQ / clear register for next interrupt
                    jsr       perform_color_cycling    
@exit               jmp       $ea81                    ; return to kernel interrupt routine






; -----------------------------------------------------------------
; perform_color_cycling:
; this routine does the actual job of cycling the colors on the screen.
;
; destroys:
;            R2
; -----------------------------------------------------------------
perform_color_cycling
                    load_addr r2,paint_lines_left_cycle-1
                    jsr       cycle_left               

                    load_addr r2,paint_lines_right_cycle-1
                    jsr       cycle_right              
                    rts


; -----------------------------------------------------------------
; paint_lines_left_cycle:
; Changes the color of characters in a given column for the lines
; that correspond to the text that we are color cycling to the left.
;
; receives:
;            A: color to use
;            X: column index
; -----------------------------------------------------------------
paint_lines_left_cycle
                    sta       ram_color_line_1 - 1,x
                    sta       ram_color_line_2 - 1,x
                    sta       ram_color_line_3 - 1,x
                    sta       ram_color_line_4 - 1,x
                    sta       ram_color_line_5 - 1,x
                    sta       ram_color_line_6 - 1,x
                    sta       ram_color_line_7 - 1,x
                    sta       ram_color_line_21 - 1,x
                    sta       ram_color_line_22 - 1,x
                    sta       ram_color_line_23 - 1,x
                    sta       ram_color_line_24 - 1,x
                    rts

; -----------------------------------------------------------------
; paint_lines_right_cycle:
; Changes the color of characters in a given column for the lines
; that correspond to the text that we are color cycling to the right.
;
; receives:
;            A: color to use
;            X: column index
; -----------------------------------------------------------------
paint_lines_right_cycle
                    sta       ram_color_line_9 - 1,x
                    sta       ram_color_line_10 - 1,x
                    sta       ram_color_line_11 - 1,x
                    sta       ram_color_line_12 - 1,x
                    sta       ram_color_line_13 - 1,x
                    sta       ram_color_line_14 - 1,x
                    sta       ram_color_line_15 - 1,x
                    sta       ram_color_line_16 - 1,x
                    sta       ram_color_line_17 - 1,x
                    sta       ram_color_line_18 - 1,x
                    rts

; -----------------------------------------------------------------
; cycle_left: performs "color cycling" to the left.
;             Treats cycle_color_seq_1 as a circular array. Picks the next
;             color in the sequence and calls a provided callback function
;             with that color for each of the 40 columns.
;
; receives:
;            R1: MSB: the current index for the 2nd color cycle sequence array.
;            R2: address of a callback routine that will use the current color.
;                This routine will receive the color in the A register and the
;                column index in the X register
; returns:
;            R1: the next index in the circular array of the color sequence.
; destroys:
;             A, X
; -----------------------------------------------------------------
cycle_left
                    ldx       #40                      ; we'll iterate 40 columns from right to left
                    ldy       r1+0                     ; fetch current starting color index from LSB of R1
cycle_left_loop
                    lda       cycle_color_seq_1,y      
                    jsr_rx    r2                       

                    prev_circ_idx #cycle_color_seq_1_len   
                    dex
                    bne       cycle_left_loop          

                    ldy       r1+0                       ; in the next interrupt, we want to start with...
                    next_circ_idx #cycle_color_seq_1_len ; ... the next color in the sequence, ...
                    sty       r1+0                       ; ... so we save this index in the LSB of R1

                    rts



; -----------------------------------------------------------------
; cycle_right: performs "color cycling" to the right
;             Treats cycle_color_seq_2 as a circular array. Picks the previous
;             color in the sequence and calls a provided callback function with
;             that color for each of the 40 columns.
;
; receives:
;            R1: MSB: the current index for the 2nd color cycle sequence array.
;            R2: address of a callback routine that will use the current color.
;                This routine will receive the color in the A register and the
;                column index in the X register.
; returns:
;            R1: the next index in the circular array of the color sequence.
; destroys:
;             A, X
; -----------------------------------------------------------------
cycle_right
                    ldx       #40                      ; we'll iterate 40 columns from right to left
                    ldy       r1+1                     ; fetch current starting color index from LSB of R1
cycle_right_loop
                    lda       cycle_color_seq_2,y      
                    jsr_rx    r2                       

                    prev_circ_idx #cycle_color_seq_2_len   
                    dex
                    bne       cycle_right_loop         

                    ldy       r1+1                         ; in the next interrupt, we want to start with...
                    prev_circ_idx #cycle_color_seq_2_len   ; ... the previous color in the sequence, ...
                    sty       r1+1                         ; ... so we save this index in the MSB of R1

                    rts


; -----------------------------------------------------------------
; macro: next_circ_idx
;
; Obtains the next index to Y in a circular array.
; Basically increments Y, except when Y is equal to the array size, in which
; case it will set it to 0.
;
; parameters:
;              1: length of the array
;
; returns:
;              Y: the next array index
; -----------------------------------------------------------------
defm                next_circ_idx
                    iny
                    cpy       #/1                      
                    bne       @exit                    
                    ldy       #0                       
@exit
endm



; -----------------------------------------------------------------
; macro: prev_circ_idx
;
; Obtains the previous index to Y in a circular array.
; Basically decrements Y, except when Y is zero, in which case it will set it
; to the array length.
;
; parameters:
;              1: length of the array
;
; returns:
;              Y: the previous array index
; -----------------------------------------------------------------
defm                prev_circ_idx
                    cpy       #0                       
                    bne       @exit                    
                    ldy       #/1                      
@exit               dey
endm



; -----------------------------------------------------------------
; print_lines: Prints a series of text lines starting on the current cursor
;              position. A small wait is performed between each line.
;              Strings must be null-terminated and a double 0-byte
;              indicates the end of all lines.
;
;
; receives:
;            R0: address of the first string
; returns:
;             Y: length of the string
; destroys:
;             A, X, R0
; -----------------------------------------------------------------
print_lines
@check_end          ldy       #0                       ; load address of the first text line
                    lda       (r0),y                   
                    bne       @print_line              
                    iny
                    lda       (r0),y                   
                    beq       @exit                    
@print_line
                    jsr       print                    
                    print_nl
                    iny                                ; Y contains the line length; we add 1 for the null terminator
                    tya
                    jsr       add_r0_a                 ; move the pointer to the next line
                    ldx       #40                      
                    jsr       wait_short               
                    jmp       @check_end               
@exit
                    rts


; -----------------------------------------------------------------
; print: Prints a null-terminated string in the current cursor position.
;
;
; receives:
;            R0: address of the string
; returns:
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
 


; -----------------------------------------------------------------
; add_r0_a: Adds the accumulator to the value in R0.
;
;
; receives:
;            R0: 16-bit number to add
;             A: 8-bit number to add to R0
; returns:
;            R0: result of the sum
; destroys:
;             A
; -----------------------------------------------------------------
add_r0_a            clc
                    adc       r0                       
                    sta       r0                       ; store sum of LSBs

                    lda       r0+1                     
                    adc       #$00                     
                    sta       r0+1                     
                    rts


; -----------------------------------------------------------------
; wait: dirty hacky routine to wait some time wasting cpu cycles.
;
;
; receives:
;            X: number of loops. Each loop is a call to wait_short set for
;               256 loops (65536 iterations). This allows up to
;               256 * 65536 = 16777216 iterations.
; destroys:
;            A, X, Y
; -----------------------------------------------------------------
wait_long
                    txa                                ; save the parameter X
                    pha
                    ldx       #$ff                     
@loop               jsr       wait_short
                    pla                                ; restore X and decrement it before saving it again
                    tax
                    dex
                    txa
                    pha
                    bne       @loop                    
                    pla
                    rts


; -----------------------------------------------------------------
; wait: dirty hacky routine to wait some time wasting cpu cycles.
;
;
; receives:
;            X: number of loops. Each loop does 256 iterations, so this
;               allows up to 256 * 256 = 65536 iterations.
; destroys:
;            X, Y
; -----------------------------------------------------------------
wait_short          ldy       #$ff
@loop               dey
                    bne       @loop                    
                    ldy       #$ff                     
                    dex
                    bne       @loop                    
                    rts



; =============================================================================
; Data
; =============================================================================
cycle_color_seq_1_len = 40
cycle_color_seq_1   byte      $09, $09, $02, $02, $08, $08, $0a, $0a, $0f, $0f
                    byte      $07, $07, $01, $01, $01, $01, $01, $01, $01, $01
                    byte      $01, $01, $01, $01, $01, $01, $01, $01, $07, $07
                    byte      $0f, $0f, $0a, $0a, $08, $08, $02, $02, $09, $09

cycle_color_seq_2_len = 30
cycle_color_seq_2
                    byte      $0e, $0e, $05, $05, $07, $07, $03, $03, $0d, $0d
                    byte      $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
                    byte      $0d, $0d, $03, $03, $07, $07, $05, $05, $0e, $0e


credits_text_1
                    text      117,100,100,100,100,100,100,100,105,0
                    text      98," video ",98,0
                    text      106,102,102,102,102,102,102,102,107,0
                    text      "editing+coding: 80coder (nix), jun 2022",0
                    text      "       concept: 80coder (nix), jul 2004",0
                    text      "scrolling pics: gerd jansen, 2009",0
                    text      " ", 0
                    text      " ", 0
                    byte      0,0

credits_text_2
                    text      117,100,100,100,100,100,100,100,100,100,100
                    text      100,100,100,100,100,100,100,105,0
                    text      98," main tools used ",98,0
                    text      106,102,102,102,102,102,102,102,102,102,102
                    text      102,102,102,102,102,102,102,107,0
                    text      122," sidplay2 - a. lorentzon / h. pedersen" ,0
                    text      122," vice emulator",0
                    text      122," cbm prg studio - a. jordison",0
                    text      122," dir master (style64)",0
                    text      122," dir master [c64] - wim taymans",0
                    text      122," ffmpeg",0
                    text      122," vsdc video editor + gimp + audacity",0
                    text      " ", 0
                    text      " ", 0
                    byte      0,0

credits_text_3
                    text      117,100,100,100,100,100,100,100,100,100,100
                    text      100,100,100,100,100,100,105,0
                    text      98," special cheers ",98,0
                    text      106,102,102,102,102,102,102,102,102,102,102
                    text      102,102,102,102,102,102,107,0
                    text      "auro, btu, garkanoid, maxbass, mo",0
                    byte      0,0
