"""Unit tests for the loguru-style Logger API.

This test suite covers the modern Logger API including:
- Basic logging methods
- Level configuration
- String formatting
- Contextual binding (bind)
- File sinks
"""

from std.testing import assert_equal, assert_true, assert_false
from spdlog.logger import (
    get_logger,
    Logger,
    BoundLogger,
    _level_from_name,
    _level_to_name,
)
from spdlog import TRACE, DEBUG, INFO, WARN, ERROR, CRITICAL, OFF


def test_level_conversion() raises -> None:
    """Test level name to value conversion."""
    print("Testing level conversion...")

    assert_equal(_level_from_name("TRACE"), TRACE, "TRACE conversion")
    assert_equal(_level_from_name("DEBUG"), DEBUG, "DEBUG conversion")
    assert_equal(_level_from_name("INFO"), INFO, "INFO conversion")
    assert_equal(_level_from_name("WARN"), WARN, "WARN conversion")
    assert_equal(_level_from_name("WARNING"), WARN, "WARNING conversion")
    assert_equal(_level_from_name("ERROR"), ERROR, "ERROR conversion")
    assert_equal(_level_from_name("CRITICAL"), CRITICAL, "CRITICAL conversion")
    assert_equal(_level_from_name("OFF"), OFF, "OFF conversion")

    # Case insensitive
    assert_equal(_level_from_name("info"), INFO, "lowercase info")
    assert_equal(_level_from_name("Debug"), DEBUG, "mixed case Debug")

    # Default
    assert_equal(
        _level_from_name("UNKNOWN"), INFO, "unknown level defaults to INFO"
    )

    print("  ✓ Level conversion tests passed")


def test_level_to_name() raises -> None:
    """Test level value to name conversion."""
    print("Testing level to name conversion...")

    assert_equal(_level_to_name(TRACE), "TRACE", "TRACE name")
    assert_equal(_level_to_name(DEBUG), "DEBUG", "DEBUG name")
    assert_equal(_level_to_name(INFO), "INFO", "INFO name")
    assert_equal(_level_to_name(WARN), "WARN", "WARN name")
    assert_equal(_level_to_name(ERROR), "ERROR", "ERROR name")
    assert_equal(_level_to_name(CRITICAL), "CRITICAL", "CRITICAL name")
    assert_equal(_level_to_name(OFF), "OFF", "OFF name")
    assert_equal(_level_to_name(99), "UNKNOWN", "unknown level")

    print("  ✓ Level to name tests passed")


def test_logger_initialization() raises -> None:
    """Test logger initialization."""
    print("Testing logger initialization...")

    var log = get_logger()
    # Logger should start uninitialized
    # First call to any method should initialize it
    _ = log.get_level()

    print("  ✓ Logger initialization tests passed")


def test_logger_set_get_level() raises -> None:
    """Test setting and getting log level."""
    print("Testing set/get level...")

    var log = get_logger()

    # Set different levels
    log.set_level("DEBUG")
    assert_equal(log.get_level(), "DEBUG", "Level should be DEBUG")

    log.set_level("WARN")
    assert_equal(log.get_level(), "WARN", "Level should be WARN")

    log.set_level("ERROR")
    assert_equal(log.get_level(), "ERROR", "Level should be ERROR")

    # Reset to INFO for other tests
    log.set_level("INFO")

    print("  ✓ Set/get level tests passed")


def test_logger_version() raises -> None:
    """Test getting logger version."""
    print("Testing version...")

    var log = get_logger()
    var ver = log.version()
    assert_true(len(ver) > 0, "Version should not be empty")

    print("  ✓ Version test passed")


def test_bound_logger() raises -> None:
    """Test bound logger with context."""
    print("Testing bound logger...")

    var log = get_logger()
    log.set_level("DEBUG")

    # Create bound logger
    var bound = BoundLogger(INFO)
    bound._add_context("user_id", "123")
    bound._add_context("request_id", "abc")

    # Test that bound logger works (just verify no errors)
    bound.info("Test message")
    bound.warn("Warning message")

    print("  ✓ Bound logger tests passed")


