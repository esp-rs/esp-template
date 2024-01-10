#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{clock::ClockControl, peripherals::Peripherals, prelude::*, Delay};

{% if alloc -%}
{{ alloc_snippet }}
{% endif -%}

#[entry]
fn main() -> ! {
    let peripherals = Peripherals::take();
    let system = peripherals.SYSTEM.split();

    let clocks = ClockControl::max(system.clock_control).freeze();
    let mut delay = Delay::new(&clocks);

    {%- if alloc %}
    init_heap();
    {%- endif %}

    esp_println::logger::init_logger_from_env();

    {% if wifi -%}
    {{ esp_wifi_snippet }}
    {% endif -%}

    loop {
        log::info!("Hello world!");
        delay.delay_ms(500u32);
    }
}
