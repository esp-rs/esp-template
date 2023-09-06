#![no_std]
#![no_main]

{% if alloc -%}
extern crate alloc;
use core::mem::MaybeUninit;
{% endif -%}
use esp_backtrace as _;
use esp_println::println;
use hal::{clock::ClockControl, peripherals::Peripherals, prelude::*, Delay};
{% if logging -%}
use log::info;
{% endif -%}

{%- if alloc %}
#[global_allocator]
static ALLOCATOR: esp_alloc::EspHeap = esp_alloc::EspHeap::empty();

fn init_heap() {
    const HEAP_SIZE: usize = 32 * 1024;
    static mut HEAP: MaybeUninit<[u8; HEAP_SIZE]> = MaybeUninit::uninit();

    unsafe {
        ALLOCATOR.init(HEAP.as_mut_ptr() as *mut u8, HEAP_SIZE);
    }
}
{% endif %}
#[entry]
fn main() -> ! {
    {%- if alloc %}
    init_heap();
    {%- endif %}
    let peripherals = Peripherals::take();
    let system = peripherals.{{ sys_peripheral }}.split();
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();
    let mut delay = Delay::new(&clocks);

    {% if logging -%}
    // setup logger
    // To change the log_level change the env section in .config/cargo.toml
    // or remove it and set ESP_LOGLEVEL manually before running cargo run
    // this requires a clean rebuild because of https://github.com/rust-lang/cargo/issues/10358
    esp_println::logger::init_logger_from_env();
    info!("Logger is setup");
    {% endif -%}

    println!("Hello world!");

    loop {
        println!("Loop...");
        delay.delay_ms(500u32);
    }
}
