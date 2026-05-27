"""File logging example using the loguru-style Logger API.

This example demonstrates how to add file sinks and configure
file-based logging with the modern Logger API.
"""

from spdlog import get_logger


def main() raises -> None:
    print("===== Loguru-style Logger File Example =====")
    print()

    var logger = get_logger()

    # 1. Basic console logging
    print("1. Starting with console logging...")
    logger.info("This goes to console")

    # 2. Add file sink
    print("\n2. Adding file sink...")
    var log_file = "./tmp/logger_example.log"
    var sink_id = logger.add(log_file, level="DEBUG")
    print("   Added file sink:", log_file)
    print("   Sink ID:", sink_id)

    # 3. Log to both console and file
    print("\n3. Logging to both console and file...")
    logger.info("This message goes to both console and file")
    logger.debug("Debug message to both outputs")
    logger.warn("Warning message to both outputs")

    # 4. Flush to ensure writes
    print("\n4. Flushing logs...")
    logger.flush()

    # 5. Read and display file contents
    print("\n5. File contents:")
    print("   ---")
    try:
        with open(log_file, "r") as f:
            var content = f.read()
            print(content)
    except:
        print("   (Could not read file)")
    print("   ---")

    # 6. Remove file sink
    print("\n6. Removing file sink...")
    logger.remove(sink_id)
    print("   File sink removed")

    # 7. Back to console only
    print("\n7. Back to console only:")
    logger.info("This only goes to console")

    print("\n===== Example completed =====")
