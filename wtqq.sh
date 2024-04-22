#!/bin/bash
# wtqq.sh

is_number() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    return 1
  else
    return 0
  fi
}

print_welcome() {
  clear
  echo "██╗     ██╗   ██╗ ██████╗ ███╗   ███╗██╗   ██╗██████╗ ██╗     ██╗██╗"
  echo "██║     ██║   ██║██╔═══██╗████╗ ████║██║   ██║██╔══██╗██║     ██║██║"
  echo "██║     ██║   ██║██║   ██║██╔████╔██║██║   ██║██████╔╝██║     ██║██║"
  echo "██║     ██║   ██║██║   ██║██║╚██╔╝██║██║   ██║██╔══██╗██║██   ██║██║"
  echo "███████╗╚██████╔╝╚██████╔╝██║ ╚═╝ ██║╚██████╔╝██████╔╝██║╚█████╔╝██║"
  echo "╚══════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚═╝ ╚════╝ ╚═╝"
  echo "                落幕笔记-https://www.luomubiji.host"
  echo "欢迎使用本脚本，本脚本由落幕笔记官网提供，脚本可能会有更新，"
  echo "建议去落幕笔记官网时刻查看是否有最新的动态。"
  echo "如果遇到问题欢迎加QQ群:420035660"
  echo "本脚本适用于arm和amd架构的服务器和无界/autMan，请确认自己的架构是否支持。"
  echo "本脚本运行后会删除您设备上原来的相关WTQQ镜像和WTQQ容器，以便支持最新的镜像版本。"
  echo
  read -p "如您同意以上内容并继续，请按y，否则请按q退出: " choice
  case "$choice" in 
    y|Y ) echo "继续执行脚本..." ;;
    q|Q ) echo "退出脚本。"; exit 0 ;;
    * ) echo "输入无效，脚本退出。"; exit 1 ;;
  esac
}


check_and_remove_image_container() {
  local wtqq_image=$(docker images -q luomubiji/wtqq:latest)
  local wtqq_container=$(docker ps -a -q --filter ancestor=luomubiji/wtqq:latest)

  if [[ $wtqq_image || $wtqq_container ]]; then
    read -p "检测到存在的镜像或容器 'luomubiji/wtqq:latest', 是否删除？(y/N): " remove_choice
    if [[ $remove_choice =~ ^[Yy]$ ]]; then
      docker rm -f $(docker ps -a -q --filter ancestor=luomubiji/wtqq:latest)
      docker rmi luomubiji/wtqq:latest
    fi
  else
    echo "不存在 'luomubiji/wtqq:latest' 镜像或容器。稍后会拉取！"
  fi
}

check_and_remove_wtqq_directory() {
  if [[ -d "wtqq" ]]; then
    read -p "检测到存在的文件夹 'wtqq', 是否删除？(y/N): " remove_dir_choice
    if [[ $remove_dir_choice =~ ^[Yy]$ ]]; then
      rm -rf wtqq
    fi
  fi
  mkdir -p wtqq
}

get_latest_release_version() {
  local repo="NapNeko/NapCatQQ"
  local api_url="https://api.github.com/repos/${repo}/releases/latest"
  local tag_name=$(curl -s "${api_url}" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
  
  echo $tag_name
}

download_napcat() {
  local arch=$(uname -m)
  local zip_url
  local tag_name="$(get_latest_release_version)"

  if [ "$arch" = "x86_64" ]; then
    zip_url="https://github.com/NapNeko/NapCatQQ/releases/download/${tag_name}/NapCat.linux.x64.zip"
  elif [ "$arch" = "aarch64" ]; then
    zip_url="https://github.com/NapNeko/NapCatQQ/releases/download/${tag_name}/NapCat.linux.arm64.zip"
  else
    echo "不支持的系统架构: $arch"
    exit 1
  fi

  echo "正在下载 $zip_url ..."
  curl -L -o NapCat.linux.zip "$zip_url" && unzip -q NapCat.linux.zip -d ./temp_napcat && \
  if [[ -d temp_napcat/NapCat.linux.x64 ]]; then
    rm -rf wtqq/*
    mv -v temp_napcat/NapCat.linux.x64/* wtqq/
    rmdir temp_napcat/NapCat.linux.x64
  elif [[ -d temp_napcat/NapCat.linux.arm64 ]]; then
    rm -rf wtqq/*
    mv -v temp_napcat/NapCat.linux.arm64/* wtqq/
    rmdir temp_napcat/NapCat.linux.arm64
  fi
  rmdir temp_napcat
  rm NapCat.linux.zip
  echo "下载完成后，创建容器~耐心等！"
}


configure_bot() {
  read -p "请选择您要配置的平台类型 (输入1或2)：
  1) 无界
  2) autMan: " platform_choice

  case "$platform_choice" in
    1)
      endpoint="/api/bot/qqws"
      ;;
    2)
      endpoint="/qq/receive"
      ;;
    *)
      echo "选择错误，脚本退出。"
      exit 1
      ;;
  esac

  read -p "请输入机器人QQ号：" qq_number
  until is_number "$qq_number"; do
    echo "QQ号必须是数字，请重新输入。"
    read -p "请输入机器人QQ号：" qq_number
  done

  read -p "请输入无界/autMan IP地址或域名：" server_ip
  read -p "请输入无界/autMan 端口号：" server_port
  echo "配置完成。"
}

start_wtqq_container() {
  docker pull luomubiji/wtqq:latest
  docker run -d -e ACCOUNT="$qq_number" -e WSR_ENABLE=true -e WS_URLS="ws://$server_ip:$server_port$endpoint" -v /root/wtqq/:/usr/src/app/napcat/ --name wtqq luomubiji/wtqq:latest
  echo "容器 wtqq 正在启动，请等待20秒..."
  sleep 20
}

update_config_and_rename() {
  local qq_number="$1"
  local server_ip="$2"
  local server_port="$3"
  local endpoint="$4"
  local config_dir="/root/wtqq/config"
  local new_config_file="${config_dir}/onebot11_${qq_number}.json"

  echo "Debugging Variables:"
  echo "QQ Number: $qq_number"
  echo "Server IP: $server_ip"
  echo "Server Port: $server_port"
  echo "Endpoint: $endpoint"
  
  rm -f ${config_dir}/*.json
  
  cat << EOF > "${new_config_file}"
{
  "httpPort": 3000,
  "httpPostUrls": [""],
  "httpSecret": "",
  "wsPort": 3001,
  "wsReverseUrls": ["ws://${server_ip}:${server_port}${endpoint}"],
  "enableHttp": false,
  "enableHttpPost": false,
  "enableWs": false,
  "enableWsReverse": true,
  "messagePostFormat": "string",
  "reportSelfMessage": false,
  "debug": false,
  "enableLocalFile2Url": true, 
  "heartInterval": 30000,
  "token": ""
}
EOF
  echo "配置文件已更新。"
}

print_welcome
check_and_remove_image_container
check_and_remove_wtqq_directory
configure_bot
download_napcat
start_wtqq_container
update_config_and_rename "$qq_number" "$server_ip" "$server_port" "$endpoint"

docker restart wtqq
echo "容器配置发生变更，正在重启..."

echo "等待15秒后出二维码，请准备好机器人所在的手机扫描二维码登录..."
sleep 15
docker logs wtqq

echo "脚本执行完毕，退出，如果后续要二维码请发送：docker logs wtqq出码，建议重启先docker restart wtqq"
