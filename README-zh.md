# n8n-amir

为了支持在 n8n Execute Command 节点中执行更多脚本命令（主要是Python），这个项目基于n8n Docker 镜像自定义二次打包，扩展了官方镜像内容。

数据卷部分保留了n8n_data，新增了n8n_workspace和n8n_pipx。在 n8n Execute Command 节点操作时任何创建的文件都在`/workspace`目录下，需要通过n8n_workspace数据卷持久化。在 n8n Execute Command 节点操作pipx命令安装可执行CLI时，这些CLI相关内容也会被持久化到n8n_pipx，这样做的目的升级Docker容器时保证用户安装的可执行CLI不丢失。

## 扩展镜像的主要内容

- ✅ **基于官方 n8n 镜像** (`docker.n8n.io/n8nio/n8n`)
- ✅ **多 Python 版本支持** - 预装 Python 3.10, 3.11, 3.12, 3.13，默认使用 Python 3.12
- ✅ **现代化 Python 包管理** - 集成 uv 包管理器，提供更快的依赖安装和虚拟环境管理
- ✅ **完整的开发工具链** - 包含 build-base、libffi-dev、openssl-dev、cargo 等编译工具
- ✅ **常用系统工具** - 支持 pip、uv、curl、wget、git、unzip、zip、tar、gzip、bash、vim、jq、tree、less、procps、util-linux、rsync等命令
- ✅ **安全性考虑** - 禁止用户n8n Execute Command 节点执行 rm -rf 命令
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

### 📦 容器化优势
- **专用工作空间**: workspace 目录持久化，便于项目管理
- **用户权限**: 以 node 用户运行，符合安全最佳实践
- **环境隔离**: 每个容器独立的 Python 环境
- **启动优化**: 自动修复配置文件权限，消除启动警告

## 快速开始

### 镜像打包与发布

```bash
.\build.sh      # Local
.\build-prd.sh  # Remote
```

### 使用 Docker Compose

```bash
# 创建数据卷
docker volume create n8n_data
docker volume create n8n_workspace
docker volume create n8n_pipx

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

可用命令 pip、uv、pipx，在 n8n Execute Command 节点操作时推荐优先使用pipx，对于一些临时运行的场景可以使用uv或pip进行实现（但需要重点解决Alpine Linux包管理依赖的问题）。

使用pipx时，需要将可执行代码包上传到访问仓库，然后在 n8n Execute Command 节点执行下载和运行，下载的可执行包会持久化存储在`n8n_pipx`数据卷中。

#### ==========================pipx使用==========================

- 当需要安装的包有可执行命令时优先使用 pipx 安装

```bash
pipx install --index-url https://pypi.tuna.tsinghua.edu.cn/simple mcp-server-time
```

- 清除缓存重新加载 Shell

```bash
hash -r
exec $SHELL
```

- 执行运行
```bash
mcp-server-time --local-timezone "Asia/Shanghai"
```

#### ==========================pip使用==========================

- 创建虚拟环境后安装包，安装结束后退出虚拟环境

```bash
python -m venv .venv && source .venv/bin/activate && pip install llmcompiler --index-url https://pypi.tuna.tsinghua.edu.cn/simple && deactivate
```

- 创建 run.py

```python
from llmcompiler.result.chat import ChatRequest
from llmcompiler.tools.basic import Tools
from langchain_openai.chat_models.base import ChatOpenAI
from llmcompiler.chat.run import RunLLMCompiler

chat = ChatRequest(message="<YOUR_MESSAGE>")

print(chat)
```

- 测试运行

```bash
pip install langgraph==0.1.19
source .venv/bin/activate && python run.py # 版本依赖可以忽略主要验证程序环境安装方式
```

#### ==========================uv使用==========================

- 创建test项目并初始化

```bash
mkdir test && cd test && uv init
```

- 测试运行

```bash
cd /workspace/test && uv run main.py
```

### 在 n8n 中的实际应用示例

切换到 n8n Execute Command 节点执行测试。

```bash
mcp-server-time --local-timezone "Asia/Shanghai" # 这只是一个示例运行是不会返回结果会一直显示加载，说明CLI安装正常
```

```bash
python -c "
import pandas as pd
print('Pandas version:', pd.__version__)
"
```

### 工具测试

```bash
# 测试常用系统工具
curl --version && wget --version && git --version && unzip -v && zip -v && tar --version && gzip --version && bash --version

# 测试编译工具
gcc --version && g++ --version && cargo --version && pkg-config --version

# 测试 Python 相关工具
python3 --version && pip3 --version && uv --version && pipx --version

# 测试开发工具
vim --version && jq --version && tree --version && less --version

# 测试系统监控工具
htop --version && ncdu --version && ps --version && free --version && uptime --version

# 测试搜索工具
rsync --version

# 测试数学计算库
python3 -c "import numpy; print('NumPy version:', numpy.__version__)" && python3 -c "import pandas; print('Pandas version:', pandas.__version__)"

# 测试 Python 版本管理
uv python list && uv --version

# 测试包管理工具
pip3 list > /workspace/pip_list.txt && cat /workspace/pip_list.txt | head -100
```



