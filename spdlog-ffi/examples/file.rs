//! 文件日志示例 - 演示如何将日志写入文件

use spdlog::{
    prelude::*,
    sink::FileSink,
    Logger,
};


fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 创建文件 sink
    let log_path = "/tmp/spdlog_test.log";
    let file_sink = FileSink::builder()
        .path(log_path)
        .truncate(true)  // 清空已有内容
        .build_arc()?;
    
    // 创建只输出到文件的 logger
    let logger = Logger::builder()
        .sink(file_sink)
        .build_arc()?;
    
    // 设置为默认 logger
    spdlog::set_default_logger(logger);
    
    // 设置日志级别
    spdlog::default_logger().set_level_filter(spdlog::LevelFilter::MoreSevereEqual(Level::Debug));
    
    // 写入日志
    info!("===== 文件日志测试开始 =====");
    debug!("这是一条 debug 日志，会写入文件");
    info!("这是一条 info 日志，会写入文件");
    warn!("这是一条 warn 日志，会写入文件");
    error!("这是一条 error 日志，会写入文件");
    
    // 带参数的日志
    let user = "Alice";
    let action = "login";
    info!("用户 {} 执行了 {} 操作", user, action);
    
    // 刷新日志确保写入文件
    spdlog::default_logger().flush();
    
    info!("===== 文件日志测试结束 =====");
    
    println!("日志已写入文件: {}", log_path);
    
    // 读取并显示文件内容
    match std::fs::read_to_string(log_path) {
        Ok(content) => {
            println!("\n文件内容:");
            println!("{}", content);
        }
        Err(e) => eprintln!("读取文件失败: {}", e),
    }
    
    Ok(())
}
