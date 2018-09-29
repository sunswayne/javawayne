---
published: true
author: Wayne Sun
layout: post
title: Jenkins+Gitlab+K8S实现持续化集成
category: DevOps
summary: 自从公司项目大量采用了docker微服务架构，本地编译打包，再加上手动部署k8s已经难以满足我们的需求，毕竟这已经浪费了我们太多的时间。所以研究着如何把Jenkins搭建起来，从此跟随潮流，走上<tt>DevOps</tt>的康庄大道。
tags:
  - docker
  - jenkins
---

`文/孙少伟`

自从公司项目大量采用了docker微服务架构，本地编译打包，再加上手动部署k8s已经难以满足我们的需求，毕竟这已经浪费了我们太多的时间。所以研究着如何把Jenkins搭建起来，从此跟随潮流，走上DevOps的康庄大道。

## 部署Gitlab ##
---
1.拉取镜像
``` bash
docker pull gitlab/gitlab-ce
```

2.运行gitlab实例
``` bash
GITLAB_HOME=`pwd`/data/gitlab
docker run -d \
    --hostname gitlab \
    --publish 8443:443 --publish 80:80 --publish 2222:22 \
    --name gitlab \
    --restart always \
    --volume $GITLAB_HOME/config:/etc/gitlab \
    --volume $GITLAB_HOME/logs:/var/log/gitlab \
    --volume $GITLAB_HOME/data:/var/opt/gitlab \
    gitlab/gitlab-ce
```
3.配置实例
``` bash
docker exec -t -i gitlab vim /etc/gitlab/gitlab.rb
```

4.配置外部访问路径
``` bash
external_url "http://xxx.xxx.xxx.xxx"
```

5.重启gitlab
``` bash
docker restart gitlab
```
## 部署Jenkins ##
---
1.拉取镜像：
``` bash
sudo docker pull jenkins
```

2.创建Dockerfile：
``` bash
FROM jenkins
USER root
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/* 
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
USER jenkins
```

3.构建Jenkins（Dockerfile所在目录）
``` bash
docker build -t jenkins:1.0 .
```

4.启动Jenkins
``` bash
docker run -d -p 80:8080 jenkins:1.0
```

### 插件 ###
- Java
- Git
- Maven

5.取消认证

取消勾选Enable authentication for '/project' end-point

6.k8s配置

![github_devops_k8s](https://i.loli.net/2018/09/29/5baf258fdfc20.png)


