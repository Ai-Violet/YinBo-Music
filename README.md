# 音波音乐 YinBo-Music - 三端项目技术文档

> 基于 Vue 3 + Spring Boot 的在线音乐播放平台，支持歌曲管理、评论、收藏、歌单、用户关注与消息通知等功能。本文档面向论文写作与开发部署，提供完整技术栈、配置说明、前后端对接及测试指南。

---

## 目录

1. [项目概述与架构](#1-项目概述与架构)
2. [技术栈详解](#2-技术栈详解)
3. [项目结构](#3-项目结构)
4. [配置文件与原理](#4-配置文件与原理)
5. [数据库设计与使用](#5-数据库设计与使用)
6. [MinIO 安装、配置与 MC 权限管理](#6-minio-安装配置与-mc-权限管理)
7. [前后端对接与核心示例代码](#7-前后端对接与核心示例代码)
8. [启动与部署流程](#8-启动与部署流程)
9. [功能测试清单](#9-功能测试清单)
10. [页面截图与论文配图建议](#10-页面截图与论文配图建议)

---

## 1. 项目概述与架构

### 1.1 三端组成

| 端 | 目录 | 端口 | 角色 |
|----|------|------|------|
| 后端 API | `YinBo-Server` | 8080 | 提供 REST API、JWT 认证、业务逻辑、文件存储 |
| 用户端 | `YinBo-Client` | 8081 | 用户听歌、评论、收藏、歌单、个人中心 |
| 管理后台 | `YinBo-Admin` | 8082 | 管理员：歌曲/歌手/分类/评论/用户/公告管理 |

### 1.2 系统架构图（可放入论文）

```
┌─────────────────────────────────────────────────────────────────┐
│                        用户端 (YinBo-Client)                      │
│  Vue 3 + TypeScript + Vite + Element Plus + Pinia                │
│  http://localhost:8081                                            │
└─────────────────────────┬───────────────────────────────────────┘
                          │ HTTP / REST (Axios)
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        后端 (YinBo-Server)                         │
│  Spring Boot 3.2 + MyBatis-Plus + Spring Security + JWT           │
│  http://localhost:8080/api                                        │
└─────┬─────────────────────────────┬───────────────────────────────┘
      │                             │
      │ 读写                         │ 读写
      ▼                             ▼
┌──────────────┐            ┌──────────────┐     ┌──────────────┐
│   MySQL 8    │            │    Redis     │     │   MinIO      │
│  3306/数据库  │            │ 6379/缓存    │     │ 9000/对象存储│
└──────────────┘            └──────────────┘     └──────────────┘
          ▲
          │ 管理端同样请求后端 API（使用 admin_token）
┌─────────────────────────────────────────────────────────────────┐
│                      管理后台 (YinBo-Admin)                       │
│  Vue 3 + TypeScript + Element Plus                               │
│  http://localhost:8082                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 技术栈详解

### 2.1 后端 (YinBo-Server)

| 技术 | 版本 | 作用 |
|------|------|------|
| Java | 17 | 运行环境 |
| Spring Boot | 3.2.0 | 应用框架 |
| Spring Security | 3.2 | 认证授权 |
| JWT (jjwt) | 0.12.3 | 无状态 Token 认证 |
| MyBatis-Plus | 3.5.5 | ORM、分页、逻辑删除 |
| MySQL Connector | - | 数据库驱动 |
| Spring Data Redis | - | Redis 集成 |
| MinIO SDK | 8.5.7 | 对象存储 |
| Swagger/OpenAPI 3 | - | API 文档 |

### 2.2 用户端 (YinBo-Client)

| 技术 | 版本 | 作用 |
|------|------|------|
| Vue | 3.x | 前端框架 |
| TypeScript | 5.9 | 类型系统 |
| Vite | 7.x | 构建与开发服务器 |
| Element Plus | 2.12 | UI 组件库 |
| Pinia | 3.x | 状态管理（播放器、用户） |
| Vue Router | 4.x | 路由 |
| Axios | 1.x | HTTP 请求 |
| Cropperjs | 1.6 | 头像/封面裁剪 |

### 2.3 管理后台 (YinBo-Admin)

与用户端技术栈基本相同，区别在于路由与接口使用 `admin_token`。

### 2.4 外部服务

| 服务 | 默认端口 | 用途 |
|------|----------|------|
| MySQL | 3306 | 业务数据持久化 |
| Redis | 6379 | 缓存、Session（如使用） |
| MinIO API | 9000 | 对象存储 API |
| MinIO Console | 9005 | MinIO 管理界面 |

---

## 3. 项目结构

```
YinBo-music/
├── YinBo-Server/                    # 后端
│   ├── src/main/java/com/yinbo/
│   │   ├── common/                  # 统一响应 Result
│   │   ├── config/                  # Security、MinIO、CORS 等
│   │   ├── controller/              # REST 控制器
│   │   ├── dto/                     # 数据传输对象
│   │   ├── entity/                  # 实体类
│   │   ├── mapper/                  # MyBatis Mapper
│   │   ├── security/                # JWT 过滤器、CurrentUser
│   │   ├── service/                 # 业务逻辑
│   │   └── exception/               # 全局异常处理
│   ├── src/main/resources/
│   │   ├── application.yml          # 主配置文件
│   │   └── db/                      # SQL 脚本
│   ├── docs/
│   │   └── STORAGE_BUCKET.md        # 存储桶说明
│   └── pom.xml
│
├── YinBo-Client/                    # 用户端
│   ├── src/
│   │   ├── api/                     # trackApi、commentApi 等
│   │   ├── components/              # Player、Header、Sidebar 等
│   │   ├── views/                   # Home、Profile、FullPlayer 等
│   │   ├── stores/                  # player、user
│   │   ├── router/
│   │   ├── utils/                   # request、token
│   │   └── constants/
│   ├── .env.development             # 开发环境变量（需自行创建）
│   └── vite.config.ts
│
├── YinBo-Admin/                     # 管理后台
│   ├── src/
│   │   ├── api/
│   │   ├── views/admin/
│   │   └── utils/
│   ├── .env.development
│   └── .env.production
│
└── README.md
```

---

## 4. 配置文件与原理

### 4.1 后端 `application.yml`

**路径**：`YinBo-Server/src/main/resources/application.yml`

| 配置项 | 说明 | 示例值 |
|--------|------|--------|
| `server.port` | 服务端口 | 8080 |
| `server.servlet.context-path` | API 前缀 | /api |
| `spring.datasource.url` | MySQL 连接 | jdbc:mysql://localhost:3306/yinbo_music?... |
| `spring.datasource.username` | 数据库用户名 | root |
| `spring.datasource.password` | 数据库密码 | 123456 |
| `spring.data.redis.host` | Redis 主机 | 127.0.0.1 |
| `spring.data.redis.port` | Redis 端口 | 6379 |
| `spring.data.redis.password` | Redis 密码 | 123456 |
| `minio.endpoint` | MinIO 地址 | http://127.0.0.1:9000 |
| `minio.access-key` | MinIO 访问密钥 | minio |
| `minio.secret-key` | MinIO 密钥 | 12345678 |
| `minio.bucket-name.main` | 存储桶名 | yinbomusic |
| `jwt.secret` | JWT 签名密钥 | yinbo-music-jwt-secret-key-... |
| `jwt.expiration` | Token 有效期（ms） | 86400000（24 小时） |
| `jwt.refresh-expiration` | 刷新 Token 有效期 | 604800000（7 天） |

**原理要点**：
- Spring Boot 通过 `spring.datasource.*` 自动配置 DataSource
- `mybatis-plus` 负责 Mapper 扫描与 SQL 映射
- `minio.*` 被 `MinioProperties` 注入，用于 `MinioConfig` 与 `MinioService`
- JWT 密钥需足够长，生产环境应使用环境变量或密钥管理

### 4.2 用户端环境变量

**创建文件**：`YinBo-Client/.env.development`

```env
VITE_API_BASE_URL=http://localhost:8080/api
```

**原理**：Vite 在构建时会将 `VITE_` 前缀变量注入 `import.meta.env`，前端通过 `import.meta.env.VITE_API_BASE_URL` 获取。

### 4.3 管理后台环境变量

**`YinBo-Admin/.env.development`**：

```env
VITE_API_BASE_URL=http://localhost:8080/api
VITE_CLIENT_URL=http://localhost:8081
```

**`YinBo-Admin/.env.production`**（生产示例）：

```env
VITE_API_BASE_URL=https://api.yinbo-music.com/api
VITE_CLIENT_URL=https://music.yinbo-music.com
```

### 4.4 Token 存储机制

| 端 | localStorage 键 | 说明 |
|----|-----------------|------|
| 用户端 | `user_token` | 普通用户 JWT |
| 管理后台 | `admin_token` | 管理员 JWT |

`request.ts` 根据当前路径是否以 `/admin` 开头，自动选择对应的 Token。

---

## 5. 数据库设计与使用

### 5.1 创建与导入

```bash
# 1. 创建数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS yinbo_music DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. 导入完整脚本
mysql -u root -p yinbo_music < YinBo-Server/src/main/resources/db/yinbo_music.sql
```

### 5.2 核心表结构

| 表名 | 说明 |
|------|------|
| `users` | 用户（含 role：USER/ADMIN） |
| `tracks` | 歌曲（minio_key、cover_key、lyric_key 关联 MinIO） |
| `playlists` | 歌单 |
| `playlist_items` | 歌单-歌曲关联 |
| `comments` | 评论（parent_id 为 NULL 表示楼层） |
| `comment_likes` | 评论点赞 |
| `favorites` | 用户收藏 |
| `user_follows` | 用户关注 |
| `notifications` | 消息通知 |
| `play_history` | 播放记录 |
| `singers` | 歌手 |
| `categories` | 音乐分类 |
| `announcements` | 公告 |

### 5.3 tracks 表与 MinIO 字段对应

| 字段 | 存储目录 | 说明 |
|------|----------|------|
| `minio_key` | music/ | 音频文件 |
| `cover_key` | cover/ | 封面图 |
| `lyric_key` | lyrics/ | 歌词文件 |

---

## 6. MinIO 安装、配置与 MC 权限管理

### 6.1 MinIO 安装

#### 方式一：Docker（推荐）

```bash
docker run -d -p 9000:9000 -p 9005:9005 \
  -e MINIO_ROOT_USER=minio \
  -e MINIO_ROOT_PASSWORD=12345678 \
  minio/minio server /data --console-address ":9005"
```

- API 地址：http://localhost:9000  
- 控制台：http://localhost:9005  
- 默认账号：minio / 12345678  

#### 方式二：Windows 二进制

1. 下载：https://min.io/download  
2. 解压得到 `minio.exe`  
3. 运行：

```powershell
minio.exe server D:\minio-data --console-address ":9005"
```

### 6.2 桶目录结构（后端自动创建）

```
yinbomusic/
├── music/      # 歌曲音频
├── cover/      # 封面
├── avatar/     # 用户头像
├── lyrics/     # 歌词
└── singer/    # 歌手头像
```

### 6.3 MC（MinIO Client）安装与桶权限

**为什么需要 MC？** 桶策略有时无法通过控制台正确设置，封面、头像等直链无法访问时，需用 `mc` 强制设置桶为公开读。

#### 安装 MC

**Windows：**
- 方式 1：`scoop install minio-client`
- 方式 2：https://min.io/docs/minio/linux/reference/minio-mc.html 下载 `mc.exe`  
- 将 `mc.exe` 放入 PATH 目录

**macOS / Linux：**
```bash
brew install minio/stable/mc   # macOS
# 或下载对应平台二进制
```

#### 配置别名并设置桶策略

```bash
# 1. 添加 MinIO 别名（用户名/密码与 docker 中一致）
mc alias set myminio http://localhost:9000 minio 12345678

# 2. 将 yinbomusic 桶设置为公开读（下载）
mc anonymous set download myminio/yinbomusic

# 3. 查看当前策略
mc anonymous get myminio/yinbomusic
```

#### 常用 MC 命令

| 命令 | 说明 |
|------|------|
| `mc anonymous set download myminio/yinbomusic` | 公开读 |
| `mc anonymous set public myminio/yinbomusic` | 公开读+写 |
| `mc ls myminio/yinbomusic` | 列出桶内对象 |

### 6.4 后端 MinIO 初始化原理

`MinioInitializer` 实现 `CommandLineRunner`，在 Spring Boot 启动后执行：
1. 若桶不存在则创建 `yinbomusic`
2. 设置桶策略为 `s3:GetObject` 公开读
3. 创建目录占位（music/、cover/、avatar/）

若 MinIO 未启动，初始化会失败并打印提示，但应用仍可启动（公开接口可访问，上传功能不可用）。

---

## 7. 前后端对接与核心示例代码

### 7.1 统一响应格式

**后端 `Result.java`**：

```java
public class Result<T> {
    private int code;      // 200 成功
    private String message;
    private T data;
}
```

**前端封装**：`request.ts` 中 axios 实例的 `baseURL` 为 `VITE_API_BASE_URL`，所有请求自动带 `Authorization: Bearer {token}`。

### 7.2 用户登录流程

**前端调用**（`YinBo-Client/src/views/Login.vue` 或 api）：

```typescript
// api/authApi 或直接调用
const res = await request.post('/auth/login', {
  username: 'xxx',
  password: 'xxx'
})
const { token, user } = res.data.data
localStorage.setItem('user_token', token)
// 存入 Pinia userStore
```

**后端接口**：`POST /api/auth/login`，返回 `{ token, user }`。

### 7.3 歌曲列表与播放

**前端 API 封装**（`YinBo-Client/src/api/index.ts`）：

```typescript
export const trackApi = {
  getHot(page?: number, size?: number, random?: boolean) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/hot', { 
      params: { page, size, random } 
    })
  },
  getDetail(id: number) {
    return request.get<ApiResponse<Track>>(`/tracks/public/${id}`)
  }
}
```

**播放器状态**（`stores/player.ts`）：
- 调用 `trackApi.getDetail(id)` 获取歌曲详情
- 通过 Layout 中的 Audio 元素播放 `playUrl`（后端预签名 URL）
- 播放列表、进度、音量等持久化到 localStorage

### 7.4 后端 Security 放行规则

```java
// SecurityConfig.java 片段
.requestMatchers("/auth/**").permitAll()
.requestMatchers("/tracks/public/**").permitAll()
.requestMatchers("/playlists/public/**").permitAll()
.requestMatchers("/admin/**").hasRole("ADMIN")
.anyRequest().authenticated()
```

- `/auth/**`、`/tracks/public/**` 等无需登录
- `/admin/**` 需 ADMIN 角色
- 其余接口需有效 JWT

### 7.5 文件上传与 MinIO

后端接收 `MultipartFile`，通过 `MinioService` 上传到对应目录（如 `cover/`、`avatar/`），并将对象 key 写入数据库。前端通过 `coverUrl`、`avatarUrl` 等字段拿到直链或预签名 URL。

---

## 8. 启动与部署流程

### 8.1 启动顺序

1. **MySQL**：创建库并导入 `yinbo_music.sql`
2. **Redis**：启动 Redis 服务
3. **MinIO**：Docker 或本地启动，执行 `mc anonymous set download myminio/yinbomusic`（若封面/头像无法加载）
4. **后端**：`cd YinBo-Server && mvn spring-boot:run`
5. **用户端**：`cd YinBo-Client && npm install && npm run dev`  
6. **管理后台**（可选）：`cd YinBo-Admin && npm install && npm run dev`

### 8.2 验证

- API：http://localhost:8080/api  
- Swagger：http://localhost:8080/api/swagger-ui/index.html  
- 用户端：http://localhost:8081  
- 管理后台：http://localhost:8082  

### 8.3 默认账号

导入 SQL 后，可查看 `users` 表。管理员账号需通过注册时填写 `adminKey: yinbo` 或数据库手动设置 `role='ADMIN'`。

---

## 9. 功能测试清单

| 模块 | 测试项 | 预期 |
|------|--------|------|
| 认证 | 注册、登录、退出、Token 刷新 | 正常跳转、Token 持久化 |
| 首页 | 热门推荐、榜单、最新音乐 | 数据加载、点击播放 |
| 搜索 | 关键词搜索、分页、热词 | 结果正确、分页生效 |
| 播放 | 播放/暂停、上一首/下一首、进度条、音量 | 音频正常、状态正确 |
| 评论 | 发表、回复、点赞、查看 | 实时更新、楼层正确 |
| 收藏 | 收藏/取消收藏 | 列表同步 |
| 歌单 | 创建、编辑、添加/移除歌曲、封面 | CRUD 正常 |
| 个人中心 | 头像、昵称、歌单、收藏、播放历史 | 数据一致 |
| 关注 | 关注/取关、关注列表 | 关系正确 |
| 通知 | 关注/评论/点赞通知、未读红点 | 数量与跳转正确 |
| 管理后台 | 歌曲/歌手/分类/评论/用户/公告管理 | 增删改查正常 |

---

## 10. 页面截图与论文配图建议

### 10.1 推荐截图页面

| 序号 | 页面 | 路径/说明 | 建议用途 |
|------|------|-----------|----------|
| 1 | 用户端首页 | `/home` 登录后 | 系统主界面 |
| 2 | 搜索页 | `/search` | 搜索与结果展示 |
| 3 | 全屏播放 | 点击封面进入 | 播放与歌词 |
| 4 | 歌单详情 | `/playlist/:id` | 歌单与歌曲列表 |
| 5 | 个人中心 | `/profile` | 用户信息与歌单 |
| 6 | 评论抽屉 | 点击「查看评论」 | 评论与回复 |
| 7 | 管理后台仪表盘 | `/admin` 登录后 | 管理端总览 |
| 8 | 歌曲管理 | 管理后台 | 后台 CRUD |
| 9 | Swagger 文档 | /api/swagger-ui | API 接口文档 |

### 10.2 截图规范建议

- 分辨率：建议 1920×1080 或 1440×900，保持统一
- 浏览器：Chrome 无痕或隐藏书签栏，界面整洁
- 可适当遮挡真实账号名、头像等隐私信息

### 10.3 论文中建议放置位置

1. **绪论/需求分析**：首页、搜索、播放界面 → 说明系统功能与用户场景  
2. **系统设计**：架构图（见 1.2）+ 数据库 ER 图 + API 模块表  
3. **实现与关键代码**：登录流程、播放流程的代码片段 + 对应界面截图  
4. **测试与结果**：功能测试表（见第 9 节）+ 典型页面截图（成功/异常提示）  
5. **附录**：完整页面截图集，按模块分组  

### 10.4 图片引用示例（Markdown/LaTeX）

```markdown
![用户端首页](docs/screenshots/01-home.png)
图 1 用户端首页
```

```latex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{docs/screenshots/01-home.png}
  \caption{用户端首页}
\end{figure}
```

建议在项目中新建 `docs/screenshots/` 目录，将截图按 `01-home.png`、`02-search.png` 等命名存放，便于论文引用和版本管理。

---

## 附录：相关文档

- [后端 README](YinBo-Server/README.md)  
- [用户端 README](YinBo-Client/README.md)  
- [管理后台 README](YinBo-Admin/README.md)  
- [数据库说明](YinBo-Server/src/main/resources/db/README.md)  
- [MinIO 存储桶说明](YinBo-Server/docs/STORAGE_BUCKET.md)  

---

**Author**: AIXiangChao  
**GitHub**: https://github.com/Ai-Violet/YinBo-Music/
