"""Basic logging example for spdlog.

This example demonstrates the basic usage of the spdlog library.
"""

from spdlog import (
    init_logger, set_level, get_level, flush, version, level_name,
    trace, debug, info, warn, error, critical, log,
    TRACE, DEBUG, INFO, WARN, ERROR, CRITICAL
)


def main() raises -> None:
    print("===== spdlog Basic Example =====")
    print()

    # 1. Initialize the logger
    print("1. Initializing logger...")
    if init_logger():
        print("   Logger initialized successfully!")
    else:
        print("   Failed to initialize logger")
        return

    # 2. Get library version
    print("\n2. Library version:", version())

    # 3. Set log level to DEBUG (show debug and above)
    print("\n3. Setting log level to DEBUG...")
    set_level(DEBUG)
    print("   Current level:", level_name(get_level()))

    # 4. Log messages at different levels
    print("\n4. Logging messages at different levels:")
    trace("This is a TRACE message")
    debug("This is a DEBUG message")
    info("This is an INFO message")
    warn("This is a WARN message")
    error("This is an ERROR message")
    critical("This is a CRITICAL message")

    # 5. Use the generic log function
    print("\n5. Using generic log() function:")
    log(INFO, "This is an INFO message using log()")
    log(ERROR, "This is an ERROR message using log()")

    # 6. Demonstrate log level filtering
    print("\n6. Setting log level to WARN (only WARN and above will show)...")
    set_level(WARN)
    print("   Current level:", level_name(get_level()))
    
    print("\n   Attempting to log at various levels:")
    trace("This TRACE message will NOT appear")
    debug("This DEBUG message will NOT appear")
    info("This INFO message will NOT appear")
    warn("This WARN message WILL appear")
    error("This ERROR message WILL appear")
    critical("This CRITICAL message WILL appear")

    # 7. Flush the log buffer
    print("\n7. Flushing log buffer...")
    flush()
    print("   Done!")

    print("\n===== Example completed =====")
