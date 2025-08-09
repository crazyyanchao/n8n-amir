#!/bin/bash

# 设置构建参数
IMAGE_NAME="n8n-amir"
TAG="latest"
DOCKERFILE="Dockerfile.n8n-amir"

# 删除现有镜像（如果存在）
echo "删除现有镜像 $IMAGE_NAME:$TAG..."
docker rmi $IMAGE_NAME:$TAG 2>/dev/null || echo "镜像不存在，跳过删除"

# 构建镜像
echo "开始构建新镜像..."
docker build \
    --file $DOCKERFILE \
    --tag $IMAGE_NAME:$TAG \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from $IMAGE_NAME:$TAG \
    .
