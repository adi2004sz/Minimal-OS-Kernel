;First stage bootloader (16-bit)
[BITS 16]               ; 16-bit mode
[ORG 0x7C00]            ; Code starts at 0x7C00 (standard boot sector location)

; Setup segments
    cli                 ; Disable interrupts
    xor ax, ax
    mov ds, ax          ; Data segment = 0
    mov es, ax          ; Extra segment = 0
    mov ss, ax          ; Stack segment = 0
    mov sp, 0x7C00      ; Stack pointer at 0x7C00

    sti                 ; Enable interrupts

    mov [BOOT_DRIVE], dl ; Save boot drive number

    ; Print booting message
    mov si, msg_boot
    call print_string

    ; Reset disk system
    xor ax, ax
    int 0x13
    jc disk_error


    ; --> Load second stage bootloader
    mov bx, SECOND_STAGE ; Destination address
    mov ah, 0x02        ; BIOS read sector function
    mov al, 10          ; Number of sectors to read
    mov ch, 0           ; Cylinder number
    mov cl, 2           ; Sector number (1-based, sector 2)
    mov dh, 0           ; Head number
    mov dl, [BOOT_DRIVE] ; Drive number
    int 0x13            ; Call BIOS
    jc disk_error       ; Jump if disk read error

    ; Jump to second stage
    mov si, msg_loading_second
    call print_string
    jmp SECOND_STAGE    ; Jump

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $               ; loop

; (Input: SI = pointer to string)
print_string:
    pusha               ; Save all registers
.loop:
    lodsb               ; Load byte at SI into AL and increment SI
    or al, al           ; Check if AL is 0 (end of string)
    jz .done            ; If AL is 0, we're done
    mov ah, 0x0E        ; BIOS teletype function
    int 0x10            ; Call BIOS
    jmp .loop           ; Repeat for next character
.done:
    popa                ; Restore all registers
    ret

; Data
BOOT_DRIVE db 0
msg_boot db 'Booting first stage...', 13, 10, 0
msg_loading_second db 'Loading second stage...', 13, 10, 0
msg_disk_error db 'Disk read error!', 13, 10, 0


times 510-($-$$) db 0   ; Pad to 510 bytes
dw 0xAA55               ; Boot signature

; Second stage will be loaded here (next sector)
SECOND_STAGE equ 0x7E00