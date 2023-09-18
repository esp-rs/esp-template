#![no_std]
#![no_main]

{% if alloc -%}
extern crate alloc;
use core::mem::MaybeUninit;
{% endif -%}
use esp_backtrace as _;
use esp_println::println;
use hal::{clock::ClockControl, peripherals::Peripherals, prelude::*, Delay};

{% if wifi -%}
use embedded_svc::{
    ipv4::Interface,
    wifi::{AccessPointInfo, ClientConfiguration, Configuration, Wifi},
};
use esp_wifi::{
    current_millis, initialize,
    wifi::{utils::create_network_interface, WifiError, WifiMode},
    wifi_interface::WifiStack,
    EspWifiInitFor,
};
{%- if arch == "riscv" %}
use hal::{systimer::SystemTimer, Rng};
{% else -%}
use hal::Rng;
{% if logging -%}

use smoltcp::iface::SocketStorage;
{% endif -%}
{% if logging -%}
use log::info;
{% endif -%}

{% if wifi -%}
const SSID: &str = env!("SSID");
const PASSWORD: &str = env!("PASSWORD");
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
    let clocks = ClockControl::max(system.clock_control).freeze();
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


    {% if wifi -%}
    {%- if arch == "riscv" %}
    let timer = SystemTimer::new(peripherals.SYSTIMER).alarm0;
    {% else -%}
    let timer = hal::timer::TimerGroup::new(
        peripherals.TIMG1,
        &clocks,
        &mut system.peripheral_clock_control,
    )
    .timer0;
    {% endif -%}

    let init = initialize(
        EspWifiInitFor::Wifi,
        timer,
        Rng::new(peripherals.RNG),
        system.radio_clock_control,
        &clocks,
    )
    .unwrap();
    {% if mcu == "esp32s2" -%}
    let wifi = peripherals.RADIO.split();
    {% else -%}
    let (wifi, ..) = peripherals.RADIO.split();
    {% endif -%}
    let mut socket_set_entries: [SocketStorage; 3] = Default::default();
    let (iface, device, mut controller, sockets) =
        create_network_interface(&init, wifi, WifiMode::Sta, &mut socket_set_entries).unwrap();
    let wifi_stack = WifiStack::new(iface, device, sockets, current_millis);
    let client_config = Configuration::Client(ClientConfiguration {
        ssid: SSID.into(),
        password: PASSWORD.into(),
        ..Default::default()
    });
    let res = controller.set_configuration(&client_config);
    println!("Wi-Fi set_configuration returned {:?}", res);

    controller.start().unwrap();
    println!("Is wifi started: {:?}", controller.is_started());

    println!("Start Wifi Scan");
    let res: Result<(heapless::Vec<AccessPointInfo, 10>, usize), WifiError> = controller.scan_n();
    if let Ok((res, _count)) = res {
        for ap in res {
            println!("{:?}", ap);
        }
    }

    println!("{:?}", controller.get_capabilities());
    println!("Wi-Fi connect: {:?}", controller.connect());

    // Wait to get connected
    println!("Wait to get connected");
    loop {
        let res = controller.is_connected();
        match res {
            Ok(connected) => {
                if connected {
                    break;
                }
            }
            Err(err) => {
                println!("{:?}", err);
                loop {}
            }
        }
    }
    println!("{:?}", controller.is_connected());

    // Wait for getting an ip address
    println!("Wait to get an ip address");
    loop {
        wifi_stack.work();

        if wifi_stack.is_iface_up() {
            println!("got ip {:?}", wifi_stack.get_ip_info());
            break;
        }
    }
    {% endif -%}

    loop {
        println!("Loop...");
        delay.delay_ms(500u32);
    }
}
