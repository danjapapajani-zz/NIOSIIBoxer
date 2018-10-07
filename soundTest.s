.section .text

.equ AUDIO, 0xFF203040

#include wav file
SONG:
.incbin "priceIsRight.wav"

#used to store 32bits/sample
SAMPLE_SOUND:
    .align 2
    .skip 266276

.global _start

_start:

    #move location of audio core into r11
    movia r11, AUDIO

    #move location of song file into r8
    movia r9, SONG

    #move location of sampled sound into r10
    movia r10, SAMPLE_SOUND
    addi r10, r10, 4

    #load hald word sample of the song file
    ldh r12, 34(r9)
    #get data size in bytes
    ldw r13, 40(r9)
    #get first 1 bits of data
    ldb r14, 44(r9)

    #mov r9 to data
    addi r9, r9, 44


ACTIVATE_INTERRUPTS:

    #activate audio codec interrupts
    #write binary 10 into audio core for read interrupt
    #unsigned number allows interrupt enable for left and right FIFO
    movui r3, 0x2
    stwio r3, 0(r11)

    #make all bits 0 except 6th bit
    #enabling ctl3
    movui r3, 0x40
    wrctl ctl3, r3

######################################################
############                         #################
############      SOUND INTERRUPT    #################
############                         #################
######################################################
.section .exceptions, "ax"

ISR:

    #check if core caused an interrupt
    #check the 6th bit
    rdctl et, ctl4
    andi et, et, 0x40
    bne et, r0, WRITE_TO_CORE

br EXIT

WRITE_TO_CORE:

    #write to left and right channels
    ldw r19, 0(r9)
    stwio r19, 8(r11)
    stwio r19, 12(r11)
    addi r9, r9, 4

br EXIT

EXIT:
    subi ea, ea, 4
    eret
