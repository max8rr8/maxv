SECTIONS
{
  . = 0x20000400;
  .text : { *(.text) }

  . = 0x20001000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}