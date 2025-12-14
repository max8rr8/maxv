MEMORY {
  FLASH (rx) : ORIGIN = 0x0000, LENGTH = 4K
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 8K
}

SECTIONS {
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
        _etext = .;
    } > FLASH
}

#OUTPUT_FORMAT(binary)

