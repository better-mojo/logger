# logger

- ✅ 基于 FFI 绑定 rust 热门日志库 [spdlog-rs](https://github.com/SpriteOvO/spdlog-rs), 提供给 Mojo 使用。
- ✅ 并参考 python [loguru](https://github.com/delgan/loguru) 日志库 API 风格，重写设计导出 API，提升易用性。

<a name="readme-top"></a>

<!-- 项目 LOGO -->
<br />
<div align="center">

<h3 align="center">Logger Mojo</h3>

  <p align="center">
    🐝 为 mojo 绑定 spdlog-rs 日志库 🔥
    <br/>

![Mojo 版本][language-shield]
[![MIT 许可证][license-shield]][license-url]
[![Pixi 徽章](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
<br/>
[![欢迎贡献者][contributors-shield]][contributors-url]

简体中文 | [English](README.md)

  </p>
</div>

## 包内容

| 项目                             | 包地址                 | 包托管平台     | 等级   | 描述                              |
|-------------------------------------|-------------------------|-----------| -------|------------------------------------------|
| ✅ [spdlog-ffi](./packages/spdlog-ffi)   | [libspdlog_ffi](https://prefix.dev/channels/better-ffi/packages/libspdlog_ffi) | [prefix.dev](https://prefix.dev/channels/better-ffi) | ⭐️⭐️⭐️ | spdlog-rs ffi 包                              |
| ✅ [spdlog](./packages/spdlog) | [spdlog](https://prefix.dev/channels/better-mojo/packages/spdlog)  | [prefix.dev](https://prefix.dev/channels/better-mojo) | ⭐️⭐️⭐️⭐️   | spdlog-mojo 包                        |

## 特性

- ✅ 支持日志输出到：`控制台`、`文件`、`标准输出`、`标准错误输出`
- ✅ 支持日志`格式`自定义
- ✅ 支持日志`等级`配置
- ✅ 支持`彩色`日志

## 使用方法

- 导入依赖：

```toml

# 先添加 2 个源地址，包含 uuid-ffi 包和 uuid 包
channels = [
    "https://conda.modular.com/max-nightly",
    "https://repo.prefix.dev/better-ffi", # 包含 uuid-ffi 包
    "https://repo.prefix.dev/better-mojo", # 包含 uuid mojo 包
    "conda-forge",
]

# 添加 2 个依赖包，包含 uuid-ffi 包和 uuid 包
[dependencies]
mojo = ">=1.0.0b2.dev2026052706,<2" # TODO X: fix 版本不一致问题！！！

# FFI 依赖
libspdlog_ffi = ">=0.1.0,<0.2"

# Mojo 包依赖
# spdlog = { git = "https://github.com/better-mojo/logger.git", branch = "main" }
spdlog = ">=0.1.2,<0.2"

```

- ✅ 简单示例:

```mojo
from spdlog import get_logger


def main() raises -> None:
    var logger = get_logger()

    logger.info("Hello, World!")
    logger.debug("Processing item {} of {}", "5", "100")
    logger.warn("Disk usage is at {}%", "85")


```

- ✅ run:

```bash
# 运行日志示例
pixi run mojo -I . examples/logger.mojo

```

<img width="600" alt="image" src="https://github.com/user-attachments/assets/4dddd12b-bcc5-456f-8a03-9a88ced56582" />

- ✅  完整示例 [examples/try-uuid](examples/try-uuid)
  - 包含完整的包依赖导入方法

```bash
# 安装依赖
pixi install

# 运行
pixi run mojo src/main.mojo

```

### 文件日志示例

- [examples/logger_file.mojo](examples/logger_file.mojo)
  - 包含完整的包依赖导入方法
  - 包含文件日志示例

## 开发环境

### 安装依赖

- 安装 [Taskfile](https://github.com/go-task/go-task) ： 编译构建工具
- 安装 [Rust](https://www.rust-lang.org/tools/install)
- 安装 [pixi](https://pixi.sh/)
- 安装 [rattler-build](https://rattler-build.prefix.dev/latest/#installation) ： 包管理工具，编译+发布 rust 二进制包
- 安装 [mojo](https://mojolang.org/install/)

```ruby
task setup
```

### 编译调试

- ✅ 编译调试 spdlog-ffi 包

```ruby

# 运行示例
task ffi:r

# 编译 spdlog-ffi 包
task ffi:b

# release spdlog-ffi 包
task ffi:rel

```

- ✅ 编译调试 [examples](./examples) 示例

```ruby
# 运行 examples 示例
task run:logger

```

## 发布到 Prefix.dev

- ✅ <https://prefix.dev/channels/better-ffi>
- ✅ <https://prefix.dev/channels/better-mojo>
- ✅ [Taskfile](./Taskfile.yml)

```bash
# 发布 spdlog-ffi 包到 prefix.dev
task m:q:rs

# 发布 spdlog 包到 prefix.dev
task m:q:mojo

```

- ✅ 编译发布 Linux 版本， 基于 `orbstack` 虚拟机
  - 注意，每次都要把 ffi 库，`3 个 OS 版本`，都发布到 prefix.dev，再发布 uuid 包。（依赖顺序）

```bash
# 查看可用的虚拟机
orbctl list 

# 连接 linux-aarch64 架构的 虚拟机, 执行编译+发布
orbctl run -m u22dev

# 连接 linux-64 架构的 虚拟机, 执行编译+发布
orbctl run -m u22build

```

## 参考

### Mojo FFI 包

- ✅ <https://github.com/better-mojo/uuid>
- ✅ <https://github.com/ehsanmok/sqlite>

### Python loguru

- ✅ <https://github.com/delgan/loguru>

### Rust spdlog

- ✅ <https://github.com/SpriteOvO/spdlog-rs>

### Rust FFI

- ✅ <https://github.com/getditto/safer_ffi>
- ✅ <https://github.com/f0cii/diplomat>
  - <https://github.com/rust-diplomat/diplomat>
  - <https://rust-diplomat.github.io/book/>
- ✅ <https://github.com/mozilla/uniffi-rs>
- ✅ <https://rustwiki.org/zh-CN/std/ffi/struct.CString.html#examples>

[language-shield]: https://img.shields.io/badge/Mojo%F0%9F%94%A5-1.0.0b2-orange

[license-shield]: https://img.shields.io/github/license/better-mojo/jojo?logo=github

[license-url]: https://github.com/better-mojo/jojo/blob/main/LICENSE

[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue

[contributors-url]: https://github.com/better-mojo/uuid#contributing
