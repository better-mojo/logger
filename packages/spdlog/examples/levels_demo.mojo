"""Log levels demonstration for spdlog.

This example shows how different log levels work and how to use them effectively.
"""

from spdlog import (
    init_logger,
    set_level,
    get_level,
    level_name,
    flush,
    trace,
    debug,
    info,
    warn,
    error,
    critical,
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    CRITICAL,
    OFF,
)


def log_at_all_levels() raises -> None:
    """Helper function to log at all levels."""
    trace("[TRACE] Detailed debugging information")
    debug("[DEBUG] Debugging information")
    info("[INFO] General information")
    warn("[WARN] Warning message")
    error("[ERROR] Error message")
    critical("[CRITICAL] Critical error message")


def main() raises -> None:
    print("===== spdlog Levels Demo =====")
    print()

    # Initialize
    if not init_logger():
        print("Failed to initialize logger")
        return

    # Demonstrate each log level
    print("Testing TRACE level:")
    set_level(TRACE)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("Testing DEBUG level:")
    set_level(DEBUG)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("Testing INFO level:")
    set_level(INFO)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("Testing WARN level:")
    set_level(WARN)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("Testing ERROR level:")
    set_level(ERROR)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("Testing CRITICAL level:")
    set_level(CRITICAL)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("Testing OFF level:")
    set_level(OFF)
    print("Current level:", level_name(get_level()))
    log_at_all_levels()
    flush()
    print()

    print("-" * 50)
    print("\n===== Demo completed =====")
    print()
    print("Summary:")
    print("  - TRACE (0): Most verbose, all messages shown")
    print("  - DEBUG (1): Debug messages and above")
    print("  - INFO  (2): Info messages and above")
    print("  - WARN  (3): Warning messages and above")
    print("  - ERROR (4): Error messages and above")
    print("  - CRITICAL (5): Only critical messages")
    print("  - OFF   (6): No messages shown")
