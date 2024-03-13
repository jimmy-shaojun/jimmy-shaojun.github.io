---
layout: page_with_comment
title: "如何以standalone模式编译并部署nextjs应用"
date: "2022-02-04"
tags: 
  - "nextjs"
  - "pre-render"
  - "build"
  - "standalone"
---

最近，我在编写一个nextjs应用，在考虑前端的部署的时候，突然想到，难道我要将nextjs对应的node_modules目录都一起部署吗？于是，我看了nextjs的文档，发现了[standalone](https://nextjs.org/docs/pages/api-reference/next-config-js/output).

| Next.js can automatically create a standalone folder that copies only the necessary files for a production deployment including select files in node_modules.

next.config.js

```js
module.exports = {
  output: 'standalone',
}
```

我仔细阅读文档后发现，如果我使用以上配置，那么，nextjs会编译生成以下内容 （注：我的项目使用了.env，如果你的项目不用.env，那么不会有.env文件生成）

```
.next/standalone/node_modules
.next/standalone/server.js
.next/standalone/package.json
.next/standalone/.env
```

`server.js`则是一个minimal server，而`.next/standalone/node_modules`则是`server.js`所需的依赖。我检查了`.next/standalone/node_modules`的大小，发现该node_modules比开发过程所使用的node_modules小多了。我的情形，standalone目录下的node_modules只有33MB，而开发阶段的node_modules将近1GB了。

假设我们要将frontend部署到同一台电脑的`/home/app`目录之下，并且希望`server.js`同时可以serve静态资源，那么

```bash
cp -r public /home/app/
cp -r public /home/app/.next /home/app/
mv /home/app/.next/standalone/node_modules /home/app/
mv /home/app/.next/standalone/server.js /home/app/
mv /home/app/.next/standalone/package.json /home/app/
mv /home/app/.next/standalone/.env /home/app/
```

接下来，便可以用如下方式启动`server`
```bash
cd /home/app/
node server.js
```