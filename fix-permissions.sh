#!/bin/sh

# n8n 权限修复脚本
# 用于在容器启动时自动修复权限问题

echo "🔧 正在修复 n8n 权限设置..."

# 确保 n8n 配置目录存在并设置正确权限
if [ -d "/home/node/.n8n" ]; then
    echo "📁 设置 n8n 配置目录权限..."
    chmod 700 /home/node/.n8n
    
    # 修复配置文件权限
    if [ -f "/home/node/.n8n/config" ]; then
        echo "📄 修复配置文件权限..."
        chmod 600 /home/node/.n8n/config
    fi
    
    # 修复其他敏感文件权限
    for file in /home/node/.n8n/*.json; do
        if [ -f "$file" ]; then
            echo "🔒 设置 $file 权限为 600..."
            chmod 600 "$file"
        fi
    done
    
    # 确保 workspace 目录权限正确
    if [ -d "/home/node/.n8n/workspace" ]; then
        echo "📂 设置 workspace 目录权限..."
        chmod 755 /home/node/.n8n/workspace
    fi
fi

# 确保 node 用户拥有所有文件
echo "👤 设置文件所有者..."
chown -R node:node /home/node/.n8n

echo "✅ 权限修复完成！"

# 启动 n8n
echo "🚀 启动 n8n..."
exec n8n start 