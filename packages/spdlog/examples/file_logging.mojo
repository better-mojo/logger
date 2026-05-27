"""File logging example for spdlog.

This example demonstrates how to log to a file.
"""

from spdlog import (
    init_logger,
    init_file_logger,
    set_level,
    flush,
    info,
    warn,
    error,
    DEBUG,
)


def main() raises -> None:
    print("===== spdlog File Logging Example =====")
    print()

    # First initialize the default logger
    print("1. Initializing default logger...")
    if not init_logger():
        print("   Failed to initialize logger")
        return
    print("   Logger initialized!")

    # Then switch to file logging
    var log_path = "./tmp/mojo_spdlog_example.log"
    print("\n2. Switching to file logging:", log_path)

    if init_file_logger(log_path):
        print("   File logger initialized!")
    else:
        print("   Failed to initialize file logger")
        return

    # Set log level
    set_level(DEBUG)

    # Write some log messages
    print("\n3. Writing log messages to file...")
    info("===== File logging example started =====")
    info("This is an info message in the file")
    warn("This is a warning message in the file")
    error("This is an error message in the file")

    # Flush to ensure everything is written
    flush()

    print("   Messages written to file!")
    print("\n4. Check the log file at:", log_path)

    # Try to read and display the file contents
    try:
        with open(log_path, "r") as f:
            print("\n5. File contents:")
            print("-" * 40)
            var content = f.read()
            print(content)
            print("-" * 40)
    except:
        print("\n5. Could not read file contents (this is OK)")

    print("\n===== Example completed =====")
