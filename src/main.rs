#![no_std]
#![no_main]

use {{ mcu }}_hal::{clock::ClockControl, pac::Peripherals, prelude::*, timer::TimerGroup, RtcCntl};
use esp_backtrace as _;
{% if mcu == "esp32c3" -%}
use riscv_rt::entry;
{%- else -%}
{%- if mcu == "esp32s2" -%}
use xtensa_atomic_emulation_trap as _;
{% endif -%}
use xtensa_lx_rt::entry;
{%- endif %}

#[entry]
fn main() -> ! {
    let peripherals = Peripherals::take().unwrap();
    {%- if mcu == "esp32" %}
    let system = peripherals.DPORT.split();
    {%- else %}
    let system = peripherals.SYSTEM.split();
    {%- endif %}
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();

    // Disable the RTC and TIMG watchdog timers
    let mut rtc_cntl = RtcCntl::new(peripherals.RTC_CNTL);
    let timer_group0 = TimerGroup::new(peripherals.TIMG0, &clocks);
    let mut wdt0 = timer_group0.wdt;
    let timer_group1 = TimerGroup::new(peripherals.TIMG1, &clocks);
    let mut wdt1 = timer_group1.wdt;

    {% if mcu == "esp32c3" -%}
    rtc_cntl.set_super_wdt_enable(false);
    rtc_cntl.set_wdt_enable(false);
    {%- else -%}
    rtc_cntl.set_wdt_global_enable(false);
    {%- endif %}
    wdt0.disable();
    wdt1.disable();

    loop {}
}
