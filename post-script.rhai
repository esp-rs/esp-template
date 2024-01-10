if variable::get("wifi"){
    print("\nFor more information and examples of esp-wifi showcasing Wifi,BLE and ESP-NOW, see https://github.com/esp-rs/esp-wifi/blob/main/examples.md\n");
}

if variable::get("ci") {
    file::rename(".github/rust_ci.yml", ".github/workflows/rust_ci.yml");
}
