# logger

- ✅ Binding the popular Rust logging library [spdlog-rs](https://github.com/SpriteOvO/spdlog-rs) via FFI for Mojo usage.
- ✅ Redesigned API inspired by Python's [loguru](https://github.com/delgan/loguru) logging library for improved usability.

<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Logger Mojo</h3>

  <p align="center">
    🐝 Binding spdlog-rs logging library for mojo 🔥
    <br/>

![Mojo Version][language-shield]
[![MIT License][license-shield]][license-url]
[![Pixi Badge](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
<br/>
[![Contributors Welcome][contributors-shield]][contributors-url]

[简体中文](README_CN.md) | English

  </p>
</div>

## Package Contents

| Project                             | Package                 | Host | Rank   | Description                              |
|-------------------------------------|-------------------------|------|--------|------------------------------------------|
| ✅ [spdlog-ffi](./packages/spdlog-ffi)   | [libspdlog_ffi](https://prefix.dev/channels/better-ffi/packages/libspdlog_ffi) | [prefix.dev](https://prefix.dev/channels/better-ffi) | ⭐️⭐️⭐️ | spdlog-rs ffi package                    |
| ✅ [spdlog](./packages/spdlog) | [spdlog](https://prefix.dev/channels/better-mojo/packages/spdlog)  | [prefix.dev](https://prefix.dev/channels/better-mojo) | ⭐️⭐️⭐️⭐️   | spdlog-mojo package                      |

## Features

- ✅ Support logging to: `console`, `file`, `stdout`, `stderr`
- ✅ Support custom log `format`
- ✅ Support log `level` configuration
- ✅ Support `colored` logs

## Usage

- Import dependencies:

```toml

# First add channel sources, including spdlog-ffi package and spdlog package
channels = [
    "https://conda.modular.com/max-nightly",
    "https://repo.prefix.dev/better-ffi", # contains spdlog-ffi package
    "https://repo.prefix.dev/better-mojo", # contains spdlog mojo package
    "conda-forge",
]

# Add dependency packages
[dependencies]
mojo = ">=1.0.0b2.dev2026052706,<2" # TODO X: fix version inconsistency issue!!!

# FFI dependency
libspdlog_ffi = ">=0.1.0,<0.2"

# Mojo package dependency
# spdlog = { git = "https://github.com/better-mojo/logger.git", branch = "main" }
spdlog = ">=0.1.2,<0.2"

```

- ✅ Simple example:

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
# Run logging example
pixi run mojo -I . examples/logger.mojo

```

<img width="600" alt="image" src="https://github.com/user-attachments/assets/4dddd12b-bcc5-456f-8a03-9a88ced56582" />

- ✅ Complete example [examples/try-uuid](examples/try-uuid)
  - Includes complete package dependency import methods

```bash
# Install dependencies
pixi install

# Run
pixi run mojo src/main.mojo

```

### File Logging Example

- [examples/logger_file.mojo](examples/logger_file.mojo)
  - Includes complete package dependency import methods
  - Includes file logging example

## Development Environment

### Install Dependencies

- Install [Taskfile](https://github.com/go-task/go-task): build tool
- Install [Rust](https://www.rust-lang.org/tools/install)
- Install [pixi](https://pixi.sh/)
- Install [rattler-build](https://rattler-build.prefix.dev/latest/#installation): package management tool, compile + publish rust binary packages
- Install [mojo](https://mojolang.org/install/)

```bash
task setup
```

### Build and Debug

- ✅ Build and debug spdlog-ffi package

```bash

# Run examples
task ffi:r

# Build spdlog-ffi package
task ffi:b

# Release spdlog-ffi package
task ffi:rel

```

- ✅ Build and debug [examples](./examples)

```bash
# Run examples
task run:logger

```

## Release and Publish to Prefix.dev

- ✅ <https://prefix.dev/channels/better-ffi>
- ✅ <https://prefix.dev/channels/better-mojo>
- ✅ [Taskfile](./Taskfile.yml)

```bash
# Publish spdlog-ffi package to prefix.dev
task m:q:rs

# Publish spdlog package to prefix.dev
task m:q:mojo

```

- ✅ Compile and release Linux version, based on `orbstack` virtual machine
  - Note: each time you need to publish the ffi library for `3 OS versions` to prefix.dev first, then publish the spdlog package. (dependency order)

```bash
# List available virtual machines
orbctl list 

# Connect to linux-aarch64 architecture virtual machine, execute compile + publish
orbctl run -m u22dev

# Connect to linux-64 architecture virtual machine, execute compile + publish
orbctl run -m u22build

```

## Reference

### Mojo FFI Packages

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
