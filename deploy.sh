#!/bin/bash

# Quartz GitHub Pages 自动部署脚本
# 由 OpenClaw 生成

set -e

echo "🚀 Quartz → GitHub Pages 部署脚本"
echo "================================="
echo ""

# 1. 检查是否在正确的目录
if [ ! -f "quartz.config.ts" ]; then
    echo "❌ 错误：请在 quartz-site 目录运行此脚本"
    echo "   cd ~/.openclaw/workspace/wiki/quartz-site"
    exit 1
fi

# 2. 获取 GitHub 信息
echo "📝 第一步：配置 GitHub 信息"
echo ""
read -p "请输入你的 GitHub 用户名: " github_username
read -p "请输入你的 GitHub 邮箱: " github_email
read -p "请输入仓库名（建议: my-wiki）: " repo_name

# 3. 配置 Git
echo ""
echo "⚙️  配置 Git..."
git config --global user.name "$github_username"
git config --global user.email "$github_email"
echo "✅ Git 配置完成"

# 4. 更新 quartz.config.ts
echo ""
echo "📝 更新 Quartz 配置..."
backup_file="quartz.config.ts.backup.$(date +%s)"
cp quartz.config.ts "$backup_file"
echo "   备份已创建: $backup_file"

# 简单的配置更新（保留原有配置结构）
sed -i '' "s|pageTitle:.*|pageTitle: \"${github_username}的知识库\",|g" quartz.config.ts
sed -i '' "s|locale:.*|locale: \"zh-CN\",|g" quartz.config.ts
sed -i '' "s|baseUrl:.*|baseUrl: \"${github_username}.github.io/${repo_name}\",|g" quartz.config.ts

echo "✅ 配置更新完成"

# 5. 初始化 Git
echo ""
echo "🔧 初始化 Git 仓库..."
if [ -d ".git" ]; then
    git remote remove origin 2>/dev/null || true
fi
git init
git add .
git commit -m "Initial commit: Deploy to GitHub Pages" 2>/dev/null || echo "   (已有提交，跳过)"
echo "✅ Git 初始化完成"

# 6. 关联远程仓库
echo ""
echo "🔗 关联 GitHub 仓库..."
git remote add origin "https://github.com/${github_username}/${repo_name}.git" 2>/dev/null || \
    git remote set-url origin "https://github.com/${github_username}/${repo_name}.git"
echo "✅ 远程仓库已关联"

# 7. 提示创建仓库
echo ""
echo "⚠️  请确保你已经在 GitHub 创建了仓库！"
echo ""
echo "   1. 访问: https://github.com/new"
echo "   2. Repository name: $repo_name"
echo "   3. 选择 Public（公开）"
echo "   4. 不要勾选 'Add a README file'"
echo "   5. 点击 'Create repository'"
echo ""
read -p "已创建仓库？按回车继续... " -r

# 8. 推送代码
echo ""
echo "📤 推送代码到 GitHub..."
git branch -M main
if git push -u origin main 2>&1 | grep -q "fatal"; then
    echo ""
    echo "❌ 推送失败！可能的原因："
    echo "   1. 仓库不存在"
    echo "   2. 需要 GitHub 登录认证"
    echo ""
    echo "请手动执行："
    echo "   git push -u origin main"
    exit 1
fi
echo "✅ 代码推送成功"

# 9. 部署到 GitHub Pages
echo ""
echo "🚀 部署到 GitHub Pages..."
npx quartz sync

# 10. 完成
echo ""
echo "🎉 部署完成！"
echo ""
echo "📍 你的网站地址:"
echo "   https://${github_username}.github.io/${repo_name}"
echo ""
echo "⏰ GitHub Pages 需要 2-3 分钟构建，请稍后访问"
echo ""
echo "💡 以后更新只需运行:"
echo "   npx quartz sync"
echo ""
echo "📚 查看完整文档:"
echo "   cat ~/.openclaw/workspace/wiki/deploy-guide.md"
