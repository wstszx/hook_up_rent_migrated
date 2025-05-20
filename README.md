# 房屋租赁 App 部署文档

本项目包含一个 Flutter 前端应用和一个 Node.js 后端服务。

## 前端部署 (Flutter)

### 1. 环境准备

确保您的开发环境已安装 Flutter SDK。请参考 [Flutter 官方文档](https://flutter.dev/docs/get-started/install) 根据您的操作系统（Windows, macOS, Linux）选择合适的安装方式并进行配置。建议安装稳定版或最新 Beta 版。

### 2. 依赖安装

进入项目根目录 (`hook_up_rent_migrated`)，运行以下命令安装 Flutter 依赖：

```bash
flutter pub get
```

### 3. 配置说明

前端应用需要配置后端 API 的地址。请修改 <mcfile name="config.dart" path="lib/config.dart"></mcfile> 文件中的 `apiUrl` 变量，将其指向您的后端服务地址。

```dart
// lib/config.dart
const String apiUrl = 'http://127.0.0.1:8080'; // 修改为您的后端服务地址
```

### 4. 运行应用

连接您的设备或启动模拟器，然后在项目根目录运行：

```bash
flutter run
```

应用将在您的设备或模拟器上启动。

### 5. 构建应用 (可选)

如果您需要构建生产环境的应用包，可以运行以下命令：

- 构建 Android APK:
  ```bash
  flutter build apk --release
  ```
- 构建 iOS AppBundle:
  ```bash
  flutter build ipa --release
  ```
- 构建 Web 应用:
  ```bash
  flutter build web --release
  ```
构建完成后，输出文件位于 `build` 目录下。

## 后端部署 (Node.js)

### 1. 环境准备

确保您的服务器已安装 Node.js 和 npm (或 yarn)。请参考 [Node.js 官方网站](https://nodejs.org/) 下载并安装适合您操作系统的版本。建议安装 LTS (长期支持) 版本。

本项目使用 MongoDB 数据库。请确保您已安装并运行 MongoDB 服务。您可以参考 [MongoDB 官方文档](https://docs.mongodb.com/manual/installation/) 进行安装和配置。

### 2. 依赖安装

进入 `server` 目录，运行以下命令安装 Node.js 依赖：

```bash
cd server
npm install
# 或者使用 yarn
# yarn install
```

### 3. 配置说明

数据库连接配置位于 <mcfile name="db.js" path="server/config/db.js"></mcfile> 文件中。请根据您的 MongoDB 配置修改连接字符串。

```javascript
// server/config/db.js
module.exports = {
  // 修改为您的 MongoDB 连接字符串，例如 'mongodb://username:password@host:port/database'
  url: 'mongodb://localhost:27017/rent_share'
};
```

后端服务默认运行在 8080 端口。如果需要修改端口，请查看 <mcfile name="index.js" path="server/index.js"></mcfile> 文件中的端口配置。

### 4. 运行服务

在 `server` 目录下，运行以下命令启动后端服务：

```bash
cd server
npm start
# 或者使用 yarn
# yarn start
```

服务将在配置的端口上启动。

## 生产环境部署建议

对于生产环境部署，建议采取以下措施以提高服务的稳定性和可维护性：

1.  **进程管理**: 使用 PM2 (Process Manager 2) 等工具管理 Node.js 进程，实现进程守护、自动重启、负载均衡等功能。
    - 安装 PM2:
      ```bash
      npm install -g pm2
      ```
    - 使用 PM2 启动服务:
      ```bash
      cd server
      pm2 start index.js --name rent-backend
      ```
    - 查看 PM2 状态:
      ```bash
      pm2 status
      ```
2.  **反向代理**: 在前端和后端服务前配置反向代理服务器，如 Nginx 或 Caddy。反向代理可以处理 SSL 证书、负载均衡、静态文件服务等，提高安全性和性能。
    - **Nginx 配置示例 (简化)**:
      ```nginx
      server {
          listen 80;
          server_name your_domain.com;

          location /api/ {
              proxy_pass http://localhost:8080; # 指向后端服务地址
              proxy_http_version 1.1;
              proxy_set_header Upgrade $websocket_upgrade;
              proxy_set_header Connection 'upgrade';
              proxy_set_header Host $host;
              proxy_cache_bypass $http_upgrade;
          }

          location / {
              # 如果前端是 Web 应用，指向前端构建目录
              # root /path/to/your/flutter/web/build;
              # try_files $uri $uri/ /index.html;

              # 如果前端是移动应用，此部分可能不需要
          }
      }
      ```
3.  **域名和 SSL**: 为您的服务配置域名，并使用 Let's Encrypt 等服务获取免费的 SSL 证书，通过 HTTPS 提供服务，保障数据传输安全。
4.  **数据库备份**: 定期备份您的 MongoDB 数据库。
5.  **日志监控**: 设置日志收集和监控系统，及时发现和解决问题。

## 注意事项

- 确保前端和后端服务都已成功启动。
- 前端应用需要能够访问到后端服务。如果后端部署在远程服务器上，请修改前端代码中相关的 API 地址（<mcfile name="config.dart" path="lib/config.dart"></mcfile> 文件）以指向正确的后端服务地址。
- 生产环境部署需要额外的配置，请参考上述建议进行操作。
