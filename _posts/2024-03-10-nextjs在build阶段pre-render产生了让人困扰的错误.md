---
layout: page_with_comment
title: "nextjs在build阶段pre-render产生了让人困扰的错误"
date: "2024-03-10"
tags: 
  - "nextjs"
  - "pre-render"
  - "build"
  - "experimental-compile"
---

最近，我的一个项目用nextjs作为前端，nestjs作为后端，postgres作为数据库。在开发阶段，一切都很好，直到我将前后端以及数据库都集成到一个docker-compose.yml之中，并且以[standalone](https://nextjs.org/docs/pages/api-reference/next-config-js/output)编译前端。

令我感到困惑的是，我通过docker-compose启动了前端，后端以及数据库以后，我访问页面，却得到了一个空白的页面，而如果我通过`next dev`在本地电脑启动nextjs app，却可以看到正常的页面。我于是直接在首页将错误信息显示出来，令我感到困惑的是，我看到的错误信息如下

```html
Error: getaddrinfo ENOTFOUND backend
```

在我看来，这意味着frontend无法访问backend，我发现也有人遇到了类似的情形[getaddrinfo ENOTFOUND when starting Next.js DEV server with IP and port](https://stackoverflow.com/questions/77031132/getaddrinfo-enotfound-when-starting-next-js-dev-server-with-ip-and-port)

更令我感到困惑的是，我通过以下命令，

```bash
docker exec -it frontend /bin/bash
% apt-get update && apt install dnsutils
% nslookup backend
Server:		127.0.0.11
Address:	127.0.0.11#53

Non-authoritative answer:
Name:	backend
Address: 172.19.0.5
```

也就是说，frontend是可以访问到backend的。这让我感到很困惑，怎么会产生`ENOTFOUND`错误呢。

我通过查找，终于找到了[Abilitty to skipping static pages generating at build time
#46544](https://github.com/vercel/next.js/discussions/46544)


| Other issues is that the backend server often cannot be reach by developer/build machine.


以及


| Hi, as an update here in the latest versions of Next.js v13.5.3 there is now next experimental-compile command to replace next build that skips prerendering step for all paths and also a separate next experimental-generate command to prerender after the fact.

我这才恍然大悟，我通过docker-compose启动了frontend backend和postgres，而frontend在docker build的时候，nextjs就尝试去pre-render页面了，而此时backend还不存在，那么，pre-render尝试访问backend来获取数据并生成html，可不就是`Error: getaddrinfo ENOTFOUND backend`吗。我之前用nextjs的时候，都是指向了一个可用的server，即nextjs在build的阶段，server一直是可用的，所以我不会遇到这个错误。可是，这一次，frontend和backend都必须在docker-compose启动完成以后才可用。

我将nextjs的编译命令改为`next experimental-compile`后，问题终于解决了。