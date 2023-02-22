let targets = #{
    esp32: #{
        arch: "xtensa",
        has_swd: false,
        sys_peripheral: "DPORT",
        toolchain: "esp",
        rust_target: "xtensa-esp32-none-elf",
        atomic_emulation: "none",
        gcc_target: "xtensa-esp32-elf",
        hal_version: "0.10.0",
    },
    esp32s2: #{
        arch: "xtensa",
        has_swd: false,
        sys_peripheral: "SYSTEM",
        toolchain: "esp",
        rust_target: "xtensa-esp32s2-none-elf",
        atomic_emulation: "esp32s2",
        gcc_target: "xtensa-esp32s2-elf",
        hal_version: "0.7.0",
    },
    esp32s3: #{
        arch: "xtensa",
        has_swd: false,
        sys_peripheral: "SYSTEM",
        toolchain: "esp",
        rust_target: "xtensa-esp32s3-none-elf",
        atomic_emulation: "none",
        gcc_target: "xtensa-esp32s3-elf",
        hal_version: "0.7.0",
    },
    esp32c2: #{
        arch: "riscv",
        has_swd: true,
        sys_peripheral: "SYSTEM",
        toolchain: "nightly",
        rust_target: "riscv32imc-unknown-none-elf",
        atomic_emulation: "riscv",
        gcc_target: "riscv32-esp-elf",
        hal_version: "0.5.0",
    },
    esp32c3: #{
        arch: "riscv",
        has_swd: true,
        sys_peripheral: "SYSTEM",
        toolchain: "nightly",
        rust_target: "riscv32imc-unknown-none-elf",
        atomic_emulation: "riscv",
        gcc_target: "riscv32-esp-elf",
        hal_version: "0.7.0",
    },
};

let target = variable::get("mcu");
let target_properties = targets.get(target);
for key in target_properties.keys() {
    variable::set(key, target_properties.get(key));
}
