# YinBo-Server - 音波音乐后端

Spring Boot 3.2 后端服务，提供 REST API、JWT 认证、文件上传与播放地址签发。

## 技术栈

- Java 17
- Spring Boot 3.2
- Spring Security + JWT
- MyBatis-Plus
- MySQL 8
- Redis
- MinIO（对象存储）

## 项目结构

```
YinBo-Server/
├── src/main/java/com/yinbo/
│   ├── common/           # 统一响应等
│   ├── config/           # 配置类（Security、MinIO、CORS 等）
│   ├── controller/       # 控制器
│   ├── dto/              # 数据传输对象
│   ├── entity/           # 实体
│   ├── mapper/            # MyBatis Mapper
│   ├── security/         # JWT、CurrentUser 等
│   └── service/          # 业务逻辑
├── src/main/resources/
│   ├── application.yml   # 主配置
│   └── db/               # 数据库脚本
├── docs/
│   └── STORAGE_BUCKET.md # 存储桶说明
└── pom.xml
```

## 快速启动

```bash
# 确保 MySQL、Redis、MinIO 已启动且配置正确
mvn spring-boot:run
```

- **API 基地址**：http://localhost:8080/api
- **Swagger 文档**：http://localhost:8080/api/swagger-ui/index.html

## 配置项

`application.yml` 中主要配置：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `server.port` | 服务端口 | 8080 |
| `server.servlet.context-path` | 上下文路径 | /api |
| `spring.datasource.*` | MySQL 连接 | localhost:3306/yinbo_music |
| `spring.data.redis.*` | Redis 连接 | localhost:6379 |
| `minio.endpoint` | MinIO 地址 | http://127.0.0.1:9000 |
| `minio.access-key` | MinIO 访问密钥 | minio |
| `minio.secret-key` | MinIO secret | 12345678 |
| `minio.bucket-name.main` | 存储桶名 | yinbomusic |
| `jwt.secret` | JWT 密钥 | - |
| `jwt.expiration` | token 有效期（毫秒） | 86400000 |

## API 模块

| 模块 | 路径前缀 | 说明 |
|------|----------|------|
| 认证 | `/auth` | 注册、登录、token 刷新 |
| 歌曲 | `/tracks/public` | 歌曲列表、详情、搜索、热门等 |
| 歌单 | `/playlists` | 歌单 CRUD、添加/移除歌曲 |
| 评论 | `/comments` | 评论、回复、点赞 |
| 收藏 | `/favorites` | 收藏/取消收藏 |
| 关注 | `/follows` | 关注/取关、关注列表 |
| 用户 | `/users` | 用户信息、播放历史、头像等 |
| 通知 | `/notifications` | 消息通知（关注、评论回复、点赞） |
| 公告 | `/announcements` | 公告列表 |
| 管理 | `/admin` | 管理端接口（需 ADMIN 角色） |

## 相关文档

- [数据库](src/main/resources/db/README.md)
- [存储桶（MinIO）](docs/STORAGE_BUCKET.md)
