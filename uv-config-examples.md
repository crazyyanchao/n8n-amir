# uv 0.8.6 全局配置指南

## 1. 基础配置

### 设置 PyPI 镜像源（环境变量方式）
```bash
# 清华镜像源（推荐）
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/

# 阿里云镜像源
export UV_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/

# 豆瓣镜像源
export UV_INDEX_URL=https://pypi.douban.com/simple/

# 官方源
export UV_INDEX_URL=https://pypi.org/simple/
```

### 设置默认 Python 版本
```bash
# 设置默认版本
uv python pin 3.12

# 查看当前版本
uv python list
```

## 2. 高级配置

### 环境变量配置
```bash
# 设置镜像源
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/

# 设置并发下载数
export UV_CONCURRENT_DOWNLOADS=20

# 设置超时时间
export UV_TIMEOUT=120

# 设置缓存目录
export UV_CACHE_DIR=~/.cache/uv

# 设置日志级别
export UV_LOG_LEVEL=info
```

### 在 Dockerfile 中配置
```dockerfile
# 设置 uv 环境变量
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/
ENV UV_CONCURRENT_DOWNLOADS=20
ENV UV_TIMEOUT=120
```

## 3. 在 n8n 中的使用示例

### 基础配置命令
```bash
# 1. 设置镜像源
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/

# 2. 设置默认 Python 版本
uv python pin 3.12

# 3. 验证配置
echo $UV_INDEX_URL
```

### 项目初始化配置
```bash
# 创建项目并配置
mkdir my-project && cd my-project
uv init --python 3.12

# 安装依赖
uv add requests pandas numpy

# 运行项目
uv run main.py
```

### 多版本 Python 管理
```bash
# 安装多个 Python 版本
uv python install 3.10
uv python install 3.11
uv python install 3.12
uv python install 3.13

# 切换版本
uv python pin 3.11

# 查看所有版本
uv python list
```

## 4. 常用命令

```bash
# 查看 uv 版本
uv --version

# 查看当前 Python 版本
uv python list

# 清理缓存
uv cache clean

# 查看帮助
uv --help
```

## 5. 性能优化配置

### 启用并行下载
```bash
# 设置并发下载数
export UV_CONCURRENT_DOWNLOADS=20
```

### 配置缓存
```bash
# 设置缓存目录
export UV_CACHE_DIR=/tmp/uv-cache

# 清理缓存
uv cache clean
```

## 6. 网络配置

### 代理设置
```bash
# 设置 HTTP 代理
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

### 超时设置
```bash
# 设置下载超时
export UV_TIMEOUT=120
```

## 7. 安全配置

### 禁用不安全源
```bash
# 只允许 HTTPS（通过设置 HTTPS 镜像源）
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/
```

## 8. 故障排除

### 常见问题解决
```bash
# 1. 清理所有缓存
uv cache clean

# 2. 重置环境变量
unset UV_INDEX_URL
unset UV_CONCURRENT_DOWNLOADS
unset UV_TIMEOUT

# 3. 重新安装 uv
pip uninstall uv
pip install uv==0.8.6

# 4. 检查网络连接
curl -I https://pypi.tuna.tsinghua.edu.cn/simple/
```

### 调试模式
```bash
# 启用详细日志
export UV_LOG_LEVEL=debug
uv add requests

# 显示下载进度
uv add pandas
```

## 9. 版本升级建议

如果你想要使用 `uv config` 命令，建议升级到更新的版本：

```bash
# 升级 uv
pip install --upgrade uv

# 或者安装最新版本
pip install uv --upgrade
```

升级后就可以使用 `uv config` 命令了：

```bash
# 设置镜像源
uv config set --default-index https://pypi.tuna.tsinghua.edu.cn/simple/

# 查看配置
uv config list
``` 