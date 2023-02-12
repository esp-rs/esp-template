#![no_std]
#![no_main]

{% if alloc -%}
extern crate alloc;
{% endif -%}

use {{ mcu }}_hal::{
    clock::ClockControl, peripherals::Peripherals, prelude::*, timer::TimerGroup, Rtc,
};
use esp_backtrace as _;
{% if mcu == "esp32s2" -%}
use xtensa_atomic_emulation_trap as _;
{% endif %}

{%- if alloc %}
#[global_allocator]
static ALLOCATOR: esp_alloc::EspHeap = esp_alloc::EspHeap::empty();

fn init_heap() {
    const HEAP_SIZE: usize = 32 * 1024;

    extern "C" {
        static mut _heap_start: u32;
        {%- if mcu != "esp32c2" and mcu != "esp32c3" %}
        static mut _heap_end: u32;
        {%- endif %}
    }

    unsafe {
        let heap_start = &_heap_start as *const _ as usize;
        {%- if mcu != "esp32c2" and mcu != "esp32c3" %}
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

{%- if mcu == "esp32" or mcu == "esp32s2" or mcu == "esp32s3" -%}
#[xtensa_lx_rt::entry]
{%- else %}
#[riscv_rt::entry]
{%- endif %}
fn main() -> ! {
    let peripherals = Peripherals::take();
    {%- if mcu == "esp32" %}
    let system = peripherals.DPORT.split();
    {%- else %}
    let system = peripherals.SYSTEM.split();
    {%- endif %}
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();

    // Disable the RTC and TIMG watchdog timers
    let mut rtc = Rtc::new(peripherals.RTC_CNTL);
    let timer_group0 = TimerGroup::new(peripherals.TIMG0, &clocks);
    let mut wdt0 = timer_group0.wdt;
    {%- if mcu != "esp32c2" %}
    let timer_group1 = TimerGroup::new(peripherals.TIMG1, &clocks);
    let mut wdt1 = timer_group1.wdt;
    {%- endif %}

    {%- if mcu == "esp32c3" %}
    rtc.swd.disable();
    {%- endif %}
    rtc.rwdt.disable();
    wdt0.disable();
    {%- if mcu != "esp32c2" %}
    wdt1.disable();
    {%- endif %}

    loop {}
}
