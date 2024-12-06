#!/bin/bash

# 设置一些变量
IMAGE_NAME="home"
CONTAINER_NAME="home"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# 拉取最新代码
echo "拉取最新代码..."
RETRY_LIMIT=5  # 最大重试次数
RETRY_COUNT=0
SUCCESS=0

# 重试拉取代码
while [ $RETRY_COUNT -lt $RETRY_LIMIT ]; do
  git reset --hard # 清理任何未提交的更改
  git pull && SUCCESS=1 && break  # 如果拉取成功，退出循环
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "拉取代码失败，正在重试... (尝试次数: $RETRY_COUNT)"
  sleep 5  # 等待5秒后重试
done

if [ $SUCCESS -eq 0 ]; then
  echo "拉取代码失败，已达到最大重试次数($RETRY_LIMIT)。退出脚本。"
  exit 1
fi

# 停止并删除旧的容器
echo "检查并停止旧的容器..."
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  echo "旧容器已停止并删除。"
else
  echo "没有找到旧容器。"
fi

# 删除旧镜像
echo "检查并删除旧的镜像..."
if [ "$(docker images -q $IMAGE_NAME)" ]; then
  docker rmi $IMAGE_NAME
  echo "旧镜像已删除。"
else
  echo "没有找到旧镜像。"
fi

# 构建并部署新镜像
echo "构建并启动新镜像..."
docker-compose -f $DOCKER_COMPOSE_FILE up --build -d

# 显示运行中的容器
echo "当前正在运行的容器："
docker ps
