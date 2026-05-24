"""Logging library for Mojo.

This library provides high-level logging functions backed by a Rust FFI.

Example:
    ```mojo
    from spdlog import (
        init_logger, set_level, get_level, flush,
        trace, debug, info, warn, error, critical, log,
        LOG_LEVEL_TRACE, LOG_LEVEL_DEBUG, LOG_LEVEL_INFO,
        LOG_LEVEL_WARN, LOG_LEVEL_ERROR, LOG_LEVEL_CRITICAL, LOG_LEVEL_OFF
    )

    # Initialize the logger
    init_logger()

    # Set log level to Debug
    set_level(LOG_LEVEL_DEBUG)

    # Log messages at different levels
    trace("This is a trace message")
    debug("This is a debug message")
    info("This is an info message")
    warn("This is a warning message")
    error("This is an error message")
    critical("This is a critical message")

    # Log with a specific level
    log(LOG_LEVEL_INFO, "This is an info message using log()")

    # Get current log level
    var level = get_level()
    print("Current log level:", level)

    # Flush the log buffer
    flush()
    ```
"""

from spdlog.ffi import (
    SpdlogFFI,
    LOG_LEVEL_TRACE,
    LOG_LEVEL_DEBUG,
    LOG_LEVEL_INFO,
)
from spdlog.ffi import (
    LOG_LEVEL_WARN,
    LOG_LEVEL_ERROR,
    LOG_LEVEL_CRITICAL,
    LOG_LEVEL_OFF,
)

from spdlog.logger import get_logger

# Re-export log level constants for convenience
comptime TRACE = LOG_LEVEL_TRACE
comptime DEBUG = LOG_LEVEL_DEBUG
comptime INFO = LOG_LEVEL_INFO
comptime WARN = LOG_LEVEL_WARN
comptime ERROR = LOG_LEVEL_ERROR
comptime CRITICAL = LOG_LEVEL_CRITICAL
comptime OFF = LOG_LEVEL_OFF


# -----------------------------------------------------------------------
# Logger Initialization and Configuration
# -----------------------------------------------------------------------




def init_logger() raises -> Bool:
    """Initialize the default logger.

    This should be called once at the start of your application.

    Returns:
        True if initialization succeeded, False otherwise.

    Example:
        ```mojo
        from spdlog import init_logger

        if init_logger():
            print("Logger initialized successfully")
        ```
    """
    var ffi = SpdlogFFI()
    return ffi.logger_init()


def set_level(level: UInt8) raises -> None:
    """Set the log level filter.

    Only messages at or above the specified level will be logged.

    Args:
        level: Log level (use constants: TRACE, DEBUG, INFO, WARN, ERROR, CRITICAL, OFF).

    Example:
        ```mojo
        from spdlog import set_level, DEBUG

        set_level(DEBUG)  # Show debug and above
        ```
    """
    var ffi = SpdlogFFI()
    ffi.set_level(level)


def get_level() raises -> UInt8:
    """Get the current log level.

    Returns:
        Current log level (0-6).

    Example:
        ```mojo
        from spdlog import get_level, INFO

        if get_level() <= INFO:
            print("Info level logging is enabled")
        ```
    """
    var ffi = SpdlogFFI()
    return ffi.get_level()


def flush() raises -> None:
    """Flush the log buffer.

    This ensures all pending log messages are written to their destinations.

    Example:
        ```mojo
        from spdlog import flush

        # ... log some messages ...
        flush()  # Ensure all messages are written
        ```
    """
    var ffi = SpdlogFFI()
    ffi.flush()


def init_file_logger(path: String) raises -> Bool:
    """Initialize a file logger.

    All subsequent log messages will be written to the specified file.

    Args:
        path: Path to the log file.

    Returns:
        True if initialization succeeded, False otherwise.

    Example:
        ```mojo
        from spdlog import init_file_logger, info

        if init_file_logger("/tmp/myapp.log"):
            info("Logging to file started")
        ```
    """
    var ffi = SpdlogFFI()
    return ffi.init_file_logger(path)


def version() raises -> String:
    """Get the library version.

    Returns:
        Version string (e.g., "0.1.0").

    Example:
        ```mojo
        from spdlog import version

        print("spdlog version:", version())
        ```
    """
    var ffi = SpdlogFFI()
    return ffi.version()


# -----------------------------------------------------------------------
# Logging Functions
# -----------------------------------------------------------------------


def trace(message: String) raises -> None:
    """Log a trace message.

    Trace messages are the most verbose and typically used for detailed
    debugging information.

    Args:
        message: Message to log.

    Example:
        ```mojo
        from spdlog import trace

        trace("Entering function foo()")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log_trace(message)


def debug(message: String) raises -> None:
    """Log a debug message.

    Debug messages are used for development and troubleshooting.

    Args:
        message: Message to log.

    Example:
        ```mojo
        from spdlog import debug

        debug("Variable x = 42")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log_debug(message)


def info(message: String) raises -> None:
    """Log an info message.

    Info messages are used for general information about program execution.

    Args:
        message: Message to log.

    Example:
        ```mojo
        from spdlog import info

        info("Application started successfully")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log_info(message)


def warn(message: String) raises -> None:
    """Log a warning message.

    Warning messages indicate potential issues that don't prevent
    the program from continuing.

    Args:
        message: Message to log.

    Example:
        ```mojo
        from spdlog import warn

        warn("Configuration file not found, using defaults")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log_warn(message)


def error(message: String) raises -> None:
    """Log an error message.

    Error messages indicate serious issues that may affect program functionality.

    Args:
        message: Message to log.

    Example:
        ```mojo
        from spdlog import error

        error("Failed to connect to database")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log_error(message)


def critical(message: String) raises -> None:
    """Log a critical message.

    Critical messages indicate severe errors that may prevent the program
    from continuing.

    Args:
        message: Message to log.

    Example:
        ```mojo
        from spdlog import critical

        critical("Out of memory, shutting down")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log_critical(message)


def log(level: UInt8, message: String) raises -> None:
    """Log a message with the specified level.

    This is a generic logging function that allows specifying the level
    dynamically.

    Args:
        level: Log level (use constants: TRACE, DEBUG, INFO, WARN, ERROR, CRITICAL, OFF).
        message: Message to log.

    Example:
        ```mojo
        from spdlog import log, INFO, ERROR

        log(INFO, "This is an info message")
        log(ERROR, "This is an error message")
        ```
    """
    var ffi = SpdlogFFI()
    ffi.log(level, message)


# -----------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------


def level_name(level: UInt8) -> String:
    """Get the name of a log level.

    Args:
        level: Log level (0-6).

    Returns:
        String name of the level ("TRACE", "DEBUG", etc.).

    Example:
        ```mojo
        from spdlog import level_name, get_level

        print("Current level:", level_name(get_level()))
        ```
    """
    if level == TRACE:
        return "TRACE"
    elif level == DEBUG:
        return "DEBUG"
    elif level == INFO:
        return "INFO"
    elif level == WARN:
        return "WARN"
    elif level == ERROR:
        return "ERROR"
    elif level == CRITICAL:
        return "CRITICAL"
    elif level == OFF:
        return "OFF"
    else:
        return "UNKNOWN"
