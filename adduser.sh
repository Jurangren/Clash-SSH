#!/bin/sh

# 检查参数是否正确
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

username=$1
password=$2

# 使用 useradd 创建用户并设置密码
useradd -m -p $(openssl passwd -1 $password) $username

# 设置用户 shell 为 /bin/tee
usermod -s /bin/tee $username

echo "User $username created with password $password and shell /bin/tee"

