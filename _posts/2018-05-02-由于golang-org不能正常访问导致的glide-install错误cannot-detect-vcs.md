---
layout: page_with_comment
title: "由于golang.org不能正常访问导致的glide install错误Cannot detect VCS"
date: "2018-05-02"
categories: 
  - "misc"
tags: 
  - "cannot"
  - "detect"
  - "go"
  - "golang"
  - "mirror"
  - "vcs"
  - "镜像"
---

[Go语言](https://golang.org)是Google推出的一种程序语言，[Glide](https://github.com/Masterminds/glide)是go语言的包管理器，可以解决项目的依赖关系。目前，Glide建议我们尽快迁移到[dep](https://github.com/golang/dep)上。

然而，由于许多常用的包都在golang.org上，而由于众所周知的原因，golang.org一直处于中国大陆无法正常访问的情况，所以，glide update总会出现诸如Cannot detect VCS的错误。

Mac和Linux下，可以用如下命令添加golang的镜像

```
rm -rf ~/.glide
mkdir -p ~/.glide
glide mirror set https://golang.org/x/mobile https://github.com/golang/mobile --vcs git
glide mirror set https://golang.org/x/crypto https://github.com/golang/crypto --vcs git
glide mirror set https://golang.org/x/net https://github.com/golang/net --vcs git
glide mirror set https://golang.org/x/tools https://github.com/golang/tools --vcs git
glide mirror set https://golang.org/x/text https://github.com/golang/text --vcs git
glide mirror set https://golang.org/x/image https://github.com/golang/image --vcs git
glide mirror set https://golang.org/x/sys https://github.com/golang/sys --vcs git
glide mirror set https://google.golang.org/grpc https://github.com/grpc/grpc-go --vcs git

```
