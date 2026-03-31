# Playwright - 自動化下載影片

## 简介
Playwright 可以模擬瀏覽器操作，下載網頁上的影片文件（mp4, webm 等）。

**YouTube 公開影片無需登陸**，但可能遇到 "Sign in to confirm that you're not a bot" 驗證。

## 防 Bot 檢測設置

```python
from playwright.sync_api import sync_playwright

def create_stealth_browser():
    """建立反檢測的瀏覽器"""
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--disable-blink-features=AutomationControlled",  # 隱藏自動化特徵
                "--disable-dev-shm-usage",
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-web-security",
                "--disable-features=IsolateOrigins,site-per-process",
            ]
        )

        # 建立帶有真實瀏覽器特徵的 context
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            viewport={"width": 1920, "height": 1080},
            locale="zh-TW",
            timezone_id="Asia/Taipei",
            extra_http_headers={
                "Accept-Language": "zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7",
            },
        )

        # 注入腳本隱藏 webdriver 特徵
        context.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
            delete window.cdc_adoQpoasnfa76pfcZLmcfl_Array;
            delete window.cdc_adoQpoasnfa76pfcZLmcfl_Promise;
            delete window.cdc_adoQpoasnfa76pfcZLmcfl_Symbol;
        """)

        return browser, context
```

## 基本用法

### 等待下載事件
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 監聽下載事件
    with page.expect_download() as download_info:
        page.goto("https://example.com/video-page")
        page.click("download-button")  # 點擊下載按鈕

    download = download_info.value
    # 保存到指定路徑
    download.save_as("/path/to/save/video.mp4")
    # 或取得臨時路徑
    print(f"下載路徑: {download.path()}")
```

### 拦截网络请求获取视频 URL
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # 攔截視頻請求
    video_url = None

    def handle_response(response):
        nonlocal video_url
        content_type = response.headers.get("content-type", "")
        if "video" in content_type or any(ext in response.url for ext in [".mp4", ".webm", ".m3u8"]):
            video_url = response.url
            print(f"找到影片: {video_url}")

    page.on("response", handle_response)
    page.goto("https://example.com/video-page")
    page.wait_for_timeout(2000)  # 等待頁面加載

    if video_url:
        print(f"可用下載連結: {video_url}")
```

### 直接下載網絡請求的影片
```python
import requests
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    video_url = None

    def handle_response(response):
        nonlocal video_url
        if "video" in response.headers.get("content-type", ""):
            video_url = response.url

    page.on("response", handle_response)
    page.goto("https://example.com/video-page")
    page.wait_for_timeout(2000)

    if video_url:
        # 使用 requests 下載（更穩定）
        response = requests.get(video_url, headers={"User-Agent": "Mozilla/5.0"})
        with open("video.mp4", "wb") as f:
            f.write(response.content)
        print("下載完成")
```

## 常用配置

### 下載到指定目錄
```python
context = browser.contexts[0]
page = context.new_page()
# 或設置下載路徑
context = browser.new_context(accept_downloads=True)
```

### 處理需要登錄的下載
```python
context = browser.new_context()
page = context.new_page()

# 登錄
page.goto("https://example.com/login")
page.fill("#username", "user")
page.fill("#password", "pass")
page.click("button[type='submit']")
page.wait_for_load_state("networkidle")

# 之後再導航到下載頁面
page.goto("https://example.com/video-page")
```

## 限制
- 某些網站使用 Blob URL 或 m3u8 流媒體，無法直接下載
- 部分網站有防下載機制（如 DRM）無法繞過
- m3u8 流媒體需要用 ffmpeg 合併 Ts 片段才能得到完整影片

## 驗證問題解決方案

如果仍然遇到 "Sign in to confirm that you're not a bot" 驗證：

### 方案一：使用真實瀏覽器的 Cookies
```python
# 用瀏覽器插件（如 "EditThisCookie") 導出登陸後的 cookies
import json

with open("youtube_cookies.json") as f:
    cookies = json.load(f)

context = browser.new_context()
context.add_cookies(cookies)
page = context.new_page()
```

### 方案二：添加隨機延遲模擬真實用戶
```python
import random
import time

# 頁面加載後隨機滾動頁面
page.evaluate("window.scrollBy(0, document.body.scrollHeight / 2)")
time.sleep(random.uniform(1, 3))
page.evaluate("window.scrollBy(0, -document.body.scrollHeight / 2)")
time.sleep(random.uniform(1, 2))
```

### 方案三：更換 IP / 使用代理
```python
context = browser.new_context(
    proxy={"server": "http://your-proxy-server:port"}
)
```

### 方案四：使用已登陸的瀏覽器配置文件
```python
# 使用 Chrome 瀏覽器的用戶數據目錄（已登陸過 YouTube）
context = browser.browser_type.launch_persistent_context(
    user_data_dir="/path/to/chrome/profile",
    headless=False,  # 需要可見模式
)
```

**注意**: 頻繁下載或大量請求仍可能觸發驗證，建議控制請求頻率。
