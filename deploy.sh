#!/bin/bash

# 设置一些变量
IMAGE_NAME="home"
CONTAINER_NAME="home"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# 拉取最新代码
echo "拉取最新代码..."
git reset --hard # 清理任何未提交的更改
git pull

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
