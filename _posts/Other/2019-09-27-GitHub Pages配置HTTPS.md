---
published: true
author: Wayne Sun
layout: post
title: GitHub Pages配置HTTPS
category: Other
summary: 最近听说GitHub Pages支持了自己的HTTPS服务，就想着把很久之前搭建的JekyII个人博客换成HTTPS访问，由于之前用的Cloud Flare免费的SSL，总感觉访问速度受到了限制（可能是幻觉），就去掉了，这次看看Github自带的Let's Encrypt证书效果如何。
tags:
  - GitHub Pages
  - HTTPS
---

`文/孙少伟`

最近听说GitHub Pages支持了自己的HTTPS服务，就想着把很久之前搭建的JekyII个人博客换成HTTPS访问，由于之前用的Cloud Flare免费的SSL，总感觉访问速度受到了限制（可能是幻觉），这次看看Github自带的Let's Encrypt证书效果如何，虽然免费版限期一年，但也很不错了，操作简单省时省力，比去搞什么第三方SSL要好得多。

## CNAME域名解析 ##
---
起初，笔者也遇到了一个大家先前都遇到的问题，就是Enforce HTTPS始终无法勾选。网上查了一下，众说纷纭。根据我的经验，干脆直接问客服。 
> GiHub在线提问 <a href="https://github.com/contact" target="_blank">drop me a line</a>

	Hi Sun,

	Thanks for writing in! I took a look and it appears that your custom domain is set up using our old A record IPs. We recently made some changes to our Pages service that included some new IPs.

	You'll need to remove your existing A records, and replace them with at least one A record that points to one of the following IP addresses:

	185.199.108.153
	185.199.109.153
	185.199.110.153
	185.199.111.153

	Optionally, you can create additional A records that point to the other IP addresses from the list. Additional records essentially act as a backup in case of DNS or CDN issues, so having at least two is best practice, though your site will still function with just one.

	If you'd also like to generate a free HTTPS certificate for your site, once you've replaced the A records, you'll need to visit your repository's settings page, which will kick off the process of provisioning an HTTPS certificate for your domain name.

	Once your certificate has been provisioned, you'll then be able to enforce HTTPS by checking the "Enforce HTTPS" checkbox.

	Bear in mind that it can take up for 24 hours for DNS changes to take full effect, and up to an hour for an HTTPS certificate to be requested, so if you follow these steps but are still having trouble, that's usually why.

	If that doesn't work for you, please let us know.

	All the best, 
	Lesley

	Find answers to common questions and learn with other GitHub users in our new GitHub Community Forum

不得不说国外的客服确实效率，不到20分钟，官方客服发邮件告知我需要配置以上4个IP到DNS记录，这和网上一部分人的说法相同。事实证明其实并没有那么麻烦，只要你配置了CNAME记录，就会自动将你的域名解析到这几个dns，并生成对应的4条A记录。

![github_ssl_cname](https://i.loli.net/2018/09/27/5bac51ac4bd7b.png)

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
```

像这样就OK了，只是因为笔者在此之前配置的是A记录，直接ping了sunswayne.github.io取得IP，再配置到了DNS记录值，这样虽然可行，但是在配置CNAME记录时会警告我域名没有正确解析到github.io，事实证明CNAME域名解析才是王道。

## 开启HTTPS访问 ##
---
当CNAME记录正常解析时，笔者再次刷新GitHub配置页面就会发现这里已经可以勾选了，请义无反顾的勾上她。

![github_ssl_enforce_https](https://i.loli.net/2018/09/27/5bac62293e8dd.png)

访问网站，如果显示无效的ssl证书，请关闭浏览器并重新打开，一切都明朗了。

![github_ssl_cer](https://i.loli.net/2018/09/27/5bac798911e5c.png)