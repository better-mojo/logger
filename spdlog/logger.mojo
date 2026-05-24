"""Loguru-style modern logging API for spdlog.

This module provides a high-level, easy-to-use logging interface inspired by
Python's loguru library. It wraps the low-level spdlog FFI bindings with a
more ergonomic API.

Key Features:
- Ready to use out of the box (no initialization required)
- Modern string formatting with {} placeholders
- Contextual logging with bind()
- Multiple sinks with different levels and formats
- Fluent API for easy configuration

Example:
    from spdlog.logger import get_logger
    
    def main() raises:
        var log = get_logger()
        log.info("Hello, World!")
        log.debug("Debug info: {}", "value")
        
        # Add file output
        log.add("/tmp/app.log", level="DEBUG")
        
        # Contextual logging
        var user_log = log.bind("user_id", "12345")
        user_log.info("User logged in")
"""

from spdlog import (
    init_logger,
    init_file_logger,
    set_level,
    get_level,
    flush,
    trace,
    debug,
    info,
    warn,
    error,
    critical,
    log,
    version,
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    CRITICAL,
    OFF,
)


# ============================================================================
# Level Helpers
# ============================================================================


def _level_from_name(name: String) -> UInt8:
    """Convert level name to numeric value."""
    var upper = name.upper()
    if upper == "TRACE":
        return TRACE
    elif upper == "DEBUG":
        return DEBUG
    elif upper == "INFO":
        return INFO
    elif upper == "WARN" or upper == "WARNING":
        return WARN
    elif upper == "ERROR":
        return ERROR
    elif upper == "CRITICAL":
        return CRITICAL
    elif upper == "OFF":
        return OFF
    else:
        return INFO  # Default


def _level_to_name(level: UInt8) -> String:
    """Convert level value to name."""
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


# ============================================================================
# Sink Configuration
# ============================================================================


struct SinkConfig(Movable):
    """Configuration for a log sink."""

    var sink: String
    var level: UInt8
    var format: String
    var filter: String
    var colorize: Bool
    var serialize: Bool
    var rotation: String
    var retention: String
    var compression: String

    def __init__(
        out self,
        sink: String,
        level: UInt8,
        format: String,
        filter: String,
        colorize: Bool,
        serialize: Bool,
        rotation: String,
        retention: String,
        compression: String,
    ):
        self.sink = sink
        self.level = level
        self.format = format
        self.filter = filter
        self.colorize = colorize
        self.serialize = serialize
        self.rotation = rotation
        self.retention = retention
        self.compression = compression

    def __init__(out self, *, deinit take: Self):
        """Move constructor."""
        self.sink = take.sink^
        self.level = take.level
        self.format = take.format^
        self.filter = take.filter^
        self.colorize = take.colorize
        self.serialize = take.serialize
        self.rotation = take.rotation^
        self.retention = take.retention^
        self.compression = take.compression^


# ============================================================================
# Bound Logger (Contextual Logging)
# ============================================================================


struct BoundLogger(Movable):
    """A logger with bound context fields.

    BoundLogger is created by calling bind() on a Logger. It carries
    context fields that are automatically added to all log messages.

    Example:
        var user_log = logger.bind("user_id", "12345")
        user_log.info("Logged in")  # Output includes user_id=12345
    """

    var _context_keys: List[String]
    var _context_values: List[String]
    var _level: UInt8

    def __init__(out self, level: UInt8 = INFO):
        """Create a new BoundLogger with specified level."""
        self._context_keys = List[String]()
        self._context_values = List[String]()
        self._level = level

    def __init__(out self, *, deinit take: Self):
        """Move constructor."""
        self._context_keys = take._context_keys^
        self._context_values = take._context_values^
        self._level = take._level

    def _add_context(mut self, key: String, value: String):
        """Add a context field (internal use)."""
        self._context_keys.append(key)
        self._context_values.append(value)

    def bind(mut self, key: String, value: String) -> Self:
        """Create a new bound logger with additional context."""
        var new_logger = Self(self._level)
        # Copy existing context
        for i in range(len(self._context_keys)):
            new_logger._add_context(
                self._context_keys[i], self._context_values[i]
            )
        # Add new context
        new_logger._add_context(key, value)
        return new_logger^

    def _format_message(self, message: String) -> String:
        """Format message with context fields."""
        if len(self._context_keys) == 0:
            return message

        var result = message
        result += " |"
        for i in range(len(self._context_keys)):
            result += (
                " " + self._context_keys[i] + "=" + self._context_values[i]
            )
        return result

    # ------------------------------------------------------------------------
    # Logging Methods
    # ------------------------------------------------------------------------

    def trace(mut self, message: String) raises:
        """Log a trace message with context."""
        if self._level <= TRACE:
            trace(self._format_message(message))

    def debug(mut self, message: String) raises:
        """Log a debug message with context."""
        if self._level <= DEBUG:
            debug(self._format_message(message))

    def info(mut self, message: String) raises:
        """Log an info message with context."""
        if self._level <= INFO:
            info(self._format_message(message))

    def warn(mut self, message: String) raises:
        """Log a warning message with context."""
        if self._level <= WARN:
            warn(self._format_message(message))

    def error(mut self, message: String) raises:
        """Log an error message with context."""
        if self._level <= ERROR:
            error(self._format_message(message))

    def critical(mut self, message: String) raises:
        """Log a critical message with context."""
        if self._level <= CRITICAL:
            critical(self._format_message(message))

    def log(mut self, level: String, message: String) raises:
        """Log a message at the specified level with context."""
        var level_val = _level_from_name(level)
        if self._level <= level_val:
            var formatted = self._format_message(message)
            if level_val == TRACE:
                trace(formatted)
            elif level_val == DEBUG:
                debug(formatted)
            elif level_val == INFO:
                info(formatted)
            elif level_val == WARN:
                warn(formatted)
            elif level_val == ERROR:
                error(formatted)
            elif level_val == CRITICAL:
                critical(formatted)


