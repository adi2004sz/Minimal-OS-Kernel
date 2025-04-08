;Second stage bootloader (16-bit to 32-bit)
[BITS 16]               ; 16-bit mode
[ORG 0x7E00]            ; Second stage starts at 0x7E00

second_stage_start:
    ; Print message
    mov si, msg_second_stage
    call print_string

    ; Save boot drive
    mov [BOOT_DRIVE], dl

    ; Load kernel from disk
    mov si, msg_loading_kernel
    call print_string
    
    ; Reset disk
    xor ax, ax
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error
    
    ; Load kernel - we will put it at physical address 0x10000 (segment 0x1000)
    mov ax, 0x1000
    mov es, ax
    xor bx, bx          ; ES:BX = 0x1000:0x0000 = physical 0x10000
    mov ah, 0x02        ; BIOS read sector function
    mov al, 20          ; Number of sectors to read
    mov ch, 0           ; Cylinder number
    mov cl, 12          ; Sector number (1-based, sector 12)
    mov dh, 0           ; Head number
    mov dl, [BOOT_DRIVE] ; Drive number
    int 0x13            ; Call BIOS
    jc disk_error       ; Jump if disk read error
    
    ; Print success message
    mov si, msg_kernel_loaded
    call print_string
    
    ; Prepare for protected mode
    cli                 ; Disable interrupts
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Clear prefetch queue and far jump to 32-bit code
    jmp CODE_SEG:protected_mode_start

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $               ;loop


; Input: SI = pointer to string
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

; GDT (Global Descriptor Table)
gdt_start:
    ; Null descriptor
    dq 0                ; 8 bytes of zeros

gdt_code:               ; Code segment descriptor
    dw 0xFFFF           ; Segment limit (bits 0-15)
    dw 0                ; Base address (bits 0-15)
    db 0                ; Base address (bits 16-23)
    db 10011010b        ; Access byte: Present, Ring 0, Code segment, Execute/Read
    db 11001111b        ; Flags (4 bits) + Limit (bits 16-19): Granularity 4KB, 32-bit
    db 0                ; Base address (bits 24-31)

gdt_data:               ; Data segment descriptor
    dw 0xFFFF           ; Segment limit (bits 0-15)
    dw 0                ; Base address (bits 0-15)
    db 0                ; Base address (bits 16-23)
    db 10010010b        ; Access byte: Present, Ring 0, Data segment, Read/Write
    db 11001111b        ; Flags (4 bits) + Limit (bits 16-19): Granularity 4KB, 32-bit
    db 0                ; Base address (bits 24-31)

gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT size (limit)
    dd gdt_start              ; GDT address

; Define segment selectors
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Data
BOOT_DRIVE db 0
msg_second_stage db 'Second stage loaded successfully!', 13, 10, 0
msg_loading_kernel db 'Loading kernel...', 13, 10, 0
msg_kernel_loaded db 'Kernel loaded successfully!', 13, 10, 0
msg_disk_error db 'Disk read error!', 13, 10, 0

; 32-bit protected mode code
[BITS 32]
protected_mode_start:
    ; Setup segment registers for 32-bit protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Setup stack
    mov esp, 0x90000
    
    ; Clear the screen first
    call clear_screen
    
    ; Print message to show we're in protected mode
    mov esi, msg_protected_mode
    call print_string_pm
    
    ; Jump to the kernel at 0x10000
    call 0x10000

    ; If kernel returns, halt
    cli
    hlt

; Function: clear_screen
; Clears the screen in video memory
clear_screen:
    push edi
    push eax
    push ecx
    
    mov edi, 0xB8000    ; Video memory address
    mov eax, 0x07200720 ; Space character with attribute (0x07)
    mov ecx, 80*25/2    ; Screen size (80x25) / 2 (for dword)
    rep stosd           ; Repeat for the entire screen
    
    pop ecx
    pop eax
    pop edi
    ret

; Function: print_string_pm
; Input: ESI = pointer to string
print_string_pm:
    push eax
    push edi
    
    mov edi, 0xB8000    ; Video memory address
    
.loop:
    lodsb               ; Load byte at ESI into AL and increment ESI
    test al, al         ; Check if end of string
    jz .done            ; If zero, we're done
    mov ah, 0x0F        ; White on black attribute
    mov [edi], ax       ; Write to video memory
    add edi, 2          ; Next character position
    jmp .loop           ; Repeat
    
.done:
    pop edi
    pop eax
    ret

; 32-bit message data
msg_protected_mode db 'Entered 32-bit protected mode, loading kernel...', 0