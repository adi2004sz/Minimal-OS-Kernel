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

## How it Works

### 1. Bootloader ( `boot.asm` )
- Occupies the MBR (512 bytes).
- Uses BIOS interrupt `INT 13h` to read the second-stage bootloader from disk into memory (at 0x7E00).
- Sets up basic segment registers.
- Transfers control to the second-stage loader.

### 2. Second-Stage Loader ( `second_stage.asm` )
- Enables A20 line for access above 1MB.
- Loads `kernel.bin` from disk to memory (at 0x100000).
- Enters long mode by:
      - Setting up GDT
      - Enabling PAE and then long mode via CR0, CR4, and EFER MSRs
- Jumps to `kernel.asm`.

### 3. Kernel Entry ( `kernel.asm` )
- Entry point `_start` is defined here.
- Prepares the stack.

## How to run
- Compile everything using: `make`
- To emulate and test the kernel: `make run`


## Expected Output
The screen will clear, display a white text message, and render a colored box with the label "SUCCESS" in the center.

![Image](https://github.com/user-attachments/assets/cd9d417c-15ac-4136-97c7-2fe6d3cac3bf)

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
