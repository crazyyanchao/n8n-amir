# n8n-amir

[![English](https://img.shields.io/badge/English-Click-yellow)](README.md)
[![中文文档](https://img.shields.io/badge/中文文档-点击查看-orange)](README-zh.md)

To support executing more script commands (mainly Python) in n8n Execute Command nodes, this project is based on the n8n Docker image with custom secondary packaging, extending the official image content.

The data volume section retains n8n_data, and adds n8n_workspace and n8n_pipx. When operating in n8n Execute Command nodes, any files created are in the `/workspace` directory, which needs to be persisted through the n8n_workspace data volume. When operating pipx commands in n8n Execute Command nodes to install executable CLIs, these CLI-related contents will also be persisted to n8n_pipx, ensuring that user-installed executable CLIs are not lost when upgrading Docker containers.

Here is an n8n workflow template: [n8n Latest Image File Monitoring and Email Notification](https://github.com/crazyyanchao/n8n-workflow-template/tree/main/workflows/docker-n8n-update-notice). It demonstrates the effects of using the custom image n8n-amir in n8n Execute Command nodes.

## Extended Image Main Content

- ✅ **Based on official n8n image** (`docker.n8n.io/n8nio/n8n`)
- ✅ **Multi-Python version support** - Pre-installed Python 3.10, 3.11, 3.12, 3.13, default using Python 3.12
- ✅ **Modern Python package management** - Integrated uv package manager, providing faster dependency installation and virtual environment management
- ✅ **Complete development toolchain** - Includes build-base, libffi-dev, openssl-dev, cargo and other compilation tools
- ✅ **Common system tools** - Supports pip, uv, curl, wget, git, unzip, zip, tar, gzip, bash, vim, jq, tree, less, procps, util-linux, rsync and other commands
- ✅ **Security considerations** - Prohibits user n8n Execute Command nodes from executing rm -rf commands
- ✅ **Dedicated workspace** - workspace directory located at `/home/node/.n8n/workspace`, convenient for project management
- ✅ **Multi-stage build optimization** - Adopts multi-stage builds, reducing final image size

## Technical Features

### 🚀 Performance Optimization
- **uv package manager**: 10-100x faster Python package installation speed than pip
- **Multi-stage builds**: Reduces image layers, optimizes build time and image size
- **Cache optimization**: Pre-installs common Python versions, avoiding repeated downloads

### 🔧 Development Experience
- **Multiple Python versions**: Supports 3.10-3.13, meeting different project requirements
- **Complete toolchain**: Includes compilation tools, supporting native extension installation

### 📦 Containerization Advantages
- **Dedicated workspace**: workspace directory persistence, convenient for project management
- **User permissions**: Runs as node user, conforming to security best practices
- **Environment isolation**: Each container has independent Python environment
- **Startup optimization**: Automatically fixes configuration file permissions, eliminating startup warnings

## Quick Start

### Image Packaging and Publishing

```bash
.\build.sh      # Local
.\build-prd.sh  # Remote
```

### Using Docker Compose

```bash
# Create data volumes
docker volume create n8n_data
docker volume create n8n_workspace
docker volume create n8n_pipx

# Start service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop service
docker-compose down
```

## Image Testing

In n8n Execute Command nodes, you can use the following commands:

### Basic Function Testing

```bash
# View all available Python versions
uv python list

# Verify current version
python --version

# Run Python script
python -c "import sys; print(f'Python version: {sys.version}')"
```

### Project Management and Package Management Testing

Available commands: pip, uv, pipx. When operating in n8n Execute Command nodes, it's recommended to prioritize using pipx. For some temporary running scenarios, you can use uv or pip for implementation (but you need to focus on solving Alpine Linux package management dependency issues).

When using pipx, you need to upload the executable code package to an accessible repository, then download and run it in the n8n Execute Command node. The downloaded executable packages will be persistently stored in the `n8n_pipx` data volume.

#### ==========================pipx Usage==========================

- When the package to be installed has executable commands, prioritize using pipx for installation

```bash
pipx install --index-url https://pypi.tuna.tsinghua.edu.cn/simple mcp-server-time
```

- Clear cache and reload Shell

```bash
hash -r
exec $SHELL
```

- Execute and run
```bash
mcp-server-time --local-timezone "Asia/Shanghai"
```

#### ==========================pip Usage==========================

- Create virtual environment, install packages, then exit virtual environment after installation

```bash
python -m venv .venv && source .venv/bin/activate && pip install llmcompiler --index-url https://pypi.tuna.tsinghua.edu.cn/simple && deactivate
```

- Create run.py

```python
from llmcompiler.result.chat import ChatRequest
from llmcompiler.tools.basic import Tools
from langchain_openai.chat_models.base import ChatOpenAI
from llmcompiler.chat.run import RunLLMCompiler

chat = ChatRequest(message="<YOUR_MESSAGE>")

print(chat)
```

- Test run

```bash
pip install langgraph==0.1.19
source .venv/bin/activate && python run.py # Version dependencies can be ignored, mainly to verify program environment installation method
```

#### ==========================uv Usage==========================

- Create test project and initialize

```bash
mkdir test && cd test && uv init
```

- Test run

```bash
cd /workspace/test && uv run main.py
```

### Actual Application Examples in n8n

Switch to n8n Execute Command node to execute tests.

```bash
mcp-server-time --local-timezone "Asia/Shanghai" # This is just an example, running won't return results and will keep showing loading, indicating CLI installation is normal
```

```bash
python -c "
import pandas as pd
print('Pandas version:', pd.__version__)
"
```

### Tool Testing

```bash
# Test common system tools
curl --version && wget --version && git --version && unzip -v && zip -v && tar --version && gzip --version && bash --version

# Test compilation tools
gcc --version && g++ --version && cargo --version && pkg-config --version

# Test Python-related tools
python3 --version && pip3 --version && uv --version && pipx --version

# Test development tools
vim --version && jq --version && tree --version && less --version

# Test system monitoring tools
htop --version && ncdu --version && ps --version && free --version && uptime --version

# Test search tools
rsync --version

# Test mathematical calculation libraries
python3 -c "import numpy; print('NumPy version:', numpy.__version__)" && python3 -c "import pandas; print('Pandas version:', pandas.__version__)"

# Test Python version management
uv python list && uv --version

# Test package management tools
pip3 list > /workspace/pip_list.txt && cat /workspace/pip_list.txt | head -100
```
