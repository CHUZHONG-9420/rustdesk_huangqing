# Windows x64 构建指南

## 环境要求

| 工具 | 版本 | 安装状态 |
|------|------|----------|
| Rust | 1.75+ | ✅ 已安装（需重启终端生效） |
| Flutter | 3.x | ❌ 需安装 |
| Visual Studio | 2019/2022 with C++ | ❌ 需安装 |
| VCPKG | latest | ❌ 需安装 |
| Python | 3.x | ✅ 已安装 |

---

## 第一步：安装 Visual Studio Build Tools

下载并安装：  
https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/

安装时勾选以下组件：
- **MSVC v143 - VS 2022 C++ x64/x86 生成工具**
- **Windows 11 SDK**
- **C++ CMake 工具**

---

## 第二步：安装 Flutter SDK

```powershell
# 方法1：使用 winget
winget install Google.Flutter

# 方法2：手动下载
# https://docs.flutter.dev/get-started/install/windows/desktop
# 解压到 C:\flutter，然后将 C:\flutter\bin 添加到 PATH
```

验证安装：
```powershell
flutter doctor
```

---

## 第三步：安装并配置 VCPKG

```powershell
# 安装 VCPKG
git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
cd C:\vcpkg
.\bootstrap-vcpkg.bat

# 设置环境变量（永久）
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:\vcpkg", "User")
[System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\vcpkg", "User")
```

---

## 第四步：安装 VCPKG 依赖

```powershell
cd C:\vcpkg

# 安装 RustDesk 所需依赖（耗时较长，约 1-2小时）
.\vcpkg install --triplet x64-windows-static \
    aom libjpeg-turbo opus libvpx libyuv ffmpeg

# 集成到 MSBuild
.\vcpkg integrate install
```

---

## 第五步：配置 Rust 工具链

**重启终端后执行：**

```powershell
# 验证 Rust 安装
rustc --version
cargo --version

# 设置默认工具链
rustup default stable-x86_64-pc-windows-msvc

# 安装 flutter_rust_bridge 代码生成工具
cargo install flutter_rust_bridge_codegen --version 1.82.7
```

---

## 第六步：生成 Flutter Bridge 绑定代码

```powershell
cd C:\Users\QI\Desktop\RestDesk\rustdesk_huangqing

flutter_rust_bridge_codegen \
    --rust-input src/flutter_ffi.rs \
    --dart-output flutter/lib/generated_bridge.dart \
    --c-output flutter/macos/Runner/bridge_generated.h
```

---

## 第七步：编译 Rust 后端（生成 DLL）

```powershell
cd C:\Users\QI\Desktop\RestDesk\rustdesk_huangqing

# 设置 VCPKG 路径
$env:VCPKG_ROOT = "C:\vcpkg"

# 编译（约 10-30 分钟）
cargo build --features flutter --lib --release
```

验证：检查 `target\release\librustdesk.dll` 是否生成。

---

## 第八步：编译 Flutter 前端

```powershell
cd C:\Users\QI\Desktop\RestDesk\rustdesk_huangqing\flutter

# 获取 Flutter 依赖
flutter pub get

# 编译 Windows Release 包
flutter build windows --release
```

---

## 第九步：复制依赖 DLL

```powershell
cd C:\Users\QI\Desktop\RestDesk\rustdesk_huangqing

# 复制虚拟显示器 DLL
copy target\release\deps\dylib_virtual_display.dll flutter\build\windows\x64\runner\Release\
```

---

## 第十步：打包（可选，生成安装程序）

```powershell
cd C:\Users\QI\Desktop\RestDesk\rustdesk_huangqing\libs\portable

pip install -r requirements.txt

python generate.py `
    -f ..\..\flutter\build\windows\x64\runner\Release\ `
    -o . `
    -e ..\..\flutter\build\windows\x64\runner\Release\rustdesk.exe
```

---

## 一键构建命令（所有环境准备好后）

```powershell
cd C:\Users\QI\Desktop\RestDesk\rustdesk_huangqing
$env:VCPKG_ROOT = "C:\vcpkg"

python build.py --flutter
```

---

## 输出位置

| 类型 | 路径 |
|------|------|
| 可执行程序 | `flutter\build\windows\x64\runner\Release\rustdesk.exe` |
| 安装包 | `rustdesk-1.4.6-install.exe`（打包后）|

---

## 常见问题

### ❌ `librustdesk.dll not found`
- Cargo build 失败，检查 VCPKG_ROOT 是否设置
- 确认 Visual Studio C++ Build Tools 已安装

### ❌ `flutter_rust_bridge_codegen not found`
- 重新运行 `cargo install flutter_rust_bridge_codegen --version 1.82.7`

### ❌ VCPKG 依赖安装失败
- 确认网络连接正常
- 尝试设置代理：`$env:HTTPS_PROXY = "http://your-proxy:port"`

### ❌ `reqwest` 编译失败
- 确认 openssl 或 rustls 相关依赖已通过 VCPKG 安装

---

## 预计构建时间

| 步骤 | 预计时间 |
|------|----------|
| VCPKG 依赖安装 | 1-2 小时 |
| Cargo build | 10-30 分钟 |
| Flutter build | 2-5 分钟 |
| **总计** | **约 2-3 小时** |
