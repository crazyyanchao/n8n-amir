# N8N Amir 生产环境部署指南

本文档介绍如何使用远程Docker镜像部署N8N Amir服务。

## 🐳 镜像信息

- **镜像地址**: `grapher01110/n8n-amir:latest`
- **Docker Hub**: https://hub.docker.com/r/grapher01110/n8n-amir
- **拉取命令**: `docker pull docker.io/grapher01110/n8n-amir:latest`

## 🚀 快速开始

### 启动服务

```bash
# 使用docker-compose启动服务
docker-compose -f docker-compose-prd.yml up -d
```

### 访问服务

服务启动后，可以通过以下地址访问：
- **Web界面**: http://localhost:5678
- **容器名称**: `n8n-amir-remote`

## 📋 常用命令

### 启动服务
```bash
# 后台启动
docker-compose -f docker-compose-prd.yml up -d

# 前台启动（查看实时日志）
docker-compose -f docker-compose-prd.yml up
```

### 查看服务状态
```bash
# 查看容器状态
docker-compose -f docker-compose-prd.yml ps

# 查看服务状态
docker-compose -f docker-compose-prd.yml top
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose-prd.yml logs

# 实时跟踪日志
docker-compose -f docker-compose-prd.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose-prd.yml logs n8n-amir

# 查看最近100行日志
docker-compose -f docker-compose-prd.yml logs --tail=100
```

### 停止服务
```bash
# 停止服务（保持容器）
docker-compose -f docker-compose-prd.yml stop

# 停止并删除容器
docker-compose -f docker-compose-prd.yml down

# 停止并删除容器和网络
docker-compose -f docker-compose-prd.yml down --remove-orphans
```

### 重启服务
```bash
# 重启服务
docker-compose -f docker-compose-prd.yml restart

# 重新构建并启动
docker-compose -f docker-compose-prd.yml up -d --force-recreate
```

## 🔧 配置说明

### 环境变量
- `N8N_HOST`: 服务监听地址 (0.0.0.0)
- `N8N_PORT`: 服务端口 (5678)
- `N8N_PROTOCOL`: 协议类型 (http)
- `N8N_WEBHOOK_URL`: Webhook基础URL
- `N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS`: 强制设置文件权限
- `N8N_RUNNERS_ENABLED`: 启用运行器
- `GENERIC_TIMEZONE`: 时区设置 (Asia/Shanghai)

### 数据卷
- `n8n_data`: N8N配置和数据存储
- `n8n_workspace`: 工作空间文件
- `n8n_pipx`: Python包管理配置

## 📁 文件结构

```
.
├── docker-compose-prd.yml          # 生产环境配置文件
├── README-prd.md                   # 说明文档
└── ...
```

## 🚨 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep 5678
   
   # 修改docker-compose-prd.yml中的端口映射
   ports:
     - "5679:5678"  # 改为5679端口
   ```

2. **权限问题**
   ```bash
   # 检查卷权限
   docker volume inspect n8n_data
   
   # 重新创建卷
   docker volume rm n8n_data
   docker volume create n8n_data
   ```

3. **镜像拉取失败**
   ```bash
   # 检查网络连接
   docker pull hello-world
   
   # 使用镜像加速器（如需要）
   # 在Docker Desktop中配置镜像加速器
   ```

### 日志分析
```bash
# 查看错误日志
docker-compose -f docker-compose-prd.yml logs --tail=50 | grep -i error

# 查看启动日志
docker-compose -f docker-compose-prd.yml logs --tail=100 | grep -i "start\|ready"
```

## 🔄 更新镜像

当有新版本发布时：

```bash
# 1. 拉取最新镜像
docker pull grapher01110/n8n-amir:latest

# 2. 停止当前服务
docker-compose -f docker-compose-prd.yml down

# 3. 重新启动服务
docker-compose -f docker-compose-prd.yml up -d

# 4. 清理旧镜像（可选）
docker image prune -f
```

---

**注意**: 生产环境部署前请确保已备份重要数据，并测试服务功能正常。
