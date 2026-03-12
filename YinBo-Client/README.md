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
- 用户：登录、注册、个人主页、设置、播放历史
- 关注：关注/取关用户
- 通知：关注、评论回复、点赞通知（右上角铃铛+红点）

## 注意事项

1. 启动前确保后端已运行在 `http://localhost:8080`
2. 生产构建需配置正确的 `VITE_API_BASE_URL`
