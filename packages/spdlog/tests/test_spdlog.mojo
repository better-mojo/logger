"""Unit tests for the spdlog library.

Run with: mojo test tests/test_spdlog.mojo
"""

from std.testing import assert_equal, assert_true, assert_false
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
    OFF,
)
from spdlog.ffi import SpdlogFFI


# -----------------------------------------------------------------------
# Logger Initialization Tests
# -----------------------------------------------------------------------


def test_init_logger() raises -> None:
    """Test logger initialization."""
    var result = init_logger()
    assert_true(result, "Logger initialization should succeed")


def test_init_logger_multiple() raises -> None:
    """Test that multiple initializations don't fail."""
    assert_true(init_logger())
    assert_true(init_logger())
    assert_true(init_logger())


# -----------------------------------------------------------------------
# Log Level Tests
# -----------------------------------------------------------------------


def test_set_and_get_level() raises -> None:
    """Test setting and getting log level."""
    init_logger()

    # Set to INFO and verify
    set_level(INFO)
    var level = get_level()
    assert_equal(level, INFO, "Log level should be INFO")

    # Set to WARN and verify
    set_level(WARN)
    level = get_level()
    assert_equal(level, WARN, "Log level should be WARN")

    # Set to ERROR and verify
    set_level(ERROR)
    level = get_level()
    assert_equal(level, ERROR, "Log level should be ERROR")


def test_all_log_levels() raises -> None:
    """Test all valid log levels."""
    init_logger()

    # Test each level individually
    set_level(TRACE)
    assert_true(get_level() <= OFF, "TRACE should be in valid range")

    set_level(DEBUG)
    assert_true(get_level() <= OFF, "DEBUG should be in valid range")

    set_level(INFO)
    assert_true(get_level() <= OFF, "INFO should be in valid range")

    set_level(WARN)
    assert_true(get_level() <= OFF, "WARN should be in valid range")

    set_level(ERROR)
    assert_true(get_level() <= OFF, "ERROR should be in valid range")

    set_level(CRITICAL)
    assert_true(get_level() <= OFF, "CRITICAL should be in valid range")

    set_level(OFF)
    assert_true(get_level() <= OFF, "OFF should be in valid range")


# -----------------------------------------------------------------------
# Version Tests
# -----------------------------------------------------------------------


def test_version() raises -> None:
    """Test getting library version."""
    var ver = version()
    assert_true(len(ver) > 0, "Version should not be empty")
    assert_true("." in ver, "Version should contain a dot")


def test_version_format() raises -> None:
    """Test version format."""
    var ver = version()
    var parts = ver.split(".")
    assert_true(len(parts) >= 2, "Version should have at least major.minor")


# -----------------------------------------------------------------------
# Logging Function Tests
# -----------------------------------------------------------------------


def test_trace() raises -> None:
    """Test trace logging."""
    init_logger()
    set_level(TRACE)
    trace("Test trace message")


def test_debug() raises -> None:
    """Test debug logging."""
    init_logger()
    set_level(DEBUG)
    debug("Test debug message")


def test_info() raises -> None:
    """Test info logging."""
    init_logger()
    set_level(INFO)
    info("Test info message")


def test_warn() raises -> None:
    """Test warn logging."""
    init_logger()
    set_level(WARN)
    warn("Test warn message")


def test_error() raises -> None:
    """Test error logging."""
    init_logger()
    set_level(ERROR)
    error("Test error message")


def test_critical() raises -> None:
    """Test critical logging."""
    init_logger()
    set_level(CRITICAL)
    critical("Test critical message")


def test_log_all_levels() raises -> None:
    """Test generic log function with all levels."""
    init_logger()
    set_level(TRACE)

    log(TRACE, "Generic trace message")
    log(DEBUG, "Generic debug message")
    log(INFO, "Generic info message")
    log(WARN, "Generic warn message")
    log(ERROR, "Generic error message")
    log(CRITICAL, "Generic critical message")


def test_log_with_empty_message() raises -> None:
    """Test logging empty message."""
    init_logger()
    set_level(INFO)
    info("")


def test_log_with_long_message() raises -> None:
    """Test logging long message."""
    init_logger()
    set_level(INFO)
    var long_msg = String()
    for _ in range(100):
        long_msg += "a"
    info(long_msg)


def test_log_with_unicode() raises -> None:
    """Test logging unicode message."""
    init_logger()
    set_level(INFO)
    info("Unicode test: hello world")


# -----------------------------------------------------------------------
# Flush Tests
# -----------------------------------------------------------------------


def test_flush() raises -> None:
    """Test flush function."""
    init_logger()
    flush()


def test_flush_after_logs() raises -> None:
    """Test flush after logging."""
    init_logger()
    set_level(INFO)
    info("Message before flush")
    debug("Debug message before flush")
    flush()
    info("Message after flush")


# -----------------------------------------------------------------------
# Level Name Tests
# -----------------------------------------------------------------------


