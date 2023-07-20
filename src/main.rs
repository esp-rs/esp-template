#![no_std]
#![no_main]

{% if alloc -%}
extern crate alloc;
{% endif -%}
use esp_backtrace as _;
use esp_println::println;
use hal::{clock::ClockControl, peripherals::Peripherals, prelude::*, timer::TimerGroup, Rtc};
{% if logging -%}
use log::{info};
{% endif -%}

{%- if alloc %}
#[global_allocator]
static ALLOCATOR: esp_alloc::EspHeap = esp_alloc::EspHeap::empty();

fn init_heap() {
    const HEAP_SIZE: usize = 32 * 1024;

    extern "C" {
        static mut _heap_start: u32;
        {%- if arch == "xtensa" %}
        static mut _heap_end: u32;
        {%- endif %}
    }

    unsafe {
        let heap_start = &_heap_start as *const _ as usize;
        {%- if arch == "xtensa" %}
        let heap_end = &_heap_end as *const _ as usize;
        assert!(
            heap_end - heap_start > HEAP_SIZE,
            "Not enough available heap memory."
        );
        {%- endif %}
        ALLOCATOR.init(heap_start as *mut u8, HEAP_SIZE);
    }
}
{% endif %}
#[entry]
fn main() -> ! {
    {%- if alloc %}
    init_heap();
    {%- endif %}
    let peripherals = Peripherals::take();
    let mut system = peripherals.{{ sys_peripheral }}.split();
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();

    // Disable the RTC and TIMG watchdog timers
    let mut rtc = Rtc::new(peripherals.{{ rct_peripheral }});
    let timer_group0 = TimerGroup::new(
        peripherals.TIMG0,
        &clocks,
        &mut system.peripheral_clock_control,
    );
    let mut wdt0 = timer_group0.wdt;
    {% if has_tg1 -%}
    let timer_group1 = TimerGroup::new(
        peripherals.TIMG1,
        &clocks,
        &mut system.peripheral_clock_control,
    );
    let mut wdt1 = timer_group1.wdt;
    {% endif -%}

    {% if has_swd -%}
    rtc.swd.disable();
    {% endif -%}
    rtc.rwdt.disable();
    wdt0.disable();
    {% if has_tg1 -%}
    wdt1.disable();
    {% endif -%}

    {% if logging -%}
    // setup logger
    // To change the log_level change the env section in .config/cargo.toml
    // or remove it and set ESP_LOGLEVEL manually before running cargo run
    // this requires a clean rebuild because of https://github.com/rust-lang/cargo/issues/10358
    esp_println::logger::init_logger_from_env();
    info!("Logger is setup");
    {% endif -%}
 
    println!("Hello world!");

    loop {}
}
