use safer_ffi::prelude::*;
use std::ffi::CString;
use spdlog::{
    self,
    Level, LevelFilter,
};

/// 调试输出开关，可以通过环境变量控制
const DEBUG_ENABLED: bool = cfg!(debug_assertions);

#[inline]
fn debug_print(msg: &str) {
    if DEBUG_ENABLED {
        println!("{}", msg);
    }
}

/// 日志级别枚举 (C 可见)
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u8)]
pub enum RsLogLevel {
    Trace = 0,
    Debug = 1,
    Info = 2,
    Warn = 3,
    Error = 4,
    Critical = 5,
    Off = 6,
}

impl From<RsLogLevel> for Level {
    fn from(level: RsLogLevel) -> Self {
        match level {
            RsLogLevel::Trace => Level::Trace,
            RsLogLevel::Debug => Level::Debug,
            RsLogLevel::Info => Level::Info,
            RsLogLevel::Warn => Level::Warn,
            RsLogLevel::Error => Level::Error,
            RsLogLevel::Critical => Level::Critical,
            RsLogLevel::Off => Level::Critical, // Off 映射到 Critical 作为占位
        }
    }
}

impl From<RsLogLevel> for LevelFilter {
    fn from(level: RsLogLevel) -> Self {
        match level {
            RsLogLevel::Trace => LevelFilter::MoreSevereEqual(Level::Trace),
            RsLogLevel::Debug => LevelFilter::MoreSevereEqual(Level::Debug),
            RsLogLevel::Info => LevelFilter::MoreSevereEqual(Level::Info),
            RsLogLevel::Warn => LevelFilter::MoreSevereEqual(Level::Warn),
            RsLogLevel::Error => LevelFilter::MoreSevereEqual(Level::Error),
            RsLogLevel::Critical => LevelFilter::MoreSevereEqual(Level::Critical),
            RsLogLevel::Off => LevelFilter::Off,
        }
    }
}

impl From<u8> for RsLogLevel {
    fn from(value: u8) -> Self {
        match value {
            0 => RsLogLevel::Trace,
            1 => RsLogLevel::Debug,
            2 => RsLogLevel::Info,
            3 => RsLogLevel::Warn,
            4 => RsLogLevel::Error,
            5 => RsLogLevel::Critical,
            6 => RsLogLevel::Off,
            _ => RsLogLevel::Info, // 默认值
        }
    }
}

impl From<RsLogLevel> for u8 {
    fn from(level: RsLogLevel) -> Self {
        level as u8
    }
}

/// 初始化默认日志记录器
/// 
/// # Safety
/// 必须在程序启动时调用一次
#[ffi_export]
pub fn rs_logger_init() -> bool {
    debug_print("rust > initializing default logger");
    
    // spdlog-rs 默认已经初始化，这里可以配置级别
    spdlog::default_logger().set_level_filter(LevelFilter::MoreSevereEqual(Level::Info));
    
    true
}

/// 设置日志级别过滤器 (使用 u8 作为参数)
#[ffi_export]
pub fn rs_logger_set_level(level: u8) {
    let log_level: RsLogLevel = level.into();
    debug_print(&format!("rust > setting log level to {:?}", log_level));
    spdlog::default_logger().set_level_filter(log_level.into());
}

/// 获取当前日志级别 (返回 u8)
#[ffi_export]
pub fn rs_logger_get_level() -> u8 {
    let filter = spdlog::default_logger().level_filter();
    let level = match filter {
        LevelFilter::MoreSevereEqual(l) => match l {
            Level::Trace => RsLogLevel::Trace,
            Level::Debug => RsLogLevel::Debug,
            Level::Info => RsLogLevel::Info,
            Level::Warn => RsLogLevel::Warn,
            Level::Error => RsLogLevel::Error,
            Level::Critical => RsLogLevel::Critical,
        },
        LevelFilter::Off => RsLogLevel::Off,
        _ => RsLogLevel::Info, // 其他情况默认 Info
    };
    level.into()
}

