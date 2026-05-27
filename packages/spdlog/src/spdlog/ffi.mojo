"""Low-level FFI wrappers for the spdlog library.

All handles are stored as Int (pointer address). Input C strings are passed
as Int via unsafe_ptr() -> Int cast. Output C-string return values are received
as UnsafePointer[UInt8, MutExternalOrigin] and immediately copied into owned
String values via StringSlice.

The library is loaded at runtime via OwnedDLHandle so Mojo's JIT never needs
to resolve symbols at compile time.

Do not call SpdlogFFI methods from user code -- use the high-level API in __init__.mojo.
"""

from std.ffi import OwnedDLHandle, RTLD
from std.os import getenv
from std.sys.info import CompilationTarget
from std.memory import UnsafePointer, alloc


# -----------------------------------------------------------------------
# Log Level Constants (must match RsLogLevel in Rust)
# -----------------------------------------------------------------------

comptime LOG_LEVEL_TRACE = 0
comptime LOG_LEVEL_DEBUG = 1
comptime LOG_LEVEL_INFO = 2
comptime LOG_LEVEL_WARN = 3
comptime LOG_LEVEL_ERROR = 4
comptime LOG_LEVEL_CRITICAL = 5
comptime LOG_LEVEL_OFF = 6


# -----------------------------------------------------------------------
# Internal helpers
# -----------------------------------------------------------------------


def _ptr_to_string(p: UnsafePointer[UInt8, MutExternalOrigin]) -> String:
    """Copy a C string at p into an owned Mojo String.

    Args:
        p: Pointer to a null-terminated UTF-8 string returned by the library.
           Null pointer returns an empty string.

    Returns:
        Owned String copy, or empty string for null pointers.
    """
    if not p:
        return String("")
    return String(StringSlice(unsafe_from_utf8_ptr=p))


def _find_spdlog_library() -> String:
    """Locate libspdlog_ffi via $CONDA_PREFIX (pixi) or bare soname.

    Search order:
    1. $CONDA_PREFIX/lib/libspdlog_ffi.so (Linux) or
       $CONDA_PREFIX/lib/libspdlog_ffi.dylib (macOS) when set.
    2. Bare soname, relying on LD_LIBRARY_PATH / dyld path.

    Returns:
        Library path string for OwnedDLHandle.
    """
    var prefix = getenv("CONDA_PREFIX", "")
    if prefix:
        comptime if CompilationTarget.is_linux():
            return prefix + "/lib/libspdlog_ffi.so"
        else:
            return prefix + "/lib/libspdlog_ffi.dylib"
    comptime if CompilationTarget.is_linux():
        return "libspdlog_ffi.so"
    else:
        return "libspdlog_ffi.dylib"


# -----------------------------------------------------------------------
# SpdlogFFI
# -----------------------------------------------------------------------


