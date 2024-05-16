#!/bin/bash

LOG_DIR="/var/main"
SSH_LOG="$LOG_DIR/ssh.log"
MAIN_LOG="$LOG_DIR/main.log"

# 确保日志目录存在
mkdir -p $LOG_DIR

# 获取当前时间戳，以指定格式显示日期
current_time=$(date +"[%y/%m/%d %H:%M:%S]")

# 将当前时间转换为 UNIX 时间戳
current_unix_time=$(date +%s)

# 检查登录或登出事件类型并记录到相应日志文件
if [ "$PAM_TYPE" = "open_session" ]; then
    echo "$current_time - SSH 登录: 用户 $PAM_USER 从 $PAM_RHOST" >> $SSH_LOG
    echo "$current_time - SSH 登录: 用户 $PAM_USER 从 $PAM_RHOST" >> $MAIN_LOG
    # 记录登录时间戳到临时文件
    echo "$current_unix_time" > "/tmp/ssh_login_time_$PAM_USER"
elif [ "$PAM_TYPE" = "close_session" ]; then
    if [ -f "/tmp/ssh_login_time_$PAM_USER" ]; then
        # 获取登录时间戳
        login_unix_time=$(cat "/tmp/ssh_login_time_$PAM_USER")
        # 计算连接时间
        duration=$((current_unix_time - login_unix_time))
        # 删除临时文件
        rm "/tmp/ssh_login_time_$PAM_USER"
        
        # 转换连接时间为小时/分钟/秒
        hours=$((duration / 3600))
        minutes=$(( (duration % 3600) / 60))
        seconds=$((duration % 60))

        echo "$current_time - SSH 登出: 用户 $PAM_USER 从 $PAM_RHOST, 连接时间: ${hours}小时${minutes}分钟${seconds}秒" >> $SSH_LOG
        echo "$current_time - SSH 登出: 用户 $PAM_USER 从 $PAM_RHOST, 连接时间: ${hours}小时${minutes}分钟${seconds}秒" >> $MAIN_LOG
    else
        echo "$current_time - SSH 登出: 用户 $PAM_USER 从 $PAM_RHOST, 无法计算连接时间" >> $SSH_LOG
        echo "$current_time - SSH 登出: 用户 $PAM_USER 从 $PAM_RHOST, 无法计算连接时间" >> $MAIN_LOG
    fi
elif [ "$PAM_TYPE" = "auth_fail" ]; then
    echo "$current_time - SSH 登录失败: 用户 $PAM_USER 从 $PAM_RHOST" >> $SSH_LOG
    echo "$current_time - SSH 登录失败: 用户 $PAM_USER 从 $PAM_RHOST" >> $MAIN_LOG
fi

