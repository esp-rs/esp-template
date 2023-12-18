let metadata = #{
    // Xtensa devices:
    esp32: #{
        hal_version: "0.17.0",
        wokwi_board: "board-esp32-devkit-c-v4",
    },
    esp32s2: #{
        atomic_emulation: true,
        hal_version: "0.14.0",
        wokwi_board: "board-esp32-s2-devkitm-1",
    },
    esp32s3: #{
        hal_version: "0.14.0",
        wokwi_board: "board-esp32-s3-devkitc-1",
    },

    // RISC-V devices:
     esp32c2: #{
        atomic_emulation: true,
        extensions: "imc",
        hal_version: "0.12.0",
        wokwi_board: "",
    },
    esp32c3: #{
        atomic_emulation: true,
        extensions: "imc",
        hal_version: "0.14.0",
        wokwi_board: "board-esp32-c3-devkitm-1",
    },
    esp32c6: #{
        extensions: "imac",
        hal_version: "0.7.0",
        wokwi_board: "board-esp32-c6-devkitc-1",
    },
    esp32h2: #{
        extensions: "imac",
        hal_version: "0.5.0",
        wokwi_board: "board-esp32-h2-devkitm-1",
    },
};

let mcu = variable::get("mcu");
let meta = metadata.get(mcu);

if meta.contains("atomic_emulation") {
    variable::set("atomic_emulation", meta.get("atomic_emulation"));
} else {
    variable::set("atomic_emulation", false);
}

variable::set("hal_version", meta.get("hal_version"));
variable::set("wokwi_board", meta.get("wokwi_board"));


if mcu in ["esp32", "esp32s2", "esp32s3"] {
    // Xtensa devices:
    variable::set("arch", "xtensa");
    variable::set("gcc_target", `xtensa-${mcu}-elf`);
    variable::set("has_swd", false);
    variable::set("rust_target", `xtensa-${mcu}-none-elf`);
    variable::set("toolchain", "esp");
} else {
    // RISC-V devices:
    let extensions = meta.get("extensions");

    variable::set("arch", "riscv");
    variable::set("gcc_target", "riscv32-esp-elf");
    variable::set("has_swd", true);
    variable::set("rust_target", `riscv32${extensions}-unknown-none-elf`);
    variable::set("toolchain", "nightly");
}

let advanced = variable::get("advanced");
if !advanced {
    variable::set("alloc", false);
    variable::set("devcontainer", false);
    variable::set("wokwi", false);
    variable::set("logging", false);
    variable::set("wifi", false);
}
