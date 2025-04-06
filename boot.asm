ORG 0x7C00
BITS 16

_start:
    jmp short start
    nop

; BIOS Parameter Block (BPB)
bpb:
    ; OEM identifier (8 bytes)
    db "MYBOOT  "
    ; Bytes per sector (2 bytes)
    dw 512
    ; Sectors per cluster (1 byte)
    db 1
    ; Reserved sectors (2 bytes)
    dw 1
    ; Number of FATs (1 byte)
    db 2
    ; Root directory entries (2 bytes)
    dw 224
    ; Total sectors (2 bytes)
    dw 2880
    ; Media descriptor type (1 byte)
    db 0xF0
    ; Sectors per FAT (2 bytes)
    dw 9
    ; Sectors per track (2 bytes)
    dw 18
    ; Heads per cylinder (2 bytes)
    dw 2
    ; Hidden sectors (4 bytes)
    dd 0
    ; Large sector count (4 bytes)
    dd 0

start:
    cli                ; Clear interrupts
    xor ax, ax         ; Zero out AX 
    mov ds, ax         
    mov es, ax         
    mov ss, ax         
    mov sp, 0x7C00     ; Set stack pointer to just below bootloader

    sti                ; Enable interrupts

    mov si, message    ; Load address of message into SI
    call print         
    jmp $              ; loop

print:
    lodsb              ; Load next byte from SI into AL
    cmp al, 0          ; Check
    je .done           ; If null terminator, exit
    call print_char    
    jmp print          ; Repeat for next character
.done:
    ret

print_char:
    mov ah, 0x0E       
    int 0x10           ; Call BIOS interrupt
    ret

message: db 'Hello World!', 0

times 510 - ($ - $$) db 0  ; Pad to 510 bytes
dw 0xAA55                   ; Boot signature