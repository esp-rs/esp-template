#![no_std]
#![no_main]

{% if alloc -%}
extern crate alloc;
{% endif -%}
use esp_backtrace as _;
use esp_println::println;
use hal::{clock::ClockControl, peripherals::Peripherals, prelude::*, timer::TimerGroup, Rtc};
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
    {% if alloc -%}
    init_heap();
    {%- endif %}
    let peripherals = Peripherals::take();
    let system = peripherals.{{ sys_peripheral }}.split();
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();

    // Disable the RTC and TIMG watchdog timers
    let mut rtc = Rtc::new(peripherals.RTC_CNTL);
    let timer_group0 = TimerGroup::new(peripherals.TIMG0, &clocks);
    let mut wdt0 = timer_group0.wdt;
    let timer_group1 = TimerGroup::new(peripherals.TIMG1, &clocks);
    let mut wdt1 = timer_group1.wdt;

    {% if has_swd -%}
    rtc.swd.disable();
    {% endif -%}
    rtc.rwdt.disable();
    wdt0.disable();
    wdt1.disable();

    println!("Hello world!");

    loop {}
}
