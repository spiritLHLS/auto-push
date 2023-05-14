#!/bin/bash
#from https://github.com/spiritLHLS/auto-push

# 指定作者的GitHub用户名
author="spiritlhls"

# 声明存储文件链接的数组
file_urls=()
blob_urls=()

# 获取作者的所有仓库
# repos=$(curl -s "https://api.github.com/users/$author/repos?per_page=100" | grep -o 'git@[^"]*')

# 非fork仓库
repos=$(curl -s "https://api.github.com/users/$author/repos?per_page=100" | jq -r '.[] | select(.fork == false) | .ssh_url')

# 识别的行开头
head='xxx'

# 需要替换的行内容
text='xxxx'

# 遍历每个仓库
for repo in $repos; do
    echo "检查仓库: $repo"
    git clone $repo temp_repo 2>/dev/null
    cd temp_repo || continue
    repo_name=$(basename "$repo" .git)
    shell_files=$(grep -r "${head}" --include=*.sh | awk -F: '{print $1}')
    if [ ! -z "$shell_files" ]; then
        for file in $shell_files; do
            branch=$(git rev-parse --abbrev-ref HEAD)
            path=$(dirname "$file")
            path=${path#"."}  # 如果路径以"."开头，则去掉"."
            if [ ! -z "$path" ]; then
                path="${path}/"
            fi
            filename=$(basename "$file")
            # https://github.com/spiritLHLS/ecs/blob/main/ecs.sh
            raw_url="https://github.com/$author/blob/$repo_name/$branch/$path$filename"
            blob_urls+=($raw_url)
            raw_url="https://raw.githubusercontent.com/$author/$repo_name/$branch/$path$filename"
            file_urls+=($raw_url)
        done
    fi
    cd ..
    rm -rf temp_repo
done

# 打印存储文件链接的数组
echo "包含指定行的Shell文件的Raw文件链接："
for url in "${blob_urls[@]}"; do
    echo "$url"
done

# 处理对应行
rm -rf result.txt
for index in "${!file_urls[@]}"; do
  url="${file_urls[$index]}"
  blob="${blob_urls[$index]}"
  file_path=$(echo "$url" | awk -F'[/]' '{for(i=1;i<=NF;i++)if($i=="main"||$i=="master"){for(j=i+1;j<=NF;j++)printf "%s/",$j}}' | sed 's/.$//')
  temp_file=$(mktemp)
  if ! curl -s "$url" -o "$temp_file"; then
    echo "无法下载文件: $url"
    continue
  fi
  line_number=$(grep -n "^${head}" "$temp_file" | cut -d ':' -f 1)
  [ -z "$line_number" ] && continue
  repository=$(echo "$blob" | cut -d'/' -f6)
  author=$(echo "$blob" | cut -d'/' -f4)
  git_url="git@github.com:$author/$repository.git"
  echo "$git_url:$file_path:$line_number" >> result.txt
  rm "$temp_file"
done

echo "检测到需要修改的部分:"
cat result.txt

while IFS= read -r line
do
    # 切分第一部分
    first_part=$(echo "$line" | cut -d '/' -f 1)
    
    # 切分后面部分
    rest=$(echo "$line" | cut -d '/' -f 2-)
    second_part=$(echo "$rest" | cut -d ':' -f 1)
    third_part=$(echo "$rest" | cut -d ':' -f 2)
    fourth_part=$(echo "$rest" | cut -d ':' -f 3)
    
    # 组合结果
    git_link="$first_part/$second_part"
    repo_name="${second_part%.git}"
    line_number="$fourth_part"
    
    # 克隆远程仓库
    git clone "$git_link"
    cd "$repo_name"

    # 获取文件名
    file_name=$(basename "$third_part")
    
    # 覆盖指定行
    sed -i "${line_number}s|.*|${text}|" "./${third_part}"

    # 添加修改的文件到暂存区
    git add "./${third_part}"
    git commit -m "修改 $file_name"

    # 推送更改到远程仓库
    git push
    
    # 返回到脚本的初始目录
    cd /root
    
    rm -rf "./${repo_name}"
done < result.txt

rm -rf result.txt
