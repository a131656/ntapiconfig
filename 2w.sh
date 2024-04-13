#!/bin/bash
# 2w.sh

clear
echo "██╗     ██╗   ██╗ ██████╗ ███╗   ███╗██╗   ██╗██████╗ ██╗     ██╗██╗"
echo "██║     ██║   ██║██╔═══██╗████╗ ████║██║   ██║██╔══██╗██║     ██║██║"
echo "██║     ██║   ██║██║   ██║██╔████╔██║██║   ██║██████╔╝██║     ██║██║"
echo "██║     ██║   ██║██║   ██║██║╚██╔╝██║██║   ██║██╔══██╗██║██   ██║██║"
echo "███████╗╚██████╔╝╚██████╔╝██║ ╚═╝ ██║╚██████╔╝██████╔╝██║╚█████╔╝██║"
echo "╚══════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚═╝ ╚════╝ ╚═╝"
echo "██╗    ██╗ ██████╗  ██████╗ ██╗     ██╗    ██╗███████╗██████╗ "
echo "██║    ██║██╔═══██╗██╔═══██╗██║     ██║    ██║██╔════╝██╔══██╗"
echo "██║ █╗ ██║██║   ██║██║   ██║██║     ██║ █╗ ██║█████╗  ██████╔╝"
echo "██║███╗██║██║   ██║██║   ██║██║     ██║███╗██║██╔══╝  ██╔══██╗"
echo "╚███╔███╔╝╚██████╔╝╚██████╔╝███████╗╚███╔███╔╝███████╗██████╔╝"
echo " ╚══╝╚══╝  ╚═════╝  ╚═════╝ ╚══════╝ ╚══╝╚══╝ ╚══════╝╚═════╝ "
echo "                落幕笔记-https://www.luomubiji.host"
echo "欢迎使用本脚本，本脚本由落幕笔记官网提供，脚本可能会有更新。"
echo "建议加入下方群了解最新动态。"
echo "如果遇到问题欢迎加QQ群:637953682"
echo "本脚本适用于arm和amd架构的服务器请确认自己的架构是否支持。"
echo

read -p "如您同意以上内容并继续，请按y，否则请按q退出: " user_choice

user_choice=$1

if [ "$user_choice" != "y" ]; then
    echo "使用方式: curl -sL https://raw.githubusercontent.com/baquanluomu/ntapiconfig/main/2w.sh | sudo bash - y"
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


if [ -d "$HOME/2w" ]; then

    if [ -f "$HOME/2w/value.json" ] && [ -f "$HOME/2w/data.json" ]; then

        read -p "2w文件夹内存在value.json和data.json，是否保留这些文件？(y/n): " preserve_files
        if [ "$preserve_files" != "y" ]; then
            rm -rf "$HOME/2w"

            mkdir -p "$HOME/2w"
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
        fi
    else

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
    fi
else

    mkdir -p "$HOME/2w"
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
fi

docker run -d \
  --restart=always \
  -v "/root/2w/data.json":/app/data.json \
  -v "/root/2w/value.json":/app/value.json \
  --name 2w \
  -p 8088:80 \
  -p 3002:3002 \
  luomubiji/2w:latest

if [ $? -eq 0 ]; then
  echo "Docker镜像已成功拉取，容器已启动。"
else
  echo "拉取Docker镜像或启动容器时出现错误。"
fi
