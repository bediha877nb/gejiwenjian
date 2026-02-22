#!/bin/bash

REPO_OWNER="bediha877nb"
REPO_NAME="gejiwenjian"
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/files"

echo "正在获取文件列表..."

# 用 curl 获取 JSON，并用 grep/sed 提取文件名和下载地址
response=$(curl -s "$API_URL")

if echo "$response" | grep -q "message"; then
    echo "未找到文件或网络错误"
    exit 1
fi

# 解析并过滤掉 .gitkeep
files=$(echo "$response" | sed 's/^\[//;s/\]$//' | tr '},{' '\n' | grep -E '"name"|"download_url"' | sed 's/"//g;s/name://;s/download_url://' | grep -v ".gitkeep" | paste -d " " - -)

if [ -z "$files" ]; then
    echo "未找到文件或网络错误"
    exit 1
fi

echo "文件列表："
echo "$files" | nl

read -p "请输入要下载的文件编号: " NUM

selected=$(echo "$files" | sed -n "${NUM}p")
FILE_NAME=$(echo "$selected" | awk '{print $1}')
DOWNLOAD_URL=$(echo "$selected" | awk '{print $2}')

echo "正在下载 $FILE_NAME..."
curl -L -o "$FILE_NAME" "$DOWNLOAD_URL"

if [ $? -eq 0 ]; then
    echo "下载完成，文件保存为: $FILE_NAME"
else
    echo "下载失败"
fi
