---
published: true
author: Wayne Sun
layout: post
title: Jenkins+Gitlab+K8S实现持续化集成
category: Other
summary: 最近听说GitHub Pages支持了自己的HTTPS服务，就想着把很久之前搭建的JekyII个人博客换成HTTPS访问，由于之前用的Cloud Flare免费的SSL，总感觉访问速度受到了限制（可能是幻觉），就去掉了，这次看看Github自带的Let's Encrypt证书效果如何。
tags:
  - GitHub Pages
  - HTTPS
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
