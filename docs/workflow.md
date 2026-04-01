---
id: workflow
aliases: []
tags: []
---

# 視頻分析流程

## 完整工作流程

### Step 1: 下載 YouTube 影片
```bash
./download.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```
影片會下載到 `/tmp/` 目錄，檔名為影片標題。

### Step 2: 從下載的影片每 30 秒提取一幀用於分析
```bash
ffmpeg -i "/tmp/影片標題.mp4" -vf "fps=1/30" -q:v 2 frames/frame_%04d.jpg
```

### Step 4: 使用 Azure Whisper API 轉錄音頻

**使用 curl 調用 REST API**
```bash
curl "$AZURE_OPENAI_ENDPOINT/openai/deployments/$AZURE_OPENAI_WHISPER_DEPLOYMENT/audio/transcriptions?api-version=2024-02-01" \
  -H "api-key: $AZURE_OPENAI_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F file="@temp_audio.mp3"
```

**使用 Python requests 調用**
```python
import os
import requests

endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")
api_key = os.environ.get("AZURE_OPENAI_API_KEY")
deployment = os.environ.get("AZURE_OPENAI_WHISPER_DEPLOYMENT")

url = f"{endpoint}/openai/deployments/{deployment}/audio/transcriptions?api-version=2024-02-01"

headers = {
    "api-key": api_key
}

with open("temp_audio.mp3", "rb") as audio_file:
    files = {"file": audio_file}
    response = requests.post(url, headers=headers, files=files)

transcription = response.json()["text"]
```

### Step 5: 擷取多個時間點的高畫質縮圖
```bash
ffmpeg -i temp_video.mp4 \
  -ss 00:00:05 -vframes 1 -q:v 2 frame_001.jpg \
  -ss 00:00:30 -vframes 1 -q:v 2 frame_002.jpg \
  -ss 00:01:00 -vframes 1 -q:v 2 frame_003.jpg \
  -ss 00:02:00 -vframes 1 -q:v 2 frame_004.jpg \
  -ss 00:05:00 -vframes 1 -q:v 2 frame_005.jpg
```

### Step 6: 清理臨時檔案
```bash
rm temp_audio.mp3 temp_video.mp4
```

## 輸出格式
- 影片基本資訊（標題、時長、來源）
- 內容摘要（段落式描述）
- 關鍵重點列表（bullet points）
- 重要時間點標記（如適用）
- 類別/標籤
