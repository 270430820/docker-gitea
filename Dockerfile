#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM alpine:3.16

LABEL maintainer="ALPINE Docker Maintainers <haojiangwei@gmail.com>"

ENV GITEA_VERSION 1.17.3
ENV GITEA_HOME /app
ENV USER git
ENV GITEA_CUSTOM ${GITEA_HOME}/custom

# 设置更新源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories 
#&& echo -e  "http://mirrors.ustc.edu.cn/alpine/edge/main\nhttp://mirrors.ustc.edu.cn/alpine/edge/community\nhttp://mirrors.ustc.edu.cn/alpine/edge/testing'>/etc/apk/repositories">>/etc/apk/repositories 

# 设置时区
#RUN apk add --no-cache tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装基础软件
RUN apk -U --no-cache --no-progress add \
    bash \
    ca-certificates \
    curl \
    gettext \
    git \
    linux-pam \
    openssh \
    openssh-sftp-server \
    s6 \
    sqlite \
    su-exec \
    tzdata \
    gnupg && \
    rm -rf /var/cache/apk/*

# 安装GITEA
RUN mkdir -p ${GITEA_HOME}/{custom/conf,git,gitea} && \
  curl -f https://github.com/go-gitea/gitea/releases/download/v$GITEA_VERSION/gitea-$GITEA_VERSION-linux-386 -o ${GITEA_HOME}/gitea/gitea && \
  chmod a+x ${GITEA_HOME}/gitea/gitea && \
  ln -s ${GITEA_HOME}/gitea/gitea /usr/local/bin/gitea
  
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	addgroup -S -g 1000 git && \
    adduser -S -H -D -h ${GITEA_HOME}/git -s /bin/bash -u 1000 -G git git && \
    echo "git:$(dd if=/dev/urandom bs=24 count=1 status=none | base64)" | chpasswd && \
    chown -R git:git ${GITEA_HOME}/git

COPY root /

RUN ln -s ${GITEA_HOME}/gitea/gitea /usr/local/bin/gitea && \
    rm -rf /var/cache/apk/*

WORKDIR ${GITEA_HOME}

VOLUME [${GITEA_HOME}]

EXPOSE 22 3000

USER ${USER}:${USER}

ENTRYPOINT ["/usr/bin/entrypoint"]

CMD ["/bin/s6-svscan", "/etc/s6"]