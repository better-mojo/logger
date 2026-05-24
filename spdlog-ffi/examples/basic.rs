//! 基本日志示例 - 演示如何使用 spdlog-ffi 记录日志

use spdlog::prelude::*;
use spdlog::LevelFilter;

fn main() {
    // 设置日志级别为全部显示
    spdlog::default_logger().set_level_filter(LevelFilter::All);
    
    // 记录不同级别的日志
    trace!("这是一条 trace 级别的日志");
    debug!("这是一条 debug 级别的日志");
    info!("这是一条 info 级别的日志");
    warn!("这是一条 warn 级别的日志");
    error!("这是一条 error 级别的日志");
    critical!("这是一条 critical 级别的日志");
    
    // 使用格式化字符串
    let name = "spdlog-rs";
    let version = "0.5";
    info!("欢迎使用 {} 版本 {}", name, version);
    
    // 演示不同日志级别的过滤
    println!("\n--- 设置日志级别为 Warn ---");
    spdlog::default_logger().set_level_filter(LevelFilter::MoreSevereEqual(Level::Warn));
    
    trace!("这条日志不会显示");
    debug!("这条日志不会显示");
    info!("这条日志不会显示");
    warn!("这条日志会显示");
    error!("这条日志会显示");
    
    println!("\n基本日志示例完成！");
}