def test_logger_formatting() raises -> None:
    """Test string formatting in logger."""
    print("Testing string formatting...")

    var log = get_logger()
    log.set_level("DEBUG")

    # Test formatting with different numbers of args
    log.info("No formatting")
    log.info("One arg: {}", "value1")
    log.info("Two args: {} and {}", "val1", "val2")
    log.info("Three args: {}, {}, {}", "a", "b", "c")

    print("  ✓ Formatting tests passed")


def test_logger_all_levels() raises -> None:
    """Test all logging levels."""
    print("Testing all logging levels...")

    var log = get_logger()
    log.set_level("TRACE")

    # Test all level methods
    log.trace("Trace message")
    log.debug("Debug message")
    log.info("Info message")
    log.warn("Warn message")
    log.error("Error message")
    log.critical("Critical message")

    # Test generic log method
    log.log("INFO", "Generic info message")
    log.log("ERROR", "Generic error message")

    print("  ✓ All levels tests passed")


def test_logger_level_filtering() raises -> None:
    """Test that level filtering works correctly."""
    print("Testing level filtering...")

    var log = get_logger()

    # Set to WARN level
    log.set_level("WARN")

    # These should not be logged
    log.trace("Should not appear")
    log.debug("Should not appear")
    log.info("Should not appear")

    # These should be logged
    log.warn("Should appear")
    log.error("Should appear")
    log.critical("Should appear")

    print("  ✓ Level filtering tests passed")


def test_logger_flush() raises -> None:
    """Test log flushing."""
    print("Testing flush...")

    var log = get_logger()
    log.info("Message before flush")
    log.flush()
    log.info("Message after flush")

    print("  ✓ Flush test passed")


def test_sink_management() raises -> None:
    """Test adding and removing sinks."""
    print("Testing sink management...")

    var log = get_logger()

    # Add a sink
    var sink_id = log.add("stdout", level="INFO")
    assert_true(sink_id >= 0, "Sink ID should be non-negative")

    # Remove the sink
    log.remove(sink_id)

    # Add multiple sinks
    var id1 = log.add("stdout", level="DEBUG")
    var id2 = log.add("stderr", level="WARN")
    assert_true(id1 != id2, "Different sinks should have different IDs")

    # Remove all
    log.remove_all()

    print("  ✓ Sink management tests passed")


def test_file_sink() raises -> None:
    """Test file sink functionality."""
    print("Testing file sink...")

    var log = get_logger()
    var log_file = "/tmp/test_logger_file.log"

    # Add file sink
    var sink_id = log.add(log_file, level="DEBUG")

    # Log some messages
    log.info("Test message 1")
    log.debug("Test message 2")
    log.flush()

    # Remove sink
    log.remove(sink_id)

    print("  ✓ File sink test passed")


def test_bind_chaining() raises -> None:
    """Test bind chaining."""
    print("Testing bind chaining...")

    var log = get_logger()
    log.set_level("DEBUG")

    # Create bound logger with chaining
    var bound = log.bind("user_id", "123")
    bound = bound.bind("username", "alice")
    bound = bound.bind("role", "admin")

    # Log with context
    bound.info("User action")
    bound.debug("Debug info")

    print("  ✓ Bind chaining test passed")


def main() raises -> None:
    """Run all logger tests."""
    print("=" * 50)
    print("Running Loguru-style Logger Tests")
    print("=" * 50)
    print()

    test_level_conversion()
    test_level_to_name()
    test_logger_initialization()
    test_logger_set_get_level()
    test_logger_version()
    test_bound_logger()
    test_logger_formatting()
    test_logger_all_levels()
    test_logger_level_filtering()
    test_logger_flush()
    test_sink_management()
    test_file_sink()
    test_bind_chaining()

    print()
    print("=" * 50)
    print("All tests passed! ✓")
    print("=" * 50)
