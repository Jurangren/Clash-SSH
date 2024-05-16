<a name="A1OuV"></a>
# Clash-SSH Docker
基于Docker，以SSH连接为接入方式的多用户认证Clash Proxy接入方案
<a name="lksUg"></a>
## 部署

1. clone本项目，cd到`clash-ssh/`文件夹下
2. 将你的clash订阅文件`config.yaml`下载到`clash-ssh/config/`下，并且需要添加下图所示红框里的内容

![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715848932361-83b3ffca-1bc8-4622-aef1-ab8ed301050f.png#averageHue=%232b2b37&clientId=uff897a29-4d8a-4&from=paste&height=758&id=ua3b5a283&originHeight=758&originWidth=1721&originalType=binary&ratio=1&rotation=0&showTitle=false&size=260223&status=done&style=none&taskId=u4d60030b-d04d-46ee-8891-2111696d56c&title=&width=1721)

3. 如果需要修改开放端口（默认`1111,9091`），请修改`docker-compose.yaml`中的`ports`部分

![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715843371750-0b070ca1-9e5c-489d-85a9-356958a5cc0a.png#averageHue=%2330303f&clientId=uff897a29-4d8a-4&from=paste&height=58&id=u0455290f&originHeight=58&originWidth=281&originalType=binary&ratio=1&rotation=0&showTitle=false&size=5316&status=done&style=none&taskId=u8ee1aad0-5d71-4e38-aff8-b64746b2792&title=&width=281)

4. 启动/关停/查看日志
- 首次启动：`sudo docker-compose up -d`，等待Dockerfile构建完毕需要等待一段时间

![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715843386971-b5105eb9-b39b-48af-8e09-d96ef3e62e77.png#averageHue=%232e2d3c&clientId=uff897a29-4d8a-4&from=paste&height=556&id=u5860ccd7&originHeight=556&originWidth=1244&originalType=binary&ratio=1&rotation=0&showTitle=false&size=118046&status=done&style=none&taskId=u2c4cee38-da28-46d9-ae6c-4f455ee559f&title=&width=1244)

- 之后每次启动：`sudo docker-compose start`
- 关停：`sudo docker-compose stop`
- 日志查看：`tail -f config/main.log`或`docker logs -f clash-clash-1`
<a name="xNr0A"></a>
## 用户添加/删除

1. `docker exec -it clash-ssh-clash-1 bash`进入容器bash
2. 用户添加：`/adduser.sh <用户名> <密码>`，相当于执行`useradd -m -p $(openssl passwd -1 $password) -s /bin/tee $username`，登录进来的用户shell为`/bin/tee`
3. 用户删除：`userdel <用户名>`

![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715843957764-e498d7be-b209-4e4c-9683-a90d7bb631d1.png#averageHue=%2330303e&clientId=uff897a29-4d8a-4&from=paste&height=146&id=u767e44fb&originHeight=146&originWidth=848&originalType=binary&ratio=1&rotation=0&showTitle=false&size=36026&status=done&style=none&taskId=u28048247-96e5-403a-b0de-1c7058cb5b0&title=&width=848)
<a name="vxDDa"></a>
## 连接和使用

1. 用户通过连接部署的clash-ssh暴露在外部的ssh端口，并使用`-D`设置一个本地动态转发端口：`ssh -D <Lport> <user>@<ip> -p1111`

![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715844269368-98ffbb13-6562-4f91-9b6c-71d2ec05de63.png#averageHue=%232b2c38&clientId=uff897a29-4d8a-4&from=paste&height=312&id=u9d8a07e1&originHeight=312&originWidth=714&originalType=binary&ratio=1&rotation=0&showTitle=false&size=34917&status=done&style=none&taskId=ua67b76c1-f197-4237-8ad7-c9fcd1cc425&title=&width=714)

2. 用户使用`socks5://127.0.0.1:<Lport>`即可接通代理

![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715844771328-6b468445-b361-4d6b-8a08-7a74cce91266.png#averageHue=%232c2d39&clientId=uff897a29-4d8a-4&from=paste&height=186&id=udddd1efe&originHeight=186&originWidth=906&originalType=binary&ratio=1&rotation=0&showTitle=false&size=37287&status=done&style=none&taskId=u64af0f57-4ee2-467e-b5ad-b2a1fcda9b9&title=&width=906)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40483021/1715844631788-ae86cb4e-abd6-4451-aad7-49a7739e628a.png#averageHue=%232e2f3b&clientId=uff897a29-4d8a-4&from=paste&height=1055&id=u86ba4b95&originHeight=1055&originWidth=2486&originalType=binary&ratio=1&rotation=0&showTitle=false&size=319866&status=done&style=none&taskId=u18ad6cbf-6a51-4a31-8a41-296eb037ee1&title=&width=2486)
<a name="h9zLV"></a>
## 非Tun模式
开启Tun模式模式需要给容器添加`NET_ADMIN`特权，虽然添加用户的时候已经将登录shell设置为`/bin/tee`，但如果很介意该特权也可以关闭Tun模式

1. 修改你的clash`config.yaml`配置文件，去除掉Tun部分的内容
2. 将`docker-compose.yaml`中`cap_add: NET_ADMIN`两行删去
3. 重新构建部署，以后用户连接时使用`ssh -L <Lport>:127.0.0.1:<SocksPort> <user>@<ip> -p1111`
