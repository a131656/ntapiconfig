#!/bin/bash
# 2w.sh

clear
echo "██╗     ███╗   ███╗██╗   ██╗███████╗    ██████╗ ██████╗ ███╗   ███╗"
echo "██║     ████╗ ████║██║   ██║██╔════╝   ██╔════╝██╔═══██╗████╗ ████║"
echo "██║     ██╔████╔██║██║   ██║███████╗   ██║     ██║   ██║██╔████╔██║"
echo "██║     ██║╚██╔╝██║██║   ██║╚════██║   ██║     ██║   ██║██║╚██╔╝██║"
echo "███████╗██║ ╚═╝ ██║╚██████╔╝███████║██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║"
echo "╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝"
echo "██╗    ██╗ ██████╗  ██████╗ ██╗     ██╗    ██╗███████╗██████╗ "
echo "██║    ██║██╔═══██╗██╔═══██╗██║     ██║    ██║██╔════╝██╔══██╗"
echo "██║ █╗ ██║██║   ██║██║   ██║██║     ██║ █╗ ██║█████╗  ██████╔╝"
echo "██║███╗██║██║   ██║██║   ██║██║     ██║███╗██║██╔══╝  ██╔══██╗"
echo "╚███╔███╔╝╚██████╔╝╚██████╔╝███████╗╚███╔███╔╝███████╗██████╔╝"
echo " ╚══╝╚══╝  ╚═════╝  ╚═════╝ ╚══════╝ ╚══╝╚══╝ ╚══════╝╚═════╝ "
echo "                落幕屋-https://lmu5.com"
echo "欢迎使用本脚本，本脚本由落幕屋官网提供，脚本可能会有更新，"
echo "建议去落幕屋官网时刻查看是否有最新的动态。"
echo "如果遇到问题欢迎加QQ群:637953682"
echo "本脚本适用于arm和amd架构的服务器请确认自己的架构是否支持。"
echo

read -p "如您同意以上内容并继续，请按y，否则请按q退出: " user_choice

if [ "$user_choice" != "y" ]; then
    echo "您选择退出。"
    exit 0
fi

container_id=$(docker ps -aqf "name=^2w$")
if [ ! -z "$container_id" ]; then
    
    read -p "已存在名为2w的容器/镜像，是否删除并继续？(y/n): " should_delete_container
    if [ "$should_delete_container" = "y" ]; then
        docker rm -f "$container_id" && echo "已删除容器：$container_id"
    else
        echo "由于您选择不删除容器，脚本退出。"
        exit 0
    fi
fi

image_id=$(docker images -q luomubiji/2w:latest)
if [ ! -z "$image_id" ]; then

    docker rmi -f "$image_id" && echo "已删除镜像：$image_id"
fi

if [ ! -d "$HOME/2w" ]; then
    echo "检测到系统没有2w相关文件夹和文件，正在创建..."
    mkdir -p "$HOME/2w"
fi

files_exist=0
if [ -f "$HOME/2w/value.json" ] && [ -f "$HOME/2w/data.json" ]; then
    files_exist=1
    read -p "2w文件夹内存在value.json和data.json，是否保留这些文件？(y/n): " preserve_files
    if [ "$preserve_files" != "y" ]; then

        echo "正在删除现有文件，并创建2w所需文件..."
        rm -f "$HOME/2w/value.json" "$HOME/2w/data.json"
        files_exist=0
    fi
fi

if [ $files_exist -eq 0 ]; then
    echo '{
  "applist": [

  ]
}' > "$HOME/2w/value.json"

    echo '{
  "web": {
    "name": "",
    "notice": ""
  },
  "qinglong": {
    "url": "",
    "id": "",
    "secret": "",
    "version": "new"
  },
  "admin": {
    "username": "",
    "password": ""
  }
}' > "$HOME/2w/data.json"
    echo "2w相关文件创建完成。"
fi

echo "正在拉取2w镜像，请稍等..."

docker run -d \
  --restart=always \
  -v "/root/2w/data.json":/app/data.json \
  -v "/root/2w/value.json":/app/value.json \
  --name 2w \
  -p 8088:80 \
  -p 3002:3002 \
  registry.cn-hangzhou.aliyuncs.com/smallfawn/2w:latest

if [ $? -eq 0 ]; then
  echo "2wDocker镜像已成功拉取，2w容器已启动。"
else
  echo "拉取2wDocker镜像或启动容器时出现错误。"
fi