struct SpdlogFFI(Movable):
    """Runtime-loaded spdlog FFI: dlopen + dlsym for all C entry-points.

    Loads libspdlog_ffi at construction via OwnedDLHandle and resolves
    every function pointer via get_function. All opaque pointer arguments
    are represented as Int (64-bit on all supported platforms), matching
    the C ABI on x86-64 and arm64.

    The OS reference-counts the underlying shared library, so multiple
    concurrent OwnedDLHandle objects map to a single loaded image.
    RTLD.NODELETE ensures dlclose is a no-op: the library stays
    resident for the process lifetime.
    """

    var _lib: OwnedDLHandle

    # -- Logger initialization and configuration --------------------------------
    var _fn_rs_logger_init: def() thin abi("C") -> Bool
    var _fn_rs_logger_set_level: def(UInt8) thin abi("C") -> None
    var _fn_rs_logger_get_level: def() thin abi("C") -> UInt8
    var _fn_rs_logger_flush: def() thin abi("C") -> None
    var _fn_rs_logger_init_file: def(
        UnsafePointer[UInt8, MutExternalOrigin]
    ) thin abi("C") -> Bool
    var _fn_rs_logger_version: def() thin abi("C") -> UnsafePointer[
        UInt8, MutExternalOrigin
    ]
    var _fn_free_rs_string: def(
        UnsafePointer[UInt8, MutExternalOrigin]
    ) thin abi("C") -> None

    # -- Logging functions ------------------------------------------------------
    var _fn_rs_log_trace: def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi(
        "C"
    ) -> None
    var _fn_rs_log_debug: def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi(
        "C"
    ) -> None
    var _fn_rs_log_info: def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi(
        "C"
    ) -> None
    var _fn_rs_log_warn: def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi(
        "C"
    ) -> None
    var _fn_rs_log_error: def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi(
        "C"
    ) -> None
    var _fn_rs_log_critical: def(
        UnsafePointer[UInt8, MutExternalOrigin]
    ) thin abi("C") -> None
    var _fn_rs_log: def(
        UInt8, UnsafePointer[UInt8, MutExternalOrigin]
    ) thin abi("C") -> None

    def __init__(out self, lib_path: String = "") raises:
        """Load libspdlog_ffi and resolve all function pointers.

        Args:
            lib_path: Explicit path to the library. If empty,
                      _find_spdlog_library() is used (honours $CONDA_PREFIX).

        Raises:
            Error: If the library cannot be opened or a symbol is missing.
        """
        var path = lib_path if lib_path else _find_spdlog_library()
        # RTLD.NODELETE: dlclose() becomes a no-op for this handle.
        self._lib = OwnedDLHandle(path, RTLD.NOW | RTLD.GLOBAL | RTLD.NODELETE)

        # Logger initialization and configuration
        self._fn_rs_logger_init = self._lib.get_function[
            def() thin abi("C") -> Bool
        ]("rs_logger_init")
        self._fn_rs_logger_set_level = self._lib.get_function[
            def(UInt8) thin abi("C") -> None
        ]("rs_logger_set_level")
        self._fn_rs_logger_get_level = self._lib.get_function[
            def() thin abi("C") -> UInt8
        ]("rs_logger_get_level")
        self._fn_rs_logger_flush = self._lib.get_function[
            def() thin abi("C") -> None
        ]("rs_logger_flush")
        self._fn_rs_logger_init_file = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> Bool
        ]("rs_logger_init_file")
        self._fn_rs_logger_version = self._lib.get_function[
            def() thin abi("C") -> UnsafePointer[UInt8, MutExternalOrigin]
        ]("rs_logger_version")
        self._fn_free_rs_string = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("free_rs_string")

        # Logging functions
        self._fn_rs_log_trace = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("rs_log_trace")
        self._fn_rs_log_debug = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("rs_log_debug")
        self._fn_rs_log_info = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("rs_log_info")
        self._fn_rs_log_warn = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("rs_log_warn")
        self._fn_rs_log_error = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("rs_log_error")
        self._fn_rs_log_critical = self._lib.get_function[
            def(UnsafePointer[UInt8, MutExternalOrigin]) thin abi("C") -> None
        ]("rs_log_critical")
        self._fn_rs_log = self._lib.get_function[
            def(
                UInt8, UnsafePointer[UInt8, MutExternalOrigin]
            ) thin abi("C") -> None
        ]("rs_log")

    # -- Logger initialization and configuration --------------------------------

    def logger_init(self) -> Bool:
        """Initialize the default logger.

        Returns:
            True if initialization succeeded.
        """
        return self._fn_rs_logger_init()

    def init_file_logger(self, path: String) -> Bool:
        """Initialize a file logger.

        Args:
            path: Path to the log file.

        Returns:
            True if initialization succeeded.
        """
        # Convert path to null-terminated bytes
        var path_bytes = path.as_bytes()
        var path_ptr = alloc[UInt8](len(path_bytes) + 1)
        for i in range(len(path_bytes)):
            path_ptr[i] = path_bytes[i]
        path_ptr[len(path_bytes)] = 0  # Null terminator
        var result = self._fn_rs_logger_init_file(path_ptr)
        path_ptr.free()
        return result

    def set_level(self, level: UInt8) -> None:
        """Set the log level filter.

        Args:
            level: Log level (0=Trace, 1=Debug, 2=Info, 3=Warn, 4=Error, 5=Critical, 6=Off).
        """
        self._fn_rs_logger_set_level(level)

    def get_level(self) -> UInt8:
        """Get the current log level filter.

        Returns:
            Current log level.
        """
        return self._fn_rs_logger_get_level()

    def flush(self) -> None:
        """Flush the log buffer."""
        self._fn_rs_logger_flush()

    def version(self) -> String:
        """Get the library version.

        Returns:
            Version string (e.g., "0.1.0").
        """
        var raw = self._fn_rs_logger_version()
        var result = _ptr_to_string(raw)
        self._fn_free_rs_string(raw)
        return result

    # -- Logging functions ------------------------------------------------------

    def _string_to_ptr(
        self, message: String
    ) -> UnsafePointer[UInt8, MutExternalOrigin]:
        """Convert a Mojo String to a C-compatible pointer.

        Args:
            message: The string to convert.

        Returns:
            A pointer to null-terminated bytes that must be freed by the caller.
        """
        var msg_bytes = message.as_bytes()
        var ptr = alloc[UInt8](len(msg_bytes) + 1)
        for i in range(len(msg_bytes)):
            ptr[i] = msg_bytes[i]
        ptr[len(msg_bytes)] = 0  # Null terminator
        return ptr

    def log_trace(self, message: String) -> None:
        """Log a trace message.

        Args:
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log_trace(ptr)
        ptr.free()

    def log_debug(self, message: String) -> None:
        """Log a debug message.

        Args:
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log_debug(ptr)
        ptr.free()

    def log_info(self, message: String) -> None:
        """Log an info message.

        Args:
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log_info(ptr)
        ptr.free()

    def log_warn(self, message: String) -> None:
        """Log a warning message.

        Args:
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log_warn(ptr)
        ptr.free()

    def log_error(self, message: String) -> None:
        """Log an error message.

        Args:
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log_error(ptr)
        ptr.free()

    def log_critical(self, message: String) -> None:
        """Log a critical message.

        Args:
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log_critical(ptr)
        ptr.free()

    def log(self, level: UInt8, message: String) -> None:
        """Log a message with the specified level.

        Args:
            level: Log level (0=Trace, 1=Debug, 2=Info, 3=Warn, 4=Error, 5=Critical, 6=Off).
            message: Message to log.
        """
        var ptr = self._string_to_ptr(message)
        self._fn_rs_log(level, ptr)
        ptr.free()
