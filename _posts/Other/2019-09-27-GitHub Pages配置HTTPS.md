---
published: true
author: Wayne Sun
layout: post
title: GitHub Pages配置HTTPS
category: Other
summary: pages支持了自己的https服务，就想着把很久之前搭建的jekyII个人博客换成https访问，由于之前用的cloudflare免费的ssl，总感觉访问速度受到了限制（可能是幻觉），就去掉了，这次看看Github自带的Let's Encrypt证书效果如何。
tags:
  - GitHub Pages
  - HTTPS
---

`文/孙少伟`

## 起源 ##
最近听说github pages支持了自己的https服务，就想着把很久之前搭建的jekyII个人博客换成https访问，由于之前用的cloudflare免费的ssl，总感觉访问速度受到了限制（可能是幻觉），就去掉了，这次看看Github自带的Let's Encrypt证书效果如何（这名字也是够了，不过我喜欢），虽然免费版限期一年，但也很不错了，操作简单省时省力，比去搞什么第三方ssl要好得多。初体验下来，嗯，真香。

## 一、直击要害 ##
起初，我遇到了一个大家先前都遇到的问题，就是Enforce无法勾选，网上查了一下，众说纷纭，根据我的经验，干脆直接问客服。
![github_ssl_ask](https://i.loli.net/2018/09/27/5bac514b17bec.png)

## 二、CNAME域名解析 ##
不得不说国外的客服就是效率，不到20分钟，客服发邮件告诉我需要配置以下4个ip到dns记录，这和网上一部分人的说法相同，事实上经我试验，其实并没有那么麻烦，只要你配置了CNAME记录，就会自动将你的域名解析到以下4个dns。
<!-- ![github_ssl_dig](https://i.loli.net/2018/09/27/5bac553b5c831.png) -->
``` bash
Sun:~ Wayne$ dig waynesun.xyz

; <<>> DiG 9.10.6 <<>> waynesun.xyz
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 38382
;; flags: qr rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;waynesun.xyz.			IN	A

;; ANSWER SECTION:
waynesun.xyz.		600	IN	CNAME	sunswayne.github.io.
sunswayne.github.io.	3202	IN	A	185.199.110.153
sunswayne.github.io.	3202	IN	A	185.199.111.153
sunswayne.github.io.	3202	IN	A	185.199.109.153
sunswayne.github.io.	3202	IN	A	185.199.108.153

;; Query time: 586 msec
;; SERVER: 202.98.96.68#53(202.98.96.68)
;; WHEN: Thu Sep 27 10:14:58 CST 2018
;; MSG SIZE  rcvd: 138

像这样就OK了。

** 解决问题 **
而笔者在此之前配置的是A记录，直接ping了sunswayne.github.io获得IP，再配置到了DNS记录值，这样虽然可行，但是在配置CNAME记录时会警告我域名没有正确解析到github.io。
![github_ssl_cname](https://i.loli.net/2018/09/27/5bac51ac4bd7b.png)

## 三、开启HTTPS ##
当CNAME正常解析时，我再刷新GitHub配置页面就会发现这里已经可以勾选了，请义无反顾的勾上她。
![github_ssl_enforce_https](https://i.loli.net/2018/09/27/5bac51ac68fb3.png)

这里Github还要和我开个玩笑，我虽然看到这激动人心的绿色字体，告知我已经成功配置了https并可以访问，但当我进入页面的时候，竟然告诉我无效的ssl证书？然而这并不会扰乱我的清晰的思路，事实证明你大爷终究是你大爷，当我关闭chrome打开safari进入网站，一切都明朗了，那骚气的小绿标赫然呈现在我的面前。
![github_ssl_cer](https://i.loli.net/2018/09/27/5bac553b4c18d.png)