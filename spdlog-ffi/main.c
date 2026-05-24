#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "cffi.h"

// 日志级别定义 (与 Rust 的 RsLogLevel 对应)
#define RS_LOG_LEVEL_TRACE 0
#define RS_LOG_LEVEL_DEBUG 1
#define RS_LOG_LEVEL_INFO 2
#define RS_LOG_LEVEL_WARN 3
#define RS_LOG_LEVEL_ERROR 4
#define RS_LOG_LEVEL_CRITICAL 5
#define RS_LOG_LEVEL_OFF 6

int main(int argc, char const *const argv[])
{
    printf("===== spdlog-ffi C 示例 =====\n\n");

    // 初始化日志记录器
    printf("1. 初始化日志记录器\n");
    if (rs_logger_init())
    {
        printf("   日志记录器初始化成功\n");
    }

    // 获取版本信息
    printf("\n2. 获取版本信息\n");
    char *version = rs_logger_version();
    printf("   spdlog-ffi 版本: %s\n", version);
    free_rs_string(version);

    // 设置日志级别为全部显示
    printf("\n3. 设置日志级别为 Trace\n");
    rs_logger_set_level(RS_LOG_LEVEL_TRACE);

    // 记录不同级别的日志
    printf("\n4. 记录各级别日志:\n");
    rs_log_trace("这是一条 trace 级别的日志 (来自 C)");
    rs_log_debug("这是一条 debug 级别的日志 (来自 C)");
    rs_log_info("这是一条 info 级别的日志 (来自 C)");
    rs_log_warn("这是一条 warn 级别的日志 (来自 C)");
    rs_log_error("这是一条 error 级别的日志 (来自 C)");
    rs_log_critical("这是一条 critical 级别的日志 (来自 C)");

    // 使用通用日志函数
    printf("\n5. 使用通用日志函数:\n");
    rs_log(RS_LOG_LEVEL_INFO, "通过 rs_log 记录的 info 日志");
    rs_log(RS_LOG_LEVEL_DEBUG, "通过 rs_log 记录的 debug 日志");

    // 演示日志级别过滤
    printf("\n6. 设置日志级别为 Warn (低于 Warn 的日志不会显示):\n");
    rs_logger_set_level(RS_LOG_LEVEL_WARN);
    rs_log_trace("这条日志不会显示");
    rs_log_debug("这条日志不会显示");
    rs_log_info("这条日志不会显示");
    rs_log_warn("这条日志会显示 - Warn 级别");
    rs_log_error("这条日志会显示 - Error 级别");
    rs_log_critical("这条日志会显示 - Critical 级别");

    // 刷新日志
    printf("\n7. 刷新日志缓冲区\n");
    rs_logger_flush();

    // 获取当前日志级别
    printf("\n8. 当前日志级别: ");
    uint8_t level = rs_logger_get_level();
    switch (level)
    {
    case RS_LOG_LEVEL_TRACE:
        printf("Trace\n");
        break;
    case RS_LOG_LEVEL_DEBUG:
        printf("Debug\n");
        break;
    case RS_LOG_LEVEL_INFO:
        printf("Info\n");
        break;
    case RS_LOG_LEVEL_WARN:
        printf("Warn\n");
        break;
    case RS_LOG_LEVEL_ERROR:
        printf("Error\n");
        break;
    case RS_LOG_LEVEL_CRITICAL:
        printf("Critical\n");
        break;
    case RS_LOG_LEVEL_OFF:
        printf("Off\n");
        break;
    default:
        printf("Unknown\n");
        break;
    }

    printf("\n===== 示例结束 =====\n");

    return EXIT_SUCCESS;
}
