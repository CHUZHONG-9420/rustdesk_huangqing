# 远程配置文件格式说明

## 配置文件示例 (config.txt)

```
# RustDesk 远程配置文件
# 每行一个配置项，格式：key:value
# 以 # 开头的行是注释

# API 服务器地址
api_server:https://api.example.com

# API 密钥
key:your_api_key_here

# 端口映射配置
# 格式：原端口:新端口
21116:60001
21117:60002
21118:60003
21119:60004
```

## 配置项说明

### api_server
- **说明**: API 服务器的 URL 地址
- **示例**: `api_server:https://api.example.com`

### key
- **说明**: API 密钥或认证 Key
- **示例**: `key:OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=`

### 端口映射
- **21116**: Rendezvous Port (会合端口)
- **21117**: Relay Port (中继端口)
- **21118**: WebSocket Rendezvous Port
- **21119**: WebSocket Relay Port

**示例**:
```
21116:60001  # 将21116端口映射到60001
21117:60002  # 将21117端口映射到60002
```

## 使用方法

1. 在远程服务器上创建 `config.txt` 文件
2. 在 RustDesk 设置中点击"拉取远程配置"按钮
3. 输入配置文件的 URL（如：https://rustdesk.6w8.top/huangqing-rustdesk/config.txt）
4. 点击确认，软件将自动下载并应用配置

## 注意事项

- 配置文件使用 UTF-8 编码
- 每个配置项独占一行
- 空行和注释行会被忽略
- 配置会自动保存到本地，重启后依然有效