def test_level_names() raises -> None:
    """Test level name mapping."""
    assert_equal(level_name(TRACE), "TRACE")
    assert_equal(level_name(DEBUG), "DEBUG")
    assert_equal(level_name(INFO), "INFO")
    assert_equal(level_name(WARN), "WARN")
    assert_equal(level_name(ERROR), "ERROR")
    assert_equal(level_name(CRITICAL), "CRITICAL")
    assert_equal(level_name(OFF), "OFF")


def test_level_name_unknown() raises -> None:
    """Test level name for unknown level."""
    assert_equal(level_name(255), "UNKNOWN")


# -----------------------------------------------------------------------
# Integration Tests
# -----------------------------------------------------------------------


def test_full_workflow() raises -> None:
    """Test a complete logging workflow."""
    # 1. Initialize
    assert_true(init_logger())

    # 2. Get version
    var ver = version()
    assert_true(len(ver) > 0)

    # 3. Set level to DEBUG
    set_level(DEBUG)
    assert_equal(get_level(), DEBUG)

    # 4. Log at various levels
    debug("Debug message in workflow")
    info("Info message in workflow")
    warn("Warn message in workflow")

    # 5. Flush
    flush()

    # 6. Change level to WARN
    set_level(WARN)
    assert_equal(get_level(), WARN)

    # 7. Log more messages
    info("This should be filtered")  # Won't show
    warn("This should show")
    error("This should also show")

    # 8. Final flush
    flush()


def test_log_level_filtering() raises -> None:
    """Test that log level filtering works correctly."""
    init_logger()

    # Set to WARN level
    set_level(WARN)

    # These should be filtered out
    trace("Trace - filtered")
    debug("Debug - filtered")
    info("Info - filtered")

    # These should be logged
    warn("Warn - visible")
    error("Error - visible")
    critical("Critical - visible")

    flush()


# -----------------------------------------------------------------------
# FFI Direct Tests
# -----------------------------------------------------------------------


def test_ffi_init() raises -> None:
    """Test direct FFI initialization."""
    var ffi = SpdlogFFI()
    var result = ffi.logger_init()
    assert_true(result)


def test_ffi_version() raises -> None:
    """Test direct FFI version call."""
    var ffi = SpdlogFFI()
    var ver = ffi.version()
    assert_true(len(ver) > 0)


def test_ffi_log_levels() raises -> None:
    """Test direct FFI log level operations."""
    var ffi = SpdlogFFI()
    ffi.logger_init()

    ffi.set_level(DEBUG)
    assert_equal(ffi.get_level(), DEBUG)

    ffi.set_level(INFO)
    assert_equal(ffi.get_level(), INFO)

    ffi.set_level(ERROR)
    assert_equal(ffi.get_level(), ERROR)


def test_ffi_logging() raises -> None:
    """Test direct FFI logging functions."""
    var ffi = SpdlogFFI()
    ffi.logger_init()
    ffi.set_level(TRACE)

    ffi.log_trace("FFI trace")
    ffi.log_debug("FFI debug")
    ffi.log_info("FFI info")
    ffi.log_warn("FFI warn")
    ffi.log_error("FFI error")
    ffi.log_critical("FFI critical")
    ffi.log(INFO, "FFI generic log")


def test_ffi_flush() raises -> None:
    """Test direct FFI flush."""
    var ffi = SpdlogFFI()
    ffi.logger_init()
    ffi.flush()


# -----------------------------------------------------------------------
# Main entry point for running tests
# -----------------------------------------------------------------------


def main() raises -> None:
    """Run all tests."""
    print("Running spdlog unit tests...")
    print()

    # Initialization tests
    print("Testing initialization...")
    test_init_logger()
    test_init_logger_multiple()
    print("  ✓ Initialization tests passed")

    # Log level tests
    print("Testing log levels...")
    test_set_and_get_level()
    test_all_log_levels()
    print("  ✓ Log level tests passed")

    # Version tests
    print("Testing version...")
    test_version()
    test_version_format()
    print("  ✓ Version tests passed")

    # Logging function tests
    print("Testing logging functions...")
    test_trace()
    test_debug()
    test_info()
    test_warn()
    test_error()
    test_critical()
    test_log_all_levels()
    test_log_with_empty_message()
    test_log_with_long_message()
    test_log_with_unicode()
    print("  ✓ Logging function tests passed")

    # Flush tests
    print("Testing flush...")
    test_flush()
    test_flush_after_logs()
    print("  ✓ Flush tests passed")

    # Level name tests
    print("Testing level names...")
    test_level_names()
    test_level_name_unknown()
    print("  ✓ Level name tests passed")

    # Integration tests
    print("Testing integration...")
    test_full_workflow()
    test_log_level_filtering()
    print("  ✓ Integration tests passed")

    # FFI direct tests
    print("Testing FFI direct calls...")
    test_ffi_init()
    test_ffi_version()
    test_ffi_log_levels()
    test_ffi_logging()
    test_ffi_flush()
    print("  ✓ FFI direct tests passed")

    print()
    print("All tests passed! ✓")
