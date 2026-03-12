# 音波音乐 YinBo-Music

基于 Vue 3 + Spring Boot 的在线音乐播放平台，支持歌曲管理、评论、收藏、歌单、用户关注与消息通知等功能。

## 项目结构

```
YinBo-music/
├── YinBo-Server/          # 后端服务 (Spring Boot)
├── YinBo-Client/          # 用户端前端 (Vue 3 + Vite)
├── YinBo-Admin/           # 管理后台 (Vue 3 + Vite)
└── README.md
```

## 技术栈

| 模块       | 技术                                                  |
|------------|-------------------------------------------------------|
| 后端       | Java 17、Spring Boot 3.2、MyBatis-Plus、JWT、Redis   |
| 用户端     | Vue 3、TypeScript、Vite、Element Plus、Pinia          |
| 管理后台   | Vue 3、TypeScript、Vite、Element Plus                 |
| 数据库     | MySQL 8.0                                             |
| 对象存储   | MinIO                                                 |
| 缓存       | Redis                                                 |

## 快速启动

### 环境要求

- JDK 17+
- Node.js 18+
- MySQL 8.0
- Redis
- MinIO（或兼容 S3 的对象存储）

### 1. 数据库初始化

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS yinbo_music DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p yinbo_music < YinBo-Server/src/main/resources/db/yinbo_music.sql
```

详见 [数据库 README](YinBo-Server/src/main/resources/db/README.md)。

### 2. 存储桶准备

启动 MinIO 后，后端首次运行会自动创建桶 `yinbomusic` 及目录结构。

详见 [存储桶 README](YinBo-Server/docs/STORAGE_BUCKET.md)。

### 3. 启动后端

```bash
cd YinBo-Server
mvn spring-boot:run
```

- API 地址：http://localhost:8080/api
- Swagger 文档：http://localhost:8080/api/swagger-ui/index.html

### 4. 启动用户端

```bash
cd YinBo-Client
npm install
npm run dev
```

访问 http://localhost:8081

### 5. 启动管理后台（可选）

```bash
cd YinBo-Admin
npm install
npm run dev
```

访问 http://localhost:8082

## 配置说明

| 服务     | 配置文件                    | 主要配置项                         |
|----------|-----------------------------|------------------------------------|
| 后端     | `YinBo-Server/application.yml` | 数据库、Redis、MinIO、JWT          |
| 用户端   | `.env.development`          | `VITE_API_BASE_URL`               |
| 管理后台 | `.env.development`          | `VITE_API_BASE_URL`、`VITE_CLIENT_URL` |

## 模块说明

| 模块       | 说明                                                         |
|------------|--------------------------------------------------------------|
| [YinBo-Server](YinBo-Server/README.md) | 后端 API、认证、业务逻辑、文件上传与存储                    |
| [YinBo-Client](YinBo-Client/README.md) | 用户端：首页、搜索、播放、评论、收藏、歌单、个人中心、通知 |
| [YinBo-Admin](YinBo-Admin/README.md)   | 管理后台：歌曲/歌手/分类/评论/用户/公告管理                 |
| [数据库](YinBo-Server/src/main/resources/db/README.md) | 表结构、导入与迁移说明          |
| [存储桶](YinBo-Server/docs/STORAGE_BUCKET.md)        | MinIO 桶结构、目录与访问配置    |

## 默认账号

导入 `yinbo_music.sql` 后可用：

- 普通用户：见 `users` 表
- 管理员：`admin1` / 对应密码（需查看数据库或自行重置）

## 开发说明

- 后端：`mvn spring-boot:run`
- 用户端：`npm run dev`（默认端口 8081）
- 管理后台：`npm run dev`（默认端口 8082）

---

**Author**: AIXiangChao  
**GitHub**: https://github.com/Ai-Violet/YinBo-Music/
