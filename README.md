# Minimal-OS-Kernel
This is a simple bootloader and kernel written in Assembly and C.
The project is not finished and it is ongoing.

## Files Overview

- `boot.asm` - The bootloader, written in assembly, which prints a character using BIOS interrupts.
- `kernel.c` - A minimal kernel written in C.
- `linker.ld` - Linker script to correctly place sections in memory.
- `Makefile` - Automates the build process.

## Requirements

Ensure you have the following installed:

- `nasm` (Assembler for bootloader)
- `gcc` (C compiler)
- `ld` (GNU linker)
- `qemu` (Emulator for testing)

## Installation on Debian-based systems:
```
sudo apt update
sudo apt install nasm gcc qemu-system-x86 build-essential
```

## Building the Kernel
Run the following command to compile and link the kernel:
```
make
```
This will generate kernel.bin, which is the final bootable binary.

## Running the Kernel in QEMU
To test the kernel in QEMU, run:
```
make run
```
If successful, you should see the letter `A` printed on the screen.

## Clean the Build
To remove compiled files:
```
make clean
```
## Future Improvements [Soon]
- Implement basic memory management.
