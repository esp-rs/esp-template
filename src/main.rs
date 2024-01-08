#![no_std]
#![no_main]

{% if alloc -%}
extern crate alloc;
use core::mem::MaybeUninit;
{% endif -%}
use {{ mcu }}_hal::{clock::ClockControl, peripherals::Peripherals, prelude::*, Delay};
use esp_backtrace as _;
use esp_println::println;

{% if wifi -%}
use esp_wifi::{initialize, EspWifiInitFor};

{% if arch == "riscv" -%}
use {{ mcu }}_hal::{systimer::SystemTimer, Rng};
{% else -%}
use {{ mcu }}_hal::{timer::TimerGroup, Rng};
{% endif -%}
{% endif -%}

{% if alloc -%}
#[global_allocator]
static ALLOCATOR: esp_alloc::EspHeap = esp_alloc::EspHeap::empty();

fn init_heap() {
    const HEAP_SIZE: usize = 32 * 1024;
    static mut HEAP: MaybeUninit<[u8; HEAP_SIZE]> = MaybeUninit::uninit();

    unsafe {
        ALLOCATOR.init(HEAP.as_mut_ptr() as *mut u8, HEAP_SIZE);
    }
}
{% endif -%}
#[entry]
fn main() -> ! {
    {%- if alloc %}
    init_heap();
    {%- endif %}
    let peripherals = Peripherals::take();
    let system = peripherals.SYSTEM.split();

    let clocks = ClockControl::max(system.clock_control).freeze();
    let mut delay = Delay::new(&clocks);

    {% if logging -%}
    // setup logger
    // To change the log_level change the env section in .cargo/config.toml
    // or remove it and set ESP_LOGLEVEL manually before running cargo run
    // this requires a clean rebuild because of https://github.com/rust-lang/cargo/issues/10358
    esp_println::logger::init_logger_from_env();
    log::info!("Logger is setup");
    {% endif -%}
    println!("Hello world!");
    {% if wifi -%}
    {% if arch == "riscv" -%}
    let timer = SystemTimer::new(peripherals.SYSTIMER).alarm0;
    {% else -%}
    let timer = TimerGroup::new(peripherals.TIMG1, &clocks).timer0;
    {% endif -%}
    let _init = initialize(
        EspWifiInitFor::Wifi,
        timer,
        Rng::new(peripherals.RNG),
        system.radio_clock_control,
        &clocks,
    )
    .unwrap();
    {% endif -%}
    loop {
        println!("Loop...");
        delay.delay_ms(500u32);
    }
}
