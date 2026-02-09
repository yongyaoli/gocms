# Build Stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

# 设置 Go 代理，加速依赖下载
ENV GOPROXY=https://goproxy.cn,direct

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# 编译应用，CGO_ENABLED=0 确保静态链接
RUN CGO_ENABLED=0 GOOS=linux go build -o goblog .

# Run Stage
FROM alpine:latest

WORKDIR /app

# 安装基础工具（可选，如需调试）
# RUN apk --no-cache add ca-certificates tzdata

# 复制编译产物
COPY --from=builder /app/goblog .

# 复制静态资源和模板
COPY --from=builder /app/web ./web
COPY --from=builder /app/config ./config

# 创建日志目录
RUN mkdir -p logs

# 暴露端口
EXPOSE 8080

# 启动应用
CMD ["./goblog"]
