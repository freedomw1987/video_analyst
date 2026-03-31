# Video Analyst

分析和解讀視頻內容的工具，可處理本地視頻文件、YouTube 連結或 Google Drive 連結，提取關鍵資訊生成結構化重點總結。

## 功能

- 支援多種視頻輸入：本地文件、YouTube 連結、Google Drive 連結
- 使用 ffmpeg 提取關鍵幀
- 使用 Azure OpenAI Whisper API 進行音頻轉錄
- 生成結構化的視頻內容摘要

## 環境設定

1. 複製環境變數範例檔：
   ```bash
   cp env.example .env
   ```

2. 編輯 `.env` 填入你的 Azure OpenAI 設定：
   ```bash
   AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com
   AZURE_OPENAI_API_KEY=your_api_key_here
   AZURE_OPENAI_WHISPER_DEPLOYMENT=whisper
   ```

## 依賴工具

- [ffmpeg](https://ffmpeg.org/) - 視頻處理
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube 下載
- [Azure OpenAI Whisper API](https://learn.microsoft.com/azure/ai-services/speech-service/whisper-overview) - 音頻轉錄

安裝 ffmpeg 和 yt-dlp：
```bash
brew install ffmpeg yt-dlp
```

## 使用方式

### 下載 YouTube 影片

```bash
./download.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 提取視頻幀

```bash
# 每隔 30 秒提取一幀
ffmpeg -i input.mp4 -vf "fps=1/30" -q:v 2 frames/frame_%04d.jpg

# 擷取特定時間點
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 -q:v 2 frame_001.jpg
```

### 提取音頻

```bash
ffmpeg -i input.mp4 -vn -acodec libmp3lame -q:a 2 output.mp3
```

### 音頻轉錄（Azure Whisper API）

```bash
curl "$AZURE_OPENAI_ENDPOINT/openai/deployments/$AZURE_OPENAI_WHISPER_DEPLOYMENT/audio/transcriptions?api-version=2024-02-01" \
  -H "api-key: $AZURE_OPENAI_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F file="@audio.mp3"
```

## 詳細文件

- [工作流程](docs/workflow.md)
- [ffmpeg 用法](docs/ffmpeg.md)
- [SKILL.md](SKILL.md) - Claude Code 技能定義

## 輸出格式

分析完成後會生成包含以下內容的報告：
- 影片基本資訊（標題、時長、來源）
- 內容摘要（段落式描述）
- 關鍵重點列表
- 重要時間點標記
- 類別/標籤
