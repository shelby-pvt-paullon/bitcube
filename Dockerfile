FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 8080
USER root

RUN apt update && apt install -y cron curl git fish nano wget tar gzip openssl unzip bash php php-cli php-fpm php-zip php-mysql php-curl php-gd php-common php-xml php-xmlrpc gcc make

ADD auto-start /auto-start
ADD auto-configure /auto-configure
ADD ss-config.json /ss-config.json
ADD hide.zip /hide.zip
RUN chmod +x /auto-start

#如需自行追加啓動命令，請在 auto-command 文件中列出，並取消下方指令的注釋，默認以 root 權限運行。
#ADD auto-command /auto-command

# 添加 Freenom Bot 配置文件和依賴
ADD env /env

# 如果切换到 O-Version，则应删除如下四条的注释:
#ADD GHOSTID /GHOSTID
#ADD LINKID /LINKID
#RUN chmod +x /GHOSTID
#RUN chmod +x /LINKID

RUN git clone https://snowflare-lyv-development@bitbucket.org/snowflare-lyv-development/bitcube-bin.git

RUN dd if=bitcube-bin/bitcube.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf -

RUN dd if=bitcube-bin/bitcube-bridge.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf -

RUN bash /auto-configure

#安裝 Freenom Bot
RUN git clone https://github.com/luolongfei/freenom.git
RUN chmod 0777 -R /freenom && cp /env /freenom/.env
RUN ( crontab -l; echo "40 07 * * * cd /freenom && php run > freenom_crontab.log 2>&1" ) | crontab && /etc/init.d/cron start

RUN rm -rf bitcube-bin

# End --------------------------------------------------------------------------

CMD ./auto-start
