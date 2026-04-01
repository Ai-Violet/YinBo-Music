# YinBo-Admin - 音波音乐管理后台

音波音乐平台的管理后台，用于歌曲、歌手、分类、评论、用户、公告等管理。

## 技术栈

- Vue 3 + TypeScript
- Vite
- Element Plus
- Vue Router
- Axios

## 项目结构

```
YinBo-Admin/
├── src/
│   ├── api/              # API 接口
│   ├── views/            # 管理页面
│   │   ├── Dashboard.vue # 仪表盘
│   │   ├── TrackManage.vue
│   │   ├── SingerManage.vue
│   │   ├── CommentManage.vue
│   │   └── ...
│   ├── router/
│   └── utils/
├── vite.config.ts
└── package.json
```

## 快速启动

```bash
npm install
npm run dev
```

默认访问：http://localhost:8082

## 脚本命令

| 命令 | 说明 |
|------|------|
| `npm run dev` | 开发模式（端口 8082） |
| `npm run build` | 生产构建 |

## 环境变量

| 变量 | 说明 | 默认 |
|------|------|------|
| `VITE_API_BASE_URL` | 后端 API 地址 | http://localhost:8080/api |
| `VITE_CLIENT_URL` | 用户端前台地址（用于「返回前台」等链接） | http://localhost:8081 |

## 数据库与 MinIO（联调时）

管理端通过后端 API 操作数据。导入数据库、配置 MinIO 桶与 Windows 启动脚本说明见仓库根目录 [README.md](../README.md) 与：

- [数据库脚本与表说明](../YinBo-Server/src/main/resources/db/README.md)
- [MinIO 桶结构](../YinBo-Server/docs/STORAGE_BUCKET.md)

根目录 **`startMinio.bat`** 为作者本机路径示例，使用前请修改为当地的 `minio.exe` 与数据目录。

## 权限说明

管理后台接口需使用**管理员 JWT**（通过管理员登录接口，如 `/auth/admin/login` 获得），存储在 `localStorage` 的 **`admin_token`** 中。请勿与普通用户接口混用 `user_token`。

首次创建管理员账号：可在用户注册请求体中携带 `adminKey: yinbo`（与后端约定一致），或导入 SQL 后在库内将用户 `role` 改为 `ADMIN`。**生产环境必须修改或移除该弱口令逻辑。**

## 注意事项

1. 新建 `.env.development`，包含 `VITE_API_BASE_URL` 与 `VITE_CLIENT_URL`（见仓库总 README）。
2. 后端 context-path 为 `/api`，环境变量中的基地址须以 `/api` 结尾（如 `http://localhost:8080/api`）。
