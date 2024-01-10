let metadata = #{
    // Xtensa devices:
    esp32: #{
        hal_version: "0.17.0",
        wokwi_board: "board-esp32-devkit-c-v4",
        esp_wifi_init: "Wifi",
        esp_wifi_feature: "wifi",
        esp_wifi_timer: "timer::TimerGroup::new(peripherals.TIMG1, &clocks).timer0"
    },
    esp32s2: #{
        hal_version: "0.14.0",
        wokwi_board: "board-esp32-s2-devkitm-1",
        esp_wifi_init: "Wifi",
        esp_wifi_feature: "wifi",
        esp_wifi_timer: "timer::TimerGroup::new(peripherals.TIMG1, &clocks).timer0"
    },
    esp32s3: #{
        hal_version: "0.14.0",
        wokwi_board: "board-esp32-s3-devkitc-1",
        esp_wifi_init: "Wifi",
        esp_wifi_feature: "wifi",
        esp_wifi_timer: "timer::TimerGroup::new(peripherals.TIMG1, &clocks).timer0"
    },

    // RISC-V devices:
     esp32c2: #{
        extensions: "imc",
        hal_version: "0.12.0",
        wokwi_board: "",
        esp_wifi_init: "Wifi",
        esp_wifi_feature: "wifi",
        esp_wifi_timer: "systimer::SystemTimer::new(peripherals.SYSTIMER).alarm0"
    },
    esp32c3: #{
        extensions: "imc",
        hal_version: "0.14.0",
        wokwi_board: "board-esp32-c3-devkitm-1",
        esp_wifi_init: "Wifi",
        esp_wifi_feature: "wifi",
        esp_wifi_timer: "systimer::SystemTimer::new(peripherals.SYSTIMER).alarm0"
    },
    esp32c6: #{
        extensions: "imac",
        hal_version: "0.7.0",
        wokwi_board: "board-esp32-c6-devkitc-1",
        esp_wifi_init: "Wifi",
        esp_wifi_feature: "wifi",
        esp_wifi_timer: "systimer::SystemTimer::new(peripherals.SYSTIMER).alarm0"
    },
    esp32h2: #{
        extensions: "imac",
        hal_version: "0.5.0",
        wokwi_board: "board-esp32-h2-devkitm-1",
        esp_wifi_init: "Ble",
        esp_wifi_feature: "ble",
        esp_wifi_timer: "systimer::SystemTimer::new(peripherals.SYSTIMER).alarm0"
    },
};

let mcu = variable::get("mcu");
let meta = metadata.get(mcu);

variable::set("esp_wifi_feature", meta.get("esp_wifi_feature"));
variable::set("hal_version", meta.get("hal_version"));
variable::set("wokwi_board", meta.get("wokwi_board"));

if mcu in ["esp32", "esp32s2", "esp32s3"] {
    // Xtensa devices:
    variable::set("arch", "xtensa");
    variable::set("gcc_target", `xtensa-${mcu}-elf`);
    variable::set("rust_target", `xtensa-${mcu}-none-elf`);
    variable::set("toolchain", "esp");
} else {
    // RISC-V devices:
    let extensions = meta.get("extensions");

    variable::set("arch", "riscv");
    variable::set("gcc_target", "riscv32-esp-elf");
    variable::set("rust_target", `riscv32${extensions}-unknown-none-elf`);
    variable::set("toolchain", "nightly");
}

let advanced = variable::get("advanced");
if !advanced {
    variable::set("alloc", false);
    variable::set("ci", false);
    variable::set("devcontainer", false);
    variable::set("wokwi", false);
    variable::set("wifi", false);
}

//
// Snippets - These should be short & self-contained, not depending on other snippets existing where possible.
//

variable::set("alloc_snippet", 
`
extern crate alloc;
use core::mem::MaybeUninit;

#[global_allocator]
static ALLOCATOR: esp_alloc::EspHeap = esp_alloc::EspHeap::empty();

fn init_heap() {
    const HEAP_SIZE: usize = 32 * 1024;
    static mut HEAP: MaybeUninit<[u8; HEAP_SIZE]> = MaybeUninit::uninit();

    unsafe {
        ALLOCATOR.init(HEAP.as_mut_ptr() as *mut u8, HEAP_SIZE);
    }
}
`);

variable::set("esp_wifi_snippet",
`
let timer = ${mcu}_hal::${meta.esp_wifi_timer};
let _init = esp_wifi::initialize(
    esp_wifi::EspWifiInitFor::${meta.esp_wifi_init},
    timer,
    Rng::new(peripherals.RNG),
    system.radio_clock_control,
    &clocks,
)
.unwrap();
`
);
