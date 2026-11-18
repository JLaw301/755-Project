use std::arch::wasm32::memory_size;
fn main() {
    let bytes = memory_size(0) * 65536;
    println!("linear memory size: {} bytes", bytes);
    println!("pointer size: {} bits", usize::BITS);
    let target = bytes + 4096;
    println!("trying to read address {:#x} (past the end)...", target);
    let v = unsafe { std::ptr::read_volatile(target as *const u8) };
    println!("READ SUCCEEDED: {}", v);
}
