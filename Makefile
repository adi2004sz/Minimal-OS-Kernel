# Tools
ASM = nasm
LD = ld
OBJCOPY = objcopy
GRUBMKRESCUE = grub-mkrescue
QEMU = qemu-system-x86_64

# File names
OUTPUT = kernel.bin
ISO = kernel.iso
ISO_DIR = iso
ISO_BOOT = $(ISO_DIR)/boot
GRUB_CFG = $(ISO_BOOT)/grub/grub.cfg

# Source files
BOOTLOADER = boot.asm
KERNEL = kernel.asm
OBJECTS = boot.o kernel.o

# Build all
all: $(OUTPUT)

# Assemble each file
%.o: %.asm
	$(ASM) -f elf64 $< -o $@

# Link everything into a binary
$(OUTPUT): $(OBJECTS)
	$(LD) -n -T linker.ld -o $@ $^ --oformat=binary

# Create bootable ISO with GRUB
iso: $(OUTPUT)
	mkdir -p $(ISO_BOOT)/grub
	cp $(OUTPUT) $(ISO_BOOT)
	echo 'set timeout=0' > $(GRUB_CFG)
	echo 'set default=0' >> $(GRUB_CFG)
	echo 'menuentry "My OS" {' >> $(GRUB_CFG)
	echo '  multiboot /boot/$(OUTPUT)' >> $(GRUB_CFG)
	echo '}' >> $(GRUB_CFG)
	$(GRUBMKRESCUE) -o $(ISO) $(ISO_DIR)

# Clean build files
clean:
	rm -f $(OBJECTS) $(OUTPUT) $(ISO)
	rm -rf $(ISO_DIR)

# Run in QEMU
run: $(ISO)
	$(QEMU) -cdrom $(ISO)
