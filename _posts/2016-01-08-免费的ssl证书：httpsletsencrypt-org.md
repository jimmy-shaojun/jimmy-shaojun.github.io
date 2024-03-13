---
layout: page_with_comment
title: "免费的SSL证书：https://letsencrypt.org/"
date: "2016-01-08"
categories: 
  - "misc"
  - "安全"
  - "电子商务"
---

今天想着给自己的blog加上ssl证书，最开始想的是用免费的，结果最后发现了https://letsencrypt.org/，不仅免费，而且部署自动化，非常方便。

letsencrypt提供了一个命令行工具，它需要在服务器上运行，然后在你的Web的根目录下创建一个特殊名称的文件，如.well-known/acme-challenge/aaaa11111，假设你的域名是www.abc.def，letsencrypt会尝试下载www.abc.def/.well-known/acme-challenge//aaaa11111，如果下载成功，则代表你是网站和域名的所有人。

我在使用letsencrypt的时候，发现由于nginx默认禁止访问"."开头的资源了（防止黑客下载.htaccess, .htpasswd文件），所以总是认证不成功，最后修改了访问权限，允许了.well-known的访问。

 

我的新blog: https://huang.sh
