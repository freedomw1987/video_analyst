# ffmpeg 用法範例

## 提取幀

```bash
# 提取視頻封面幀（指定時間點）
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 output.jpg

# 每隔 N 秒提取一幀
ffmpeg -i input.mp4 -vf "fps=1/10" frame_%03d.jpg

# 擷取多個時間點的縮圖
ffmpeg -i input.mp4 \
  -ss 00:00:10 -vframes 1 -q:v 2 frame_001.jpg \
  -ss 00:01:30 -vframes 1 -q:v 2 frame_002.jpg \
  -ss 00:03:00 -vframes 1 -q:v 2 frame_003.jpg
```

## 音頻處理

```bash
# 從視頻中提取音頻
ffmpeg -i input.mp4 -vn -acodec libmp3lame -q:a 2 output.mp3
```

## 格式轉換

```bash
# 轉換視頻格式
ffmpeg -i input.avi -codec copy output.mp4

# 壓縮視頻
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -c:a aac -b:a 128k output.mp4

# 調整解析度
ffmpeg -i input.mp4 -vf "scale=1280:720" output.mp4
```

## 剪輯與合併

```bash
# 剪切視頻片段
ffmpeg -i input.mp4 -ss 00:01:00 -to 00:02:30 -c copy output.mp4

# 合併多個視頻
ffmpeg -f concat -i filelist.txt -c copy output.mp4
```

## 資訊查詢

```bash
# 查看視頻資訊
ffmpeg -i input.mp4
```
