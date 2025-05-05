#![no_std]
use core::arch::asm;

fn print_char(c: u8)  {
    unsafe {
        let uart_ptr: *mut u8 = 0x1234 as *mut u8;
        *uart_ptr = c;
        let mut i = 0x200;
        while i != 0 { i -= 1;  asm!("nop"); }
    }
}

fn print_string(c: &str) {
    for b in c.bytes() {
        print_char(b);
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn r_main() {
    print_string("RUST!\n\r");
}
