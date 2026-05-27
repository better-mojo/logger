use spdlog_ffi;

fn main() {
    #[cfg(feature = "c-headers")]
    spdlog_ffi::generate_headers().expect("Failed to generate headers");
}