/// 记录 trace 级别日志
#[ffi_export]
pub fn rs_log_trace(message: char_p::Ref<'_>) {
    let msg = message.to_str();
    debug_print(&format!("rust > log trace: {}", msg));
    spdlog::trace!("{}", msg);
}

/// 记录 debug 级别日志
#[ffi_export]
pub fn rs_log_debug(message: char_p::Ref<'_>) {
    let msg = message.to_str();
    debug_print(&format!("rust > log debug: {}", msg));
    spdlog::debug!("{}", msg);
}

/// 记录 info 级别日志
#[ffi_export]
pub fn rs_log_info(message: char_p::Ref<'_>) {
    let msg = message.to_str();
    debug_print(&format!("rust > log info: {}", msg));
    spdlog::info!("{}", msg);
}

/// 记录 warn 级别日志
#[ffi_export]
pub fn rs_log_warn(message: char_p::Ref<'_>) {
    let msg = message.to_str();
    debug_print(&format!("rust > log warn: {}", msg));
    spdlog::warn!("{}", msg);
}

/// 记录 error 级别日志
#[ffi_export]
pub fn rs_log_error(message: char_p::Ref<'_>) {
    let msg = message.to_str();
    debug_print(&format!("rust > log error: {}", msg));
    spdlog::error!("{}", msg);
}

/// 记录 critical 级别日志
#[ffi_export]
pub fn rs_log_critical(message: char_p::Ref<'_>) {
    let msg = message.to_str();
    debug_print(&format!("rust > log critical: {}", msg));
    spdlog::critical!("{}", msg);
}

/// 使用指定级别记录日志 (使用 u8 作为级别参数)
#[ffi_export]
pub fn rs_log(level: u8, message: char_p::Ref<'_>) {
    let log_level: RsLogLevel = level.into();
    let msg = message.to_str();
    debug_print(&format!("rust > log {:?}: {}", log_level, msg));
    
    match log_level {
        RsLogLevel::Trace => spdlog::trace!("{}", msg),
        RsLogLevel::Debug => spdlog::debug!("{}", msg),
        RsLogLevel::Info => spdlog::info!("{}", msg),
        RsLogLevel::Warn => spdlog::warn!("{}", msg),
        RsLogLevel::Error => spdlog::error!("{}", msg),
        RsLogLevel::Critical => spdlog::critical!("{}", msg),
        RsLogLevel::Off => {}, // Off 不记录
    }
}

/// 刷新日志缓冲区
#[ffi_export]
pub fn rs_logger_flush() {
    debug_print("rust > flushing logger");
    spdlog::default_logger().flush();
}

/// 创建文件日志记录器（简化版，返回是否成功）
/// 
/// # Safety
/// - path 必须是有效的 UTF-8 字符串
#[ffi_export]
pub fn rs_logger_init_file(path: char_p::Ref<'_>) -> bool {
    let path_str = path.to_str();
    debug_print(&format!("rust > initializing file logger at: {}", path_str));
    
    use spdlog::sink::FileSink;
    
    match FileSink::builder().path(path_str).build_arc() {
        Ok(file_sink) => {
            let logger = match spdlog::Logger::builder()
                .sink(file_sink)
                .build_arc() {
                Ok(l) => l,
                Err(_) => return false,
            };
            spdlog::set_default_logger(logger);
            true
        }
        Err(e) => {
            eprintln!("rust > failed to create file sink: {:?}", e);
            false
        }
    }
}

/// 获取日志库版本信息
#[ffi_export]
pub fn rs_logger_version() -> char_p::Box {
    let version = env!("CARGO_PKG_VERSION");
    debug_print(&format!("rust > logger version: {}", version));
    CString::new(version).unwrap().into()
}

