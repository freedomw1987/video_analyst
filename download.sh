#!/usr/bin/env bash
set -e

if [[ -z "$1" ]]; then
  echo "Usage: $0 <youtube-url>"
  exit 1
fi

command -v yt-dlp >/dev/null || {
  echo "yt-dlp not found. Install: brew install yt-dlp"
  exit 1
}

echo "Downloading to /tmp"
yt-dlp --remote-components ejs:github --js-runtimes node --cookies COOKIES -o "/tmp/%(title)s.%(ext)s" -f "bestvideo[vcodec^=avc]+bestaudio[acodec^=aac]/best[vcodec^=avc]/best" --merge-output-format mp4 "$1"
echo "Done."
