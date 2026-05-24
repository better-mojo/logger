from spdlog import (
    init_logger,
    set_level,
    get_level,
    flush,
    version,
    level_name,
    trace,
    debug,
    info,
    warn,
    error,
    critical,
    log,
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    CRITICAL,
)


def main() raises -> None:
    """Basic example of using spd spdlog."""
    init_logger()
    set_level(INFO)
    # info("Hello, world!", "name", "Mojo")
    warn("Warning message")
    error("Error message")
    critical("Critical message")
    flush()
    log(INFO, "Log message with level INFO")

    print("hello", "world")
