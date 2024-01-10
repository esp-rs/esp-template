fn main() {
    println!("cargo:rustc-link-arg-bins=-Tlinkall.x");
    {% if wifi %}
    println!("cargo:rustc-link-arg-bins=-Trom_functions.x");
    {% endif -%}
}