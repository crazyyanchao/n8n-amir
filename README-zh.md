# n8n-amir

为了支持在 n8n Execute Command 节点中执行更多脚本命令（主要是Python），这个项目基于n8n Docker 镜像自定义二次打包，扩展了官方镜像内容。

## 扩展镜像的主要内容

- ✅ **基于官方 n8n 镜像** (`docker.n8n.io/n8nio/n8n`)
- ✅ **多 Python 版本支持** - 预装 Python 3.10, 3.11, 3.12, 3.13，默认使用 Python 3.12
- ✅ **现代化 Python 包管理** - 集成 uv 包管理器，提供更快的依赖安装和虚拟环境管理
- ✅ **完整的开发工具链** - 包含 build-base、libffi-dev、openssl-dev、cargo 等编译工具
- ✅ **常用系统工具** - 支持 pip、uv、curl、wget、git、unzip、zip、tar、gzip、bash 等命令
- ✅ **安全性考虑** - 禁止用户n8n Execute Command 节点执行 rm -rf 命令
- ✅ **优化的中国镜像源** - 配置清华 PyPI 镜像源，提升包下载速度
- ✅ **专用工作空间** - workspace 目录位于 `/home/node/.n8n/workspace`，便于项目管理
- ✅ **多阶段构建优化** - 采用多阶段构建，减小最终镜像体积

## 技术特性

### 🚀 性能优化
- **uv 包管理器**: 比 pip 快 10-100 倍的 Python 包安装速度
- **多阶段构建**: 减少镜像层数，优化构建时间和镜像大小
- **缓存优化**: 预装常用 Python 版本，避免重复下载

### 🔧 开发体验
- **多 Python 版本**: 支持 3.10-3.13，满足不同项目需求
- **完整工具链**: 包含编译工具，支持原生扩展安装
- **中国镜像源**: 配置清华 PyPI 镜像，提升下载速度

### 📦 容器化优势
- **专用工作空间**: workspace 目录持久化，便于项目管理
- **用户权限**: 以 node 用户运行，符合安全最佳实践
- **环境隔离**: 每个容器独立的 Python 环境
- **启动优化**: 自动修复配置文件权限，消除启动警告

## 快速开始

### 镜像打包与发布

```bash
.\build.sh
```

### 使用 Docker Compose

```bash
# 创建数据卷
docker volume create n8n_data
docker volume create n8n_workspace

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 镜像测试

在 n8n Execute Command 节点中，你可以使用以下命令：

### 基础功能测试

```bash
# 查看所有可用的 Python 版本
uv python list

# 验证当前版本
python --version

# 运行 Python 脚本
python -c "import sys; print(f'Python version: {sys.version}')"
```

### 项目管理和包管理测试

```bash
# 1. 查看当前用户
whoami

# 2. 查看当前工作区目录
pwd

# 3. 创建项目目录 && 初始化项目 && 安装 pandas && 返回自定义 DataFrame
rm -r amir-101 && mkdir -p amir-101 && cd amir-101 && uv init --python 3.12 . 

# 4. 安装 pandas
cd amir-101 && uv add pandas --default-index https://pypi.tuna.tsinghua.edu.cn/simple/ && cat pyproject.toml

# 5. 创建 data.py 并执行
cd amir-101 && echo 'import pandas as pd
df = pd.DataFrame({"姓名": ["张三", "李四"], "分数": [95, 88]})
print(df)' > data.py && cat data.py

# 6. 运行项目
cd amir-101 && ls -As
cd amir-101 && uv run main.py && uv run data.py
cd amir-101 && && uv run data.py # 报错？？？
```

```bash
mkdir test
cd test && uv init
cd /home/node/.n8n/workspace/test && uv run main.py
```
### 在 n8n 中的实际应用示例

```bash
# 切换到 Python 3.11 并安装包
uv python pin 3.11 && \
uv add requests pandas && \
python3 -c "
import requests
import pandas as pd
print('Python version:', requests.__version__)
print('Pandas version:', pd.__version__)
"
```

### 系统工具测试

```bash
# 测试常用系统工具
curl --version
wget --version
git --version
unzip -v
zip -v
tar --version
gzip --version
bash --version
```

### 开发工具链测试

```bash
# 测试编译工具
gcc --version
cargo --version
pip3 --version
uv --version
```



