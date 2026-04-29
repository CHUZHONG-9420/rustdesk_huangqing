# 远程配置功能使用说明

## 功能概述

此功能允许 RustDesk 从远程服务器动态获取配置信息，包括：
- API 服务器地址
- API 密钥
- 端口映射（21116-21119）

## 使用步骤

### 1. 准备配置文件

在您的远程服务器上创建一个 `config.txt` 文件，格式如下：

```txt
# API 服务器地址
api_server:https://api.example.com

# API 密钥  
key:your_api_key_here

# 端口映射
21116:60001
21117:60002
21118:60003
21119:60004
```

### 2. 在 RustDesk 中拉取配置

1. 打开 RustDesk 应用
2. 进入 **设置 (Settings)**
3. 点击 **网络 (Network)** 标签
4. 找到 **拉取远程配置 (Fetch Remote Config)** 选项
5. 点击该选项，会弹出对话框
6. 输入配置文件的 URL，例如：`https://rustdesk.6w8.top/huangqing-rustdesk/config.txt`
7. 点击 **拉取 (Fetch)** 按钮
8. 等待配置下载完成

### 3. 确认配置生效

配置成功拉取后，会显示遮蔽后的敏感信息：
- API Server（部分隐藏，如：`http****com`）
- Key（部分隐藏，如：`OeVu****mBw=`）
- Ports（部分隐藏，如：`{ren****119}`）

配置会自动保存到本地，下次启动软件时自动加载。

**注意**：为保护敏感信息，显示时会自动遮蔽中间部分，仅显示首尾字符。

## 配置文件格式

### 基本规则

- 每行一个配置项
- 格式：`key:value`
- 以 `#` 开头的行是注释
- 空行会被忽略
- 使用 UTF-8 编码

### 配置项说明

#### api_server
API 服务器的完整 URL 地址
```
api_server:https://api.example.com
```

#### key
API 认证密钥
```
key:OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=
```

#### 端口映射

将默认端口映射到自定义端口：

- **21116** → Rendezvous Port（会合端口）
- **21117** → Relay Port（中继端口）
- **21118** → WebSocket Rendezvous Port
- **21119** → WebSocket Relay Port

示例：
```
21116:60001  # 将 21116 映射到 60001
21117:60002  # 将 21117 映射到 60002
```

## 实现细节

### Rust 后端

1. **配置存储**：`libs/hbb_common/src/config.rs`
   - `RemoteConfig` 结构体存储配置信息
   - `fetch_remote_config()` 函数下载配置
   - `init_remote_config()` 在启动时加载本地缓存

2. **FFI 接口**：`src/flutter_ffi.rs`
   - `fetch_remote_config_async()` - 异步拉取配置
   - `get_remote_config_info()` - 获取当前配置信息

3. **端口动态获取**：
   ```rust
   RemoteConfig::get_rendezvous_port()  // 获取实际使用的端口
   RemoteConfig::get_relay_port()
   RemoteConfig::get_ws_rendezvous_port()
   RemoteConfig::get_ws_relay_port()
   ```

### Flutter 前端

1. **UI 入口**：`flutter/lib/desktop/pages/desktop_setting_page.dart`
   - 在网络设置中添加"拉取远程配置"按钮
   - `showFetchRemoteConfigDialog()` 函数显示对话框

2. **用户交互流程**：
   - 输入 URL → 点击拉取 → 调用 Rust FFI → 显示结果

## 注意事项

1. **网络要求**：需要能访问配置文件所在的 URL
2. **HTTPS 推荐**：建议使用 HTTPS 保证配置安全
3. **配置缓存**：配置会保存在本地，即使网络断开也能使用上次的配置
4. **端口优先级**：远程配置的端口优先于默认端口

## 故障排查

### 无法连接到配置服务器
- 检查 URL 是否正确
- 确认网络连接正常
- 检查防火墙设置

### 配置未生效
- 重启 RustDesk 应用
- 检查配置文件格式是否正确
- 查看日志文件获取详细错误信息

### 端口未改变
- 确认配置文件中端口映射格式正确
- 重启应用以使端口配置生效

## 示例

参见项目根目录下的 `config_example.txt` 文件。
