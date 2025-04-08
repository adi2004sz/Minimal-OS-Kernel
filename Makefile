# Tools
ASM=nasm
DD=dd

# Targets
all: bootdisk.img

# Build first stage bootloader
boot.bin: boot.asm
	$(ASM) -f bin boot.asm -o boot.bin

# Build second stage bootloader
second_stage.bin: second_stage.asm
	$(ASM) -f bin second_stage.asm -o second_stage.bin

# Build kernel
kernel.bin: kernel.asm
	$(ASM) -f bin kernel.asm -o kernel.bin

# Create bootable disk image
bootdisk.img: boot.bin second_stage.bin kernel.bin
	# Create empty disk image (1MB)
	$(DD) if=/dev/zero of=bootdisk.img bs=512 count=2048
	# Write first stage bootloader at sector 0
	$(DD) if=boot.bin of=bootdisk.img conv=notrunc bs=512 count=1
	# Write second stage bootloader at sector 1
	$(DD) if=second_stage.bin of=bootdisk.img conv=notrunc bs=512 seek=1
	# Write kernel at sector 11
	$(DD) if=kernel.bin of=bootdisk.img conv=notrunc bs=512 seek=11

# Run in QEMU
run: bootdisk.img
	qemu-system-i386 -drive format=raw,file=bootdisk.img

# Debug with QEMU monitor
debug: bootdisk.img
	qemu-system-i386 -drive format=raw,file=bootdisk.img -monitor stdio

# Clean up
clean:
	rm -f *.bin *.img