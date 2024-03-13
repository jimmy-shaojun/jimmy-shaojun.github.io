---
layout: page_with_comment
title: "我的pg_cjk_parser开源项目让pleroma可以支持中日韩CJK全文检索"
date: "2022-05-16"
tags: 
  - "c"
  - "postgres"
  - "extension"
---

2019年，我创立了[pg_cjk_parser](https://github.com/huangjimmy/pg_cjk_parser)。[pg_cjk_parser](https://github.com/huangjimmy/pg_cjk_parser)是一个postgres search extension，以C语言编写，可以将中日韩文字解析成为[2-gram](https://www.mathworks.com/discovery/ngram.html)，同时，对于其他文字，如英语法语等，则采用postgres的默认search extension的解析模式。

今天我发现，[pleroma](https://docs-develop.pleroma.social/)在文章 [How to enable text search for Chinese, Japanese and Korean](https://docs-develop.pleroma.social/backend/configuration/howto_search_cjk/)之中
将我的pg_cjk_parser作为推荐之一。

pleroma推荐的postgres search extensions之中，我的[pg_cjk_parser](https://github.com/huangjimmy/pg_cjk_parser)
是唯一一个同时支持中日韩CJK的search extension。