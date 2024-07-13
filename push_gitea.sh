#!/bin/bash
# from https://github.com/spiritLHLS/auto-push

utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  echo "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  echo "Locale set to $utf8_locale"
fi

# 设置变量
repo_url="http://xxxxxxx:3000/用户名/仓库名.git" # 使用HTTP远程地址
commit_message="Auto update" # 提交时相应的说明
branch="main" # 远程分支
remote_folder="" # 远程仓库的目录，为空则是根目录
local_repo_dir="temp" # 缓存文件夹，跑完后自动删除无需修改

# 创建本地Git仓库
mkdir $local_repo_dir
cd $local_repo_dir
git init

# 创建本地分支并切换到该分支
git checkout -b $branch

# 设置远程仓库
git remote add origin $repo_url

# 增大传送限制
git config http.postBuffer 41943040000

# 拉取远程仓库更改并合并到本地仓库
git pull origin $branch --rebase

# 使用rsync复制文件到远程仓库目录，并排除指定路径
# /root/item1/ 替换为 你的项目的根目录的绝对路径
rsync -av --exclude='push.sh' --exclude='temp' /root/item1/ ./$remote_folder

# 添加所有文件到暂存区
git add .

# 提交变更
git commit -m "$commit_message"

# 推送到远程仓库
git push -f origin $branch

# 返回上一级目录
cd ..

# 删除缓存文件夹
rm -rf $local_repo_dir
