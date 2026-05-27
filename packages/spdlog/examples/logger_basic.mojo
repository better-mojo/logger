"""Basic example of using the loguru-style Logger API.

This example demonstrates the modern, easy-to-use logging interface
inspired by Python's loguru library.
"""

from spdlog import get_logger


def main() raises -> None:
    print("===== Loguru-style Logger Basic Example =====")
    print()

    var logger = get_logger()

    # 1. Ready to use out of the box!
    print("1. Basic logging - no initialization needed!")
    logger.info("Hello, World!")
    logger.debug("This won't show (default level is INFO)")

    # 2. Set log level
    print("\n2. Setting log level to DEBUG...")
    logger.set_level("DEBUG")
    logger.debug("Now debug messages will appear!")

    # 3. Different log levels
    print("\n3. Logging at different levels:")
    logger.trace("Trace message (most verbose)")
    logger.debug("Debug message for development")
    logger.info("Info message for general information")
    logger.warn("Warning message for potential issues")
    logger.error("Error message for problems")
    logger.critical("Critical message for severe errors")

    # 4. String formatting
    print("\n4. String formatting with {} placeholders:")
    logger.info("User {} logged in from {}", "alice", "192.168.1.1")
    logger.debug("Processing item {} of {}", "5", "100")
    logger.warn("Disk usage is at {}%", "85")

    # 5. Get current level
    print("\n5. Current log level:", logger.get_level())

    # 6. Flush logs
    print("\n6. Flushing log buffers...")
    logger.flush()
    print("   Done!")

    print("\n===== Example completed =====")
