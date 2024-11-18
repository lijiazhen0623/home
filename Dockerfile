# 构建阶段
FROM node:18 AS builder
WORKDIR /app

# 设置 npm 源为淘宝镜像，加速依赖安装
RUN npm config set registry https://registry.npmmirror.com

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制项目文件
COPY . . 

# 如果 .env 文件不存在，则从 .env.example 复制一个
RUN [ ! -e ".env" ] && cp .env.example .env || true

# 构建生产文件
RUN npm run build

# 最小化镜像阶段
FROM node:18-alpine
WORKDIR /app

# 复制构建后的文件
COPY --from=builder /app/dist ./dist

# 安装 http-server
RUN npm install -g http-server

# 暴露端口
EXPOSE 12445

# 启动服务
CMD ["http-server", "dist", "-p", "12445"]
