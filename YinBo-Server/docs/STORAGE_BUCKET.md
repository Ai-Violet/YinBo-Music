# 音波音乐 - 存储桶（MinIO）

对象存储使用 MinIO，所有媒体文件存储在统一桶中，按目录区分类型。

## 桶配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| 桶名 | `application.yml` 中 `minio.bucket-name.main` | `yinbomusic` |
|  endpoint | MinIO API 地址 | `http://127.0.0.1:9000` |
|  Console | MinIO 管理界面 | `http://localhost:9005` |
|  Access Key | 访问密钥 | `minio` |
|  Secret Key | 密钥 | `12345678` |

## 桶目录结构

```
yinbomusic/                    # 主桶
├── music/                     # 歌曲音频
│   └── {uuid}.{mp3|flac|...}
├── cover/                     # 歌曲/歌单封面
│   └── {uuid}.{jpg|png|...}
├── avatar/                    # 用户头像
│   └── {uuid}.{jpg|png|...}
├── lyrics/                    # 歌词文件（LRC 等）
│   └── {uuid}.lrc
└── singer/                    # 歌手头像
    └── {uuid}.{jpg|png|...}
```

## 初始化

后端启动时（`MinioInitializer`）会自动：

1. 若桶不存在则创建 `yinbomusic`
2. 设置桶策略为公开读（`s3:GetObject`）
3. 创建目录占位：`music/`、`cover/`、`avatar/`

## 访问方式

- **直链访问**：`http://{minio-endpoint}/{bucket}/{object-path}`（需桶策略为公开读）
- **预签名 URL**：后端通过 `MinioService.getPresignedUrl()` 签发临时链接（默认 24 小时），用于音频播放等

## 数据库对应

| 表 | 字段 | 存储目录 |
|----|------|----------|
| tracks | minio_key | music/ |
| tracks | cover_key | cover/ |
| tracks | lyric_key | lyrics/ |
| users | avatar | avatar/ |
| singers | avatar | singer/ |
| playlists | cover | cover/ |

## 启动 MinIO

### Windows 批处理（本地二进制）

仓库根目录 **`startMinio.bat`**：切换到 `minio.exe` 所在目录后执行 `server`，并绑定 API `127.0.0.1:9000`、控制台 `127.0.0.1:9005`。  
**注意：** 脚本内路径默认为示例（如 `F:\MinIO\bin`、`F:\MinIO\data`），克隆到其它机器后必须改为本机实际路径；Access Key / Secret Key 须与 `application.yml` 中 `minio.access-key`、`minio.secret-key` 一致。

### Docker

```bash
docker run -d -p 9000:9000 -p 9005:9005 \
  -e MINIO_ROOT_USER=minio \
  -e MINIO_ROOT_PASSWORD=12345678 \
  minio/minio server /data --console-address ":9005"
```

或使用项目中的 `docker-compose`（若有）启动 MinIO 服务。

## 故障排查：私密桶强制改为公开

若桶被创建为私密，或 Console 中策略未生效，导致封面、头像等无法直链访问，需使用 **MinIO Client (`mc`)** 强制将桶改为公开读。

### 1. 安装 mc

```bash
# Windows (使用 scoop)
scoop install minio-client

# 或从 MinIO 官网下载 mc.exe
# https://min.io/docs/minio/linux/reference/minio-mc.html
```

### 2. 配置别名并设置桶策略

```bash
# 添加 MinIO 服务别名
mc alias set myminio http://localhost:9000 <access-key> <secret-key>

# 示例（默认 minioadmin/minioadmin）：
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# 强制将 yinbomusic 桶设置为公开读
mc anonymous set download myminio/yinbomusic
```

### 3. 常用 mc 策略命令

| 命令 | 说明 |
|------|------|
| `mc anonymous set download myminio/yinbomusic` | 公开读（下载） |
| `mc anonymous set public myminio/yinbomusic` | 完全公开（读+写） |
| `mc anonymous get myminio/yinbomusic` | 查看当前策略 |

### 4. 策略生效后

- 对象直链格式：`http://localhost:9000/yinbomusic/{object-path}`
- 若 MinIO 使用非默认端口，将 `9000` 替换为实际端口
