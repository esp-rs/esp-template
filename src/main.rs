#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{delay::Delay, prelude::*};

{% if alloc -%}
{{ alloc_snippet }}
{% endif -%}

#[entry]
fn main() -> ! {
    #[allow(unused)]
    let peripherals = esp_hal::init(esp_hal::Config::default());
    let delay = Delay::new();

    {%- if alloc %}
    init_heap();
    {%- endif %}

    esp_println::logger::init_logger_from_env();

    {% if wifi -%}
    {{ esp_wifi_snippet }}
    {% endif -%}

    loop {
        log::info!("Hello world!");
        delay.delay(500.millis());
    }
}
