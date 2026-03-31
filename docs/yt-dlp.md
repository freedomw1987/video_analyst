# yt-dlp 用法範例

## 下載 YouTube 影片

```bash
# 最高畫質
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"

# 下載並提取音頻（mp3 格式）
yt-dlp -x --audio-format mp3 "https://www.youtube.com/watch?v=VIDEO_ID"

# 1080p 畫質並保留視頻
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" "https://www.youtube.com/watch?v=VIDEO_ID"

# 只下載畫質（不打包音頻）
yt-dlp -f "bestvideo[height<=720]" -o "video.%(ext)s" "https://www.youtube.com/watch?v=VIDEO_ID"
```

## 播放列表

```bash
# 從播放列表下載（1-10）
yt-dlp --playlist-start 1 --playlist-end 10 "https://www.youtube.com/playlist?list=PLAYLIST_ID"
```

## 資訊查詢

```bash
# 查看可用格式
yt-dlp --list-formats "https://www.youtube.com/watch?v=VIDEO_ID"

# 設置輸出檔名
yt-dlp -o "%(title)s.%(ext)s" "https://www.youtube.com/watch?v=VIDEO_ID"
```

## 字幕

```bash
# 下載字幕
yt-dlp --write-subs --write-auto-subs --sub-lang zh-Hant,zh-Hans,en "https://www.youtube.com/watch?v=VIDEO_ID"
```
