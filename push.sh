#!/bin/bash

# 设置变量
repo_url="git@github.com:spiritLHLS/auto-push.git" #改成你的SSH远程地址
commit_message="Auto update" # 提交时相应的说明
branch="main" # 远程分支
remote_folder="" # 为空则是根目录
local_repo_dir="temp" # 缓存文件夹，跑完后自动删除无需修改

# 创建本地Git仓库
mkdir $local_repo_dir
cd $local_repo_dir
git init

# 创建本地分支并切换到该分支
git checkout -b $branch

# 设置远程仓库
git remote add origin $repo_url

# 拉取远程仓库更改并合并到本地仓库
git pull origin $branch --rebase

# 将需要上传的文件复制到仓库的目录下
cp 你的文件的绝对路径 ./$remote_folder

# 添加所有文件到暂存区
git add .

# 提交变更
git commit -m "$commit_message"

# 将本地仓库与远程仓库关联
git remote add origin $repo_url

# 推送到远程仓库
git push -f origin $branch

# 返回上一级目录
cd ..

# 删除缓存文件夹
rm -rf $local_repo_dir