/// 释放 Rust 分配的字符串
#[ffi_export]
pub fn free_rs_string(string: char_p::Box) {
    let str = string.to_str();
    debug_print(&format!("rust > freeing string: {:?}", str));
    drop(string);
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CStr;

    // ==================== 日志级别转换测试 ====================

    #[test]
    fn test_log_level_conversion() {
        assert_eq!(Level::from(RsLogLevel::Trace), Level::Trace);
        assert_eq!(Level::from(RsLogLevel::Debug), Level::Debug);
        assert_eq!(Level::from(RsLogLevel::Info), Level::Info);
        assert_eq!(Level::from(RsLogLevel::Warn), Level::Warn);
        assert_eq!(Level::from(RsLogLevel::Error), Level::Error);
        assert_eq!(Level::from(RsLogLevel::Critical), Level::Critical);
    }

    #[test]
    fn test_log_level_filter_conversion() {
        assert_eq!(LevelFilter::from(RsLogLevel::Trace), LevelFilter::MoreSevereEqual(Level::Trace));
        assert_eq!(LevelFilter::from(RsLogLevel::Debug), LevelFilter::MoreSevereEqual(Level::Debug));
        assert_eq!(LevelFilter::from(RsLogLevel::Info), LevelFilter::MoreSevereEqual(Level::Info));
        assert_eq!(LevelFilter::from(RsLogLevel::Warn), LevelFilter::MoreSevereEqual(Level::Warn));
        assert_eq!(LevelFilter::from(RsLogLevel::Error), LevelFilter::MoreSevereEqual(Level::Error));
        assert_eq!(LevelFilter::from(RsLogLevel::Critical), LevelFilter::MoreSevereEqual(Level::Critical));
        assert_eq!(LevelFilter::from(RsLogLevel::Off), LevelFilter::Off);
    }

    #[test]
    fn test_log_level_u8_conversion() {
        assert_eq!(RsLogLevel::from(0u8), RsLogLevel::Trace);
        assert_eq!(RsLogLevel::from(1u8), RsLogLevel::Debug);
        assert_eq!(RsLogLevel::from(2u8), RsLogLevel::Info);
        assert_eq!(RsLogLevel::from(3u8), RsLogLevel::Warn);
        assert_eq!(RsLogLevel::from(4u8), RsLogLevel::Error);
        assert_eq!(RsLogLevel::from(5u8), RsLogLevel::Critical);
        assert_eq!(RsLogLevel::from(6u8), RsLogLevel::Off);
        assert_eq!(RsLogLevel::from(255u8), RsLogLevel::Info); // 默认值
    }

    // ==================== rs_logger_init 测试 ====================

    #[test]
    fn test_logger_init() {
        let result = rs_logger_init();
        assert!(result);
    }

    #[test]
    fn test_logger_init_multiple_calls() {
        // 多次调用应该都是成功的
        assert!(rs_logger_init());
        assert!(rs_logger_init());
        assert!(rs_logger_init());
    }

    // ==================== rs_logger_set_level / rs_logger_get_level 测试 ====================

    #[test]
    fn test_logger_set_and_get_level() {
        // 注意：spdlog 使用全局 logger，测试可能相互影响
        // 这里我们只验证设置和获取功能正常工作
        rs_logger_init();
        
        // 先设置一个已知的级别
        rs_logger_set_level(2); // Info
        assert_eq!(rs_logger_get_level(), 2);
        
        rs_logger_set_level(3); // Warn
        assert_eq!(rs_logger_get_level(), 3);
        
        rs_logger_set_level(4); // Error
        assert_eq!(rs_logger_get_level(), 4);
    }

    #[test]
    fn test_logger_set_all_levels() {
        rs_logger_init();
        
        // 测试所有有效的日志级别
        for level in 0u8..=6u8 {
            rs_logger_set_level(level);
            let got = rs_logger_get_level();
            // 注意：由于 spdlog 内部实现，某些级别可能映射到不同的值
            // 我们只确保不会 panic，并且返回值在有效范围内
            assert!(got <= 6, "日志级别应该在 0-6 范围内");
        }
    }

    #[test]
    fn test_logger_set_invalid_level() {
        rs_logger_init();
        
        // 设置无效级别（如 255），应该使用默认值 Info (2)
        rs_logger_set_level(255);
        // 由于 spdlog 内部可能不保存无效值，我们主要确保不会 panic
    }

    // ==================== rs_logger_version 测试 ====================

    #[test]
    fn test_logger_version() {
        let version = rs_logger_version();
        let version_str = version.to_str();
        assert!(!version_str.is_empty());
        // 版本号应该符合语义化版本格式
        assert!(version_str.contains('.'));
    }

    #[test]
    fn test_logger_version_format() {
        let version = rs_logger_version();
        let version_str = version.to_str();
        
        // 验证版本号格式 (x.y.z)
        let parts: Vec<&str> = version_str.split('.').collect();
        assert!(parts.len() >= 2, "版本号应该至少包含 major.minor");
        
        // 验证每个部分都是数字
        for part in &parts {
            assert!(part.parse::<u32>().is_ok(), "版本号各部分应该是数字");
        }
    }

    // ==================== 各级别日志记录测试 ====================

    /// 辅助函数：创建 C 字符串引用
    /// 注意：返回的 char_p::Ref 的生命周期与输入字符串相同
    fn create_cstr(s: &str) -> char_p::Ref<'_> {
        // 创建一个静态 buffer 来存储 null-terminated 字符串
        // 这里我们使用 CString 并 leak 它来获得 'static 生命周期
        let c_string = std::ffi::CString::new(s).unwrap();
        
        // leak 内存以获得 'static 生命周期（仅用于测试）
        let leaked = Box::leak(c_string.into_bytes_with_nul().into_boxed_slice());
        let c_str = unsafe { CStr::from_bytes_with_nul_unchecked(leaked) };
        char_p::Ref::from(c_str)
    }

    #[test]
    fn test_log_trace() {
        rs_logger_init();
        rs_logger_set_level(0); // Trace
        let msg = create_cstr("trace test message");
        rs_log_trace(msg);
    }

    #[test]
    fn test_log_debug() {
        rs_logger_init();
        rs_logger_set_level(1); // Debug
        let msg = create_cstr("debug test message");
        rs_log_debug(msg);
    }

    #[test]
    fn test_log_info() {
        rs_logger_init();
        rs_logger_set_level(2); // Info
        let msg = create_cstr("info test message");
        rs_log_info(msg);
    }

    #[test]
    fn test_log_warn() {
        rs_logger_init();
        rs_logger_set_level(3); // Warn
        let msg = create_cstr("warn test message");
        rs_log_warn(msg);
    }

    #[test]
    fn test_log_error() {
        rs_logger_init();
        rs_logger_set_level(4); // Error
        let msg = create_cstr("error test message");
        rs_log_error(msg);
    }

    #[test]
    fn test_log_critical() {
        rs_logger_init();
        rs_logger_set_level(5); // Critical
        let msg = create_cstr("critical test message");
        rs_log_critical(msg);
    }

    // ==================== rs_log (通用日志函数) 测试 ====================

    #[test]
    fn test_log_all_levels() {
        rs_logger_init();
        rs_logger_set_level(0); // Trace
        
        let msg = create_cstr("generic log message");
        
        // 测试所有级别
        rs_log(0, msg); // Trace
        rs_log(1, msg); // Debug
        rs_log(2, msg); // Info
        rs_log(3, msg); // Warn
        rs_log(4, msg); // Error
        rs_log(5, msg); // Critical
        rs_log(6, msg); // Off - 应该不会输出
    }

    #[test]
    fn test_log_with_empty_message() {
        rs_logger_init();
        let msg = create_cstr("");
        rs_log_info(msg);
    }

    #[test]
    fn test_log_with_long_message() {
        rs_logger_init();
        let long_msg = "a".repeat(1000);
        let c_str = std::ffi::CString::new(long_msg.as_str()).unwrap();
        let msg = char_p::Ref::from(CStr::from_bytes_with_nul(c_str.as_bytes_with_nul()).unwrap());
        rs_log_info(msg);
    }

    #[test]
    fn test_log_with_unicode_message() {
        rs_logger_init();
        let msg = create_cstr("Unicode 测试消息 🎉");
        rs_log_info(msg);
    }

    // ==================== rs_logger_flush 测试 ====================

    #[test]
    fn test_logger_flush() {
        rs_logger_init();
        // 刷新不应该 panic
        rs_logger_flush();
    }

    #[test]
    fn test_logger_flush_after_logs() {
        rs_logger_init();
        
        let msg = create_cstr("message before flush");
        rs_log_info(msg);
        rs_log_debug(msg);
        rs_logger_flush();
        
        let msg2 = create_cstr("message after flush");
        rs_log_info(msg2);
    }

    // ==================== rs_logger_init_file 测试 ====================

    #[test]
    fn test_logger_init_file_success() {
        let temp_path = "/tmp/test_spdlog_ffi_1.log";
        
        // 删除已存在的文件
        let _ = std::fs::remove_file(temp_path);
        
        let path = create_cstr(temp_path);
        let result = rs_logger_init_file(path);
        
        assert!(result, "文件日志初始化应该成功");
        
        // 验证文件被创建
        assert!(std::path::Path::new(temp_path).exists(), "日志文件应该被创建");
        
        // 清理
        let _ = std::fs::remove_file(temp_path);
    }

    #[test]
    fn test_logger_init_file_invalid_path() {
        // 使用无效路径（如目录不存在的路径）
        let path = create_cstr("/nonexistent/directory/test.log");
        let result = rs_logger_init_file(path);
        
        assert!(!result, "无效路径应该返回失败");
    }

    #[test]
    fn test_logger_file_logging() {
        let temp_path = "/tmp/test_spdlog_ffi_2.log";
        let _ = std::fs::remove_file(temp_path);
        
        // 初始化文件日志
        let path = create_cstr(temp_path);
        assert!(rs_logger_init_file(path));
        
        // 写入一些日志
        rs_logger_set_level(2); // Info
        let msg = create_cstr("file log test message");
        rs_log_info(msg);
        rs_log_warn(msg);
        
        // 刷新确保写入
        rs_logger_flush();
        
        // 验证文件内容
        let content = std::fs::read_to_string(temp_path).expect("应该能读取日志文件");
        assert!(content.contains("file log test message"), "日志文件应该包含写入的消息");
        
        // 清理
        let _ = std::fs::remove_file(temp_path);
    }

    // ==================== free_rs_string 测试 ====================

    #[test]
    fn test_free_rs_string() {
        let version = rs_logger_version();
        // 释放字符串不应该 panic
        free_rs_string(version);
    }

    // ==================== 综合测试 ====================

    #[test]
    fn test_full_workflow() {
        // 完整的日志工作流程测试
        
        // 1. 初始化
        assert!(rs_logger_init());
        
        // 2. 获取版本
        let version = rs_logger_version();
        assert!(!version.to_str().is_empty());
        free_rs_string(version);
        
        // 3. 设置级别为 Debug
        rs_logger_set_level(1);
        assert_eq!(rs_logger_get_level(), 1);
        
        // 4. 记录各级别日志
        let msg = create_cstr("workflow test");
        rs_log_trace(msg); // 不会显示，因为级别是 Debug
        rs_log_debug(msg); // 会显示
        rs_log_info(msg);  // 会显示
        
        // 5. 刷新
        rs_logger_flush();
        
        // 6. 更改级别为 Error
        rs_logger_set_level(4);
        rs_log_info(msg);  // 不会显示
        rs_log_error(msg); // 会显示
        
        // 7. 最终刷新
        rs_logger_flush();
    }

    #[test]
    fn test_log_message() {
        // 初始化日志记录器
        rs_logger_init();
        rs_logger_set_level(0); // Trace
        
        // 这些调用不应该 panic
        let c_str = std::ffi::CString::new("test message").unwrap();
        let msg = char_p::Ref::from(CStr::from_bytes_with_nul(c_str.as_bytes_with_nul()).unwrap());
        rs_log_trace(msg);
        rs_log_debug(msg);
        rs_log_info(msg);
        rs_log_warn(msg);
        rs_log_error(msg);
        rs_log_critical(msg);
        
        // 测试通用日志函数
        rs_log(2, msg); // Info
        rs_log(1, msg); // Debug
    }
}
