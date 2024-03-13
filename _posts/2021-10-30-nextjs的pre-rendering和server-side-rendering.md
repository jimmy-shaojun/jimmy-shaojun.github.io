---
layout: page_with_comment
title: "nextjs的Pre-Rendering和Server Side Rendering"
date: "2021-10-30"
tags: 
  - "nextjs"
  - "frontend"
  - "backend"
---

加入Amazon已经一年多了，最近，我的工作涉及到Team的一个旧的前端组件的迁移。该组件使用的技术已经在公司内部要淘汰了，因此，我需要将该组件迁移到Amazon的Card framework上。在工作之余，我想要同时尝试下Amazon之外的技术。我听说nextjs是一个很受欢迎的frontend framework，于是我尝试了一下nextjs。

阅读nextjs的文档以后，我对两个概念有了较多的兴趣，即Pre-Rendering和Server Side Rendering (SSR)。

根据文档，SSR即由服务器根据每一个请求（Request）而生成具体的页面HTML。而pre-render的意思是，nextjs会事先生成html文件，而不是让client side的JavaScript去生成最终的页面，因此，这样可以获得更好的性能以及对SEO较为友好。

我刚看到SSR的时候，我想到了很多年以前写JSP或者PHP的情形，例如，一个JSP页面可以是如下
```jsp
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>JSP - Server Side Rendering</title>
</head>
<%@ page import="java.util.Date" %>
<body>
<h3>Hi Dear</h3><br>
<strong>Current Time is</strong>: <%=new Date() %>
</body>
</html>
```

我不禁想，nextjs的Server Side Rendering本质上和过去的JSP，PHP甚至CGI，没什么区别啊，怎么很多人都说nextjs是frontend呢？

我再进一步看了Pre-Render的文档，我这才发现，原来nextjs pre-render生成了html，所以，即便是搜索引擎对页面索引的时候，索引的内容和用户在浏览器之中看到的内容是一致的，而不会像client side rect app那样，页面全部是JavaScript而没有实际内容。当浏览器加载了页面以后，nextjs会初始化react components（nextjs将这个初始化过程叫做hydration）。

当我将nextjs的Server Side Rendering，Pre-Render和Hydration结合起来看以后，我确实感到了nextjs的优势。然而，我也认为，我们不能简单的讲nextjs说成是frontend，我认为，nextjs应该是一个frontend + backend的开发工具。

* 如果我们采用Server Side Rendering生成JSON数据，那么，nextjs完全可以用来开发一个REST API和GraphQL Server
* 我们可以用nextjs开发 client side react app，而不需要使用nextjs的Server Side Rendering和Pre-Rendering
* 我们也可以开发包含Server Side Rendering和Pre-Rendering的nextjs app。