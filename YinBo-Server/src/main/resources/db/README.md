# 音波音乐 - 数据库

## 文件说明

| 文件 | 说明 |
|------|------|
| `yinbo_music.sql` | **完整数据库脚本** - 建表 + 初始数据，一次性导入即可 |

## 使用方式

```bash
# 1. 创建数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS yinbo_music DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. 导入脚本
mysql -u root -p yinbo_music < yinbo_music.sql
```

## 表结构概览

| 表名 | 说明 |
|------|------|
| **announcements** | 公告 |
| **audit_logs** | 操作审计日志 |
| **categories** | 音乐分类 |
| **comment_likes** | 评论点赞记录 |
| **comments** | 评论（含楼层、回复） |
| **favorites** | 用户收藏 |
| **notifications** | 消息通知（关注、评论回复、点赞） |
| **play_history** | 播放记录 |
| **playlist_items** | 歌单歌曲关联 |
| **playlists** | 歌单 |
| **search_hot_words** | 搜索热词 |
| **singers** | 歌手 |
| **track_tags** | 歌曲标签 |
| **tracks** | 歌曲（含 lyric_key、cover_key、minio_key 等） |
| **user_activities** | 用户动态（预留） |
| **user_follows** | 用户关注关系 |
| **user_privacy** | 用户隐私设置 |
| **users** | 用户 |

## 核心表说明

### users
用户账号、昵称、头像、签名、性别、生日、地区等。

### tracks
歌曲信息，含 `minio_key`（音频）、`cover_key`（封面）、`lyric_key`（歌词）在 MinIO 中的对象路径。

### comments
- `parent_id` 为 NULL：楼层评论
- `parent_id` 有值：回复（统一挂在楼层下）

### notifications
| 字段 | 说明 |
|------|------|
| user_id | 接收者 |
| from_user_id | 触发者 |
| type | FOLLOW / COMMENT_REPLY / LIKE |
| ref_id / ref_type | 关联 ID 与类型 |
| extra | 如 trackId，用于跳转 |
| read | 0 未读 / 1 已读 |