# ============================================================================
# Main Logger
# ============================================================================


struct Logger:
    """Loguru-style logger with modern API.

    This logger provides an easy-to-use interface inspired by Python's loguru.
    It supports multiple sinks, contextual logging, and modern string formatting.

    The logger is ready to use immediately - no initialization required.
    It defaults to console output with INFO level.

    Example:
        var log = get_logger()
        log.info("Application started")

        # Add file output
        log.add("/tmp/app.log", level="DEBUG")

        # Contextual logging
        var user_log = log.bind("user_id", "12345")
        user_log.info("User action")
    """

    var _sinks: List[SinkConfig]
    var _level: UInt8
    var _initialized: Bool

    def __init__(out self):
        """Create a new Logger instance."""
        self._sinks = List[SinkConfig]()
        self._level = INFO
        self._initialized = False

    def _ensure_initialized(mut self) raises:
        """Ensure the logger is initialized."""
        if not self._initialized:
            _ = init_logger()
            self._initialized = True

    # ------------------------------------------------------------------------
    # Configuration
    # ------------------------------------------------------------------------

    def add(
        mut self,
        sink: String,
        level: String = "INFO",
        format: String = "",
        filter: String = "",
        colorize: Bool = True,
        serialize: Bool = False,
        rotation: String = "",
        retention: String = "",
        compression: String = "",
    ) raises -> Int:
        """Add a new sink to the logger.

        Args:
            sink: Sink destination ("stdout", "stderr", or file path)
            level: Minimum level for this sink ("TRACE", "DEBUG", "INFO", etc.)
            format: Optional format string
            filter: Optional filter pattern
            colorize: Whether to use colors for console output
            serialize: Whether to output as JSON
            rotation: Rotation policy (e.g., "10 MB", "1 day")
            retention: Retention policy (e.g., "30 days")
            compression: Compression format (e.g., "gz")

        Returns:
            Sink ID that can be used with remove()

        Example:
            log.add("/tmp/app.log", level="DEBUG")
            log.add("stdout", level="INFO", colorize=True)
        """
        self._ensure_initialized()

        var level_val = _level_from_name(level)
        var config = SinkConfig(
            sink=sink,
            level=level_val,
            format=format,
            filter=filter,
            colorize=colorize,
            serialize=serialize,
            rotation=rotation,
            retention=retention,
            compression=compression,
        )

        # Initialize file logger if needed
        if sink != "stdout" and sink != "stderr":
            _ = init_file_logger(sink)

        self._sinks.append(config^)

        # Update global level if this sink has lower level
        if level_val < self._level:
            self._level = level_val
            set_level(self._level)

        return len(self._sinks) - 1

    def remove(mut self, sink_id: Int) raises:
        """Remove a sink by ID.

        Args:
            sink_id: The ID returned by add()
        """
        self._ensure_initialized()
        if sink_id >= 0 and sink_id < len(self._sinks):
            # Mark as removed (in a real implementation, we'd properly remove)
            # For now, just set level to OFF
            self._sinks[sink_id].level = OFF

    def remove_all(mut self) raises:
        """Remove all sinks."""
        self._ensure_initialized()
        self._sinks.clear()

    def set_level(mut self, level: String) raises:
        """Set the global log level.

        Args:
            level: Level name ("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL", "OFF")
        """
        self._ensure_initialized()
        self._level = _level_from_name(level)
        set_level(self._level)

    def get_level(mut self) raises -> String:
        """Get the current log level name."""
        self._ensure_initialized()
        return _level_to_name(self._level)

    # ------------------------------------------------------------------------
    # Contextual Logging
    # ------------------------------------------------------------------------

    def bind(mut self, key: String, value: String) raises -> BoundLogger:
        """Create a bound logger with a context field.

        Args:
            key: Context field name
            value: Context field value

        Returns:
            A BoundLogger that includes this context in all messages

        Example:
            var user_log = log.bind("user_id", "12345")
            user_log.info("Logged in")  # Output: Logged in | user_id=12345
        """
        self._ensure_initialized()
        var bound = BoundLogger(self._level)
        bound._add_context(key, value)
        return bound^

    # ------------------------------------------------------------------------
    # String Formatting Helper
    # ------------------------------------------------------------------------

    def _format(
        self, message: String, arg1: String, arg2: String, arg3: String
    ) -> String:
        """Format message with {} placeholders."""
        var result = message

        # Replace first {}
        if arg1 != "":
            var byte_len = result.byte_length()
            for i in range(byte_len - 1):
                if result[byte=i] == "{" and result[byte=i + 1] == "}":
                    # Find the position and do string replacement
                    var before = String()
                    for j in range(i):
                        before += result[byte=j]
                    var after = String()
                    for j in range(i + 2, byte_len):
                        after += result[byte=j]
                    result = before + arg1 + after
                    break

        # Replace second {}
        if arg2 != "":
            var byte_len = result.byte_length()
            for i in range(byte_len - 1):
                if result[byte=i] == "{" and result[byte=i + 1] == "}":
                    var before = String()
                    for j in range(i):
                        before += result[byte=j]
                    var after = String()
                    for j in range(i + 2, byte_len):
                        after += result[byte=j]
                    result = before + arg2 + after
                    break

        # Replace third {}
        if arg3 != "":
            var byte_len = result.byte_length()
            for i in range(byte_len - 1):
                if result[byte=i] == "{" and result[byte=i + 1] == "}":
                    var before = String()
                    for j in range(i):
                        before += result[byte=j]
                    var after = String()
                    for j in range(i + 2, byte_len):
                        after += result[byte=j]
                    result = before + arg3 + after
                    break

        return result

    # ------------------------------------------------------------------------
    # Logging Methods
    # ------------------------------------------------------------------------

    def trace(
        mut self,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log a trace message.

        Args:
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        if self._level <= TRACE:
            trace(self._format(message, arg1, arg2, arg3))

    def debug(
        mut self,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log a debug message.

        Args:
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        if self._level <= DEBUG:
            debug(self._format(message, arg1, arg2, arg3))

    def info(
        mut self,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log an info message.

        Args:
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        if self._level <= INFO:
            info(self._format(message, arg1, arg2, arg3))

    def warn(
        mut self,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log a warning message.

        Args:
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        if self._level <= WARN:
            warn(self._format(message, arg1, arg2, arg3))

    def error(
        mut self,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log an error message.

        Args:
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        if self._level <= ERROR:
            error(self._format(message, arg1, arg2, arg3))

    def critical(
        mut self,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log a critical message.

        Args:
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        if self._level <= CRITICAL:
            critical(self._format(message, arg1, arg2, arg3))

    def log(
        mut self,
        level: String,
        message: String,
        arg1: String = "",
        arg2: String = "",
        arg3: String = "",
    ) raises:
        """Log a message at the specified level.

        Args:
            level: Level name ("TRACE", "DEBUG", "INFO", etc.)
            message: Log message with optional {} placeholders
            arg1: First format argument
            arg2: Second format argument
            arg3: Third format argument
        """
        self._ensure_initialized()
        var level_val = _level_from_name(level)
        if self._level <= level_val:
            var formatted = self._format(message, arg1, arg2, arg3)
            if level_val == TRACE:
                trace(formatted)
            elif level_val == DEBUG:
                debug(formatted)
            elif level_val == INFO:
                info(formatted)
            elif level_val == WARN:
                warn(formatted)
            elif level_val == ERROR:
                error(formatted)
            elif level_val == CRITICAL:
                critical(formatted)

    # ------------------------------------------------------------------------
    # Utility
    # ------------------------------------------------------------------------

    def flush(mut self) raises:
        """Flush all log buffers."""
        self._ensure_initialized()
        flush()

    def version(mut self) raises -> String:
        """Get the spdlog version."""
        self._ensure_initialized()
        return version()


# ============================================================================
# Factory Function
# ============================================================================


def get_logger() -> Logger:
    """Get a new logger instance.

    Returns:
        A new Logger ready to use

    Example:
        var log = get_logger()
        log.info("Hello, World!")
    """
    return Logger()


# global logger instance
comptime logger = get_logger()
