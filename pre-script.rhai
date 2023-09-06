let targets = #{
    esp32: #{
        arch: "xtensa",
        has_swd: false,
        has_tg1: true,
        sys_peripheral: "DPORT",
        rct_peripheral: "RTC_CNTL",
        toolchain: "esp",
        rust_target: "xtensa-esp32-none-elf",
        atomic_emulation: "none",
        gcc_target: "xtensa-esp32-elf",
        hal_version: "0.15.0",
        wokwi_board: "board-esp32-devkit-v1",
    },
     esp32c2: #{
        arch: "riscv",
        has_swd: true,
        has_tg1: false,
        sys_peripheral: "SYSTEM",
        rct_peripheral: "RTC_CNTL",
        toolchain: "nightly",
        rust_target: "riscv32imc-unknown-none-elf",
        atomic_emulation: "riscv",
        gcc_target: "riscv32-esp-elf",
        hal_version: "0.10.0",
        wokwi_board: "",
    },
    esp32c3: #{
        arch: "riscv",
        has_swd: true,
        has_tg1: true,
        sys_peripheral: "SYSTEM",
        rct_peripheral: "RTC_CNTL",
        toolchain: "nightly",
        rust_target: "riscv32imc-unknown-none-elf",
        atomic_emulation: "riscv",
        gcc_target: "riscv32-esp-elf",
        hal_version: "0.12.0",
        wokwi_board: "board-esp32-c3-devkitm-1",
    },
    esp32c6: #{
        arch: "riscv",
        has_swd: true,
        has_tg1: true,
        sys_peripheral: "PCR",
        rct_peripheral: "LP_CLKRST",
        toolchain: "nightly",
        rust_target: "riscv32imac-unknown-none-elf",
        atomic_emulation: "none",
        gcc_target: "riscv32-esp-elf",
        hal_version: "0.5.0",
        wokwi_board: "board-esp32-c6-devkitc-1",
    },
    esp32h2: #{
        arch: "riscv",
        has_swd: true,
        has_tg1: true,
        sys_peripheral: "PCR",
        rct_peripheral: "LP_CLKRST",
        toolchain: "nightly",
        rust_target: "riscv32imac-unknown-none-elf",
        atomic_emulation: "none",
        gcc_target: "riscv32-esp-elf",
        hal_version: "0.3.0",
        wokwi_board: "",
    },
    esp32s2: #{
        arch: "xtensa",
        has_swd: false,
        has_tg1: true,
        sys_peripheral: "SYSTEM",
        rct_peripheral: "RTC_CNTL",
        toolchain: "esp",
        rust_target: "xtensa-esp32s2-none-elf",
        atomic_emulation: "esp32s2",
        gcc_target: "xtensa-esp32s2-elf",
        hal_version: "0.12.0",
        wokwi_board: "board-esp32-s2-devkitm-1",
    },
    esp32s3: #{
        arch: "xtensa",
        has_swd: false,
        has_tg1: true,
        sys_peripheral: "SYSTEM",
        rct_peripheral: "RTC_CNTL",
        toolchain: "esp",
        rust_target: "xtensa-esp32s3-none-elf",
        atomic_emulation: "none",
        gcc_target: "xtensa-esp32s3-elf",
        hal_version: "0.12.0",
        wokwi_board: "board-esp32-s3-devkitc-1",
    },
};

let target = variable::get("mcu");
let target_properties = targets.get(target);
for key in target_properties.keys() {
    variable::set(key, target_properties.get(key));
}

let advanced = variable::get("advanced");
if !advanced {
    variable::set("alloc", false);
    variable::set("devcontainer", false);
    variable::set("wokwi", false);
    variable::set("logging", false);
}
