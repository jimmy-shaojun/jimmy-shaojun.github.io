---
layout: page_with_comment
title: "更新了pg_cjk_parser，让它同时支持postgres11到16"
date: "2023-11-03"
tags: 
  - "c"
  - "postgres"
  - "extension"
---

2023年10月，我离开了Flexport，离开后，我对[pg_cjk_parser](https://github.com/huangjimmy/pg_cjk_parser)进行了更新。

* 添加了Dockerfile_pg11并且修改了Dockerfile，以便用户可以生成包含pg_cjk_parser的postgres 11，12，13，14，15，16的docker image
* 韩国用户发现了pg_cjk_parser的一个bug，对于Korean没有正确的解析出2-gram，我修复了这个bug
* 添加了github workflows，对于每一个commit和PR，workflows都会验证改动是否能在postgres 11到16上编译通过且测试通过