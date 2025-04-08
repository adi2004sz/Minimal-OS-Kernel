;Simple 32-bit kernel that displays a message
[BITS 32]           ; We're in 32-bit protected mode
[ORG 0x10000]       ; Our kernel is loaded at physical address 0x10000

_start:
    ; Setup registers (just to be safe)
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    
    ; Clear the screen
    call clear_screen
    
    ; Print our kernel message
    mov esi, msg_kernel
    mov edi, 0xB8000
    call print_string
    
    ; Draw a colorful box in the center of the screen
    call draw_box
    
    ; Infinite loop - halt the CPU
    jmp $

; Function: clear_screen
; Clears the screen in video memory
clear_screen:
    push edi
    push eax
    push ecx
    
    mov edi, 0xB8000    ; Video memory address
    mov eax, 0x07200720 ; Space character with attribute (black background, white text)
    mov ecx, 80*25/2    ; Screen size (80x25) / 2 (for dword)
    rep stosd           ; Repeat for the entire screen
    
    pop ecx
    pop eax
    pop edi
    ret

; Function: print_string
; Input: ESI = pointer to string, EDI = video memory position
print_string:
    push eax
    push edi
    
.loop:
    lodsb               ; Load byte at ESI into AL and increment ESI
    test al, al         ; Check if end of string
    jz .done            ; If zero, we are done
    mov ah, 0x0F        ; White on black attribute
    mov [edi], ax       ; Write to video memory
    add edi, 2          ; Next character position
    jmp .loop           ; Repeat
    
.done:
    pop edi
    pop eax
    ret


; Draws box in the center of the screen
draw_box:
    push eax
    push ebx
    push ecx
    push edx
    push edi
    
    ; Calculate the starting position for the box (center of screen)
    mov edi, 0xB8000            ; Video memory
    add edi, (12 * 80 + 35) * 2 ; Row 12, Column 35
    
    ; Draw top border
    mov ah, 0x1F                ; Blue background, white text
    mov al, '='                 ; Border character
    mov ecx, 10                 ; Box width
    
.top_border:
    mov [edi], ax
    add edi, 2
    loop .top_border
    
    ; Move to next row
    add edi, (80 - 10) * 2
    
    ; Draw middle rows with sides
    mov edx, 5                  ; Box height
    
.row:
    ; Left border
    mov ah, 0x2F                ; Green background, white text
    mov al, '|'                 ; Border character
    mov [edi], ax
    
    ; Middle space
    add edi, 2
    mov ah, 0x4F                ; Red background, white text
    mov al, ' '                 ; Space character
    mov ecx, 8                  ; Middle width
    
.middle:
    mov [edi], ax
    add edi, 2
    loop .middle
    
    ; Right border
    mov ah, 0x2F                ; Green background, white text
    mov al, '|'                 ; Border character
    mov [edi], ax
    
    ; Move to next row
    add edi, (80 - 9) * 2
    
    ; Decrease row count
    dec edx
    jnz .row
    
    ; Draw bottom border
    mov ah, 0x1F                ; Blue background, white text
    mov al, '='                 ; Border character
    mov ecx, 10                 ; Box width
    
.bottom_border:
    mov [edi], ax
    add edi, 2
    loop .bottom_border
    
    ; Add text inside the box (centered)
    mov edi, 0xB8000             ; Video memory
    add edi, (14 * 80 + 36) * 2  ; Position for text
    
    mov esi, msg_box
    
.print_box_text:
    lodsb
    test al, al
    jz .box_done
    
    mov ah, 0x4F                 ; Red background, white text
    mov [edi], ax
    add edi, 2
    jmp .print_box_text
    
.box_done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Data
msg_kernel db 'Kernel loaded successfully in 32-bit protected mode!', 0
msg_box db 'SUCCESS', 0

; Fill the rest of the kernel with zeros
times 10240-($-$$) db 0  ; Pad to 10KB