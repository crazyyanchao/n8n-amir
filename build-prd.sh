#!/bin/bash

# 生产环境构建脚本 - 发布到 Docker Hub
# 使用方法: ./build-prd.sh [版本号]

# 设置构建参数
IMAGE_NAME="n8n-amir"
DOCKERFILE="Dockerfile.n8n-amir"
BASE_IMAGE="docker.n8n.io/n8nio/n8n"

# 检查是否提供了版本号参数
if [ $# -eq 0 ]; then
    echo "请提供版本号: ./build-prd.sh <版本号>"
    echo "例如: ./build-prd.sh 1.105.4"
    exit 1
fi

VERSION=$1
LATEST_TAG="latest"
VERSION_TAG="$VERSION"

# 设置 Docker Hub 用户名（请根据实际情况修改）
DOCKER_USERNAME="grapher01110"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME"

echo "=========================================="
echo "开始构建生产环境镜像"
echo "镜像名称: $FULL_IMAGE_NAME"
echo "版本: $VERSION_TAG"
echo "最新标签: $LATEST_TAG"
echo "基础镜像: $BASE_IMAGE"
echo "=========================================="

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker 未运行或无法连接"
    exit 1
fi

# 检查是否已登录 Docker Hub
if ! docker info | grep -q "Username"; then
    echo "警告: 未检测到 Docker Hub 登录信息"
    echo "请先运行: docker login"
    read -p "是否继续构建？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 拉取最新基础镜像
echo "拉取基础镜像 $BASE_IMAGE:$VERSION_TAG..."
docker pull $BASE_IMAGE:$VERSION_TAG

# 如果指定版本不存在，则拉取最新版本作为备选
if [ $? -ne 0 ]; then
    echo "警告: 指定版本 $VERSION_TAG 不存在，拉取最新版本..."
    docker pull $BASE_IMAGE:latest
    if [ $? -ne 0 ]; then
        echo "错误: 无法拉取基础镜像"
        exit 1
    fi
fi

# 删除现有镜像（如果存在）
echo "清理现有镜像..."
docker rmi $FULL_IMAGE_NAME:$VERSION_TAG 2>/dev/null || echo "版本镜像不存在，跳过删除"
docker rmi $FULL_IMAGE_NAME:$LATEST_TAG 2>/dev/null || echo "最新镜像不存在，跳过删除"

# 构建版本镜像
echo "构建版本镜像 $FULL_IMAGE_NAME:$VERSION_TAG..."
docker build \
    --file $DOCKERFILE \
    --build-arg N8N_VERSION=$VERSION_TAG \
    --tag $FULL_IMAGE_NAME:$VERSION_TAG \
    --tag $FULL_IMAGE_NAME:$LATEST_TAG \
    --no-cache \
    .

# 检查构建是否成功
if [ $? -ne 0 ]; then
    echo "错误: 镜像构建失败"
    exit 1
fi

echo "镜像构建成功！"

# 显示镜像信息
echo "构建的镜像信息:"
docker images $FULL_IMAGE_NAME

# 推送镜像到 Docker Hub
echo "=========================================="
echo "推送镜像到 Docker Hub..."
echo "=========================================="

# 推送版本镜像
echo "推送版本镜像 $FULL_IMAGE_NAME:$VERSION_TAG..."
docker push $FULL_IMAGE_NAME:$VERSION_TAG

if [ $? -ne 0 ]; then
    echo "错误: 版本镜像推送失败"
    exit 1
fi

# 推送最新标签镜像
echo "推送最新标签镜像 $FULL_IMAGE_NAME:$LATEST_TAG..."
docker push $FULL_IMAGE_NAME:$LATEST_TAG

if [ $? -ne 0 ]; then
    echo "错误: 最新标签镜像推送失败"
    exit 1
fi

echo "=========================================="
echo "镜像发布成功！"
echo "=========================================="
echo "镜像地址: https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
echo "拉取命令:"
echo "  docker pull $FULL_IMAGE_NAME:$VERSION_TAG"
echo "  docker pull $FULL_IMAGE_NAME:$LATEST_TAG"
echo "=========================================="

# 清理本地镜像（可选）
read -p "是否清理本地镜像以节省空间？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "清理本地镜像..."
    docker rmi $FULL_IMAGE_NAME:$VERSION_TAG
    docker rmi $FULL_IMAGE_NAME:$LATEST_TAG
    echo "本地镜像已清理"
fi 