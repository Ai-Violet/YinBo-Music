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

## 权限说明

管理后台接口需使用**管理员 token**（`/auth/admin/login` 登录后获得），存储在 `localStorage` 的 `admin_token` 中。
