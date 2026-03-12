@echo off
:: 切换到minio.exe所在目录（如果批处理文件和minio.exe不在同一目录，需要手动修改路径）
cd /d F:\MinIO\bin

:: 执行MinIO启动命令（和你原来的命令一致）
minio.exe server F:\MinIO\data --console-address "127.0.0.1:9005" --address "127.0.0.1:9000"

:: 保持窗口不关闭（方便查看启动日志或错误信息，可选）
pause