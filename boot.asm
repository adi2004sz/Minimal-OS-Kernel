bits 16
org 0x7C00

_start:
    mov al, 0x41  ; Litera 'A'
    mov ah, 0x0E  ; BIOS teletype mode
    int 0x10      ; Apel BIOS pentru a afișa caracterul

    hlt

times 510 - ($ - $$) db 0  ; Padding până la 510 bytes
dw 0xAA55                  ; Boot sector signature
