FROM ubuntu:latest

# 安装ssh
RUN	apt-get update && \
	echo -e '1\n1' | \
	apt-get install -y ssh

RUN	mkdir -p /config /etc/clash/clash-dashboard /etc/config /.config/clash/ /root/.config

ADD	./sshlog.sh /
ADD	./start.sh /
ADD	./adduser.sh /
ADD	./etcconfig/ /etc
ADD	./clash-linux-amd64 /root/
ADD	./clash-dashboard /etc/clash/clash-dashboard

# 设置中国上海时区
ENV	TimeZone=Asia/Shanghai
RUN	ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime && echo $TimeZone > /etc/timezone

# 软连接和执行权限的添加
RUN	ln -s /.config/clash/ /root/.config/ && \
	ln -s /.config/clash/ / && \
	chmod +x /sshlog.sh && \
	chmod u+x /root/clash-linux-amd64 /start.sh /adduser.sh

# pam的ssh日志配置,ssh禁止打印默认信息
RUN	echo 'session	required	 pam_exec.so /sshlog.sh' >> /etc/pam.d/sshd && \
	echo 'PrintLastLog no' >> /etc/ssh/sshd_config && \
	rm -rf /etc/legal && \
	rm -rf /etc/update-motd.d/*

EXPOSE 22
EXPOSE 9090

CMD /start.sh
