#![no_std]
use core::arch::asm;
use core::ptr;

fn print_char(c: u8)  {
    unsafe {
        let uart_tx_ptr: *mut u32 = 0x40000000 as *mut u32;
        while ptr::read_volatile(uart_tx_ptr) != !0 {}
        ptr::write_volatile(uart_tx_ptr, c as u32);
    }
}

fn print_string(c: &str) {
    for b in c.bytes() {
        print_char(b);
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn r_main() {
    loop {
        print_string("RUST!\n\r");
    }
}
