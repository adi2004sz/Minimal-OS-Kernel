# Minimal-OS-Kernel
This is a x86 dual-stage bootloader that transitions from 16-bit real mode to 32-bit protected mode, and loads a simple kernel that writes a success message and renders a colorful box in VGA text mode.
The project is not finished and it is ongoing.

## Project Structure

Minimal-OS-Kernel/

├── boot.asm           # First stage bootloader (512 bytes, lives in MBR)

├── second_stage.asm   # Loads kernel, enters protected mode, and jumps to kernel

├── kernel.asm         # 32-bit protected mode kernel with VGA output

├── Makefile

└── README.md

## Expected Output
The screen will clear, display a white text message, and render a colored box with the label "SUCCESS" in the center.

## Concepts Covered
- 16-bit real mode bootloading
- BIOS disk and video interrupts (int 13h, int 10h)
- Transition to 32-bit protected mode
- Setting up GDT
- VGA text mode graphics
- Basic kernel execution

## Requirements

Ensure you have the following installed:

- `nasm` (Assembler for bootloader)
- `qemu` (Emulator for testing)
- `dd` or equivalent for creating floppy/hard disk images
- `ld` (GNU linker) [not yet necesssary]
- `gcc` (C compiler) [not yet necesssary]


## Future Improvements
- Transition the Kernal to C 
- Implement basic memory management.
