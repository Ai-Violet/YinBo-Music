# YinBo-Client - 音波音乐用户端

音波音乐播放平台的前端项目，使用 Vue 3 + TypeScript + Vite + Element Plus 构建。

## 技术栈

| 技术 | 说明 |
|------|------|
| Vue 3 | Composition API、`<script setup>` |
| TypeScript | 类型支持 |
| Vite | 构建与开发服务器 |
| Element Plus | UI 组件 |
| Pinia | 状态管理 |
| Vue Router | 路由 |
| Axios | HTTP 请求 |
| SCSS | 样式 |

## 项目结构

```
YinBo-Client/
├── src/
│   ├── api/              # API 接口（trackApi、commentApi、notificationApi 等）
│   ├── components/       # 公共组件
│   │   ├── Header.vue    # 头部导航（含通知铃铛）
│   │   ├── Sidebar.vue   # 侧边栏
│   │   ├── Player.vue    # 底部播放器
│   │   └── TrackCommentDrawer.vue  # 评论抽屉
│   ├── views/            # 页面
│   │   ├── Home.vue      # 主页（含通知、歌单、评论）
│   │   ├── FullPlayer.vue# 全屏播放
│   │   ├── Profile.vue   # 个人主页
│   │   ├── Settings.vue  # 个人设置
│   │   └── ...
│   ├── stores/           # Pinia 状态
│   │   ├── player.ts     # 播放器状态
│   │   └── user.ts       # 用户状态
│   ├── router/           # 路由
│   ├── utils/            # 工具（request、token）
│   ├── composables/      # 组合式逻辑（如 useTheme）
│   └── constants/        # 常量
├── .env.development      # 开发环境变量
├── vite.config.ts
└── package.json
```

## 快速启动

```bash
npm install
npm run dev
```

默认访问：http://localhost:8081

## 脚本命令

| 命令 | 说明 |
|------|------|
| `npm run dev` | 开发模式（端口 8081） |
| `npm run build` | 生产构建 |
| `npm run preview` | 预览生产构建 |

## 环境变量

| 变量 | 说明 | 默认 |
|------|------|------|
| `VITE_API_BASE_URL` | 后端 API 地址 | http://localhost:8080/api |

## 主要功能

- 首页：榜单、热门推荐、我的歌单、搜索
- 播放：底部播放器、全屏播放、歌词、播放列表
- 评论：楼层评论、回复、点赞
- 收藏：收藏/取消收藏歌曲
- 歌单：创建、编辑、添加/移除歌曲
- 用户：登录、**邮箱验证码注册**（见后端 [EMAIL_VERIFICATION.md](../YinBo-Server/docs/EMAIL_VERIFICATION.md)）、个人主页、设置、播放历史
- 关注：关注/取关用户
- 通知：关注、评论回复、点赞通知（右上角铃铛+红点）

## 数据库与对象存储（联调时）

本仓库用户端不直接连库；数据来自后端 API。完整数据库脚本、MinIO 桶说明见：

- [YinBo-Server 数据库 README](../YinBo-Server/src/main/resources/db/README.md)
- [存储桶说明](../YinBo-Server/docs/STORAGE_BUCKET.md)

Windows 下本地 MinIO 可用仓库根目录 **`startMinio.bat`**（需把其中的盘符路径改成你本机的 `minio.exe` 与数据目录）。

## 注意事项

1. 若仓库内没有 `.env.development`，请**自行新建**，至少包含 `VITE_API_BASE_URL=http://localhost:8080/api`，否则请求可能指向错误地址。
2. 启动前确保后端已运行（默认 `http://localhost:8080/api`，注意带 `/api` 上下文路径）。
3. 用户 Token 存 `localStorage` 键 **`user_token`**；与管理后台的 `admin_token` 互不通用。
4. 生产构建须设置正确的 `VITE_API_BASE_URL`（指向线上 API 基地址）。
