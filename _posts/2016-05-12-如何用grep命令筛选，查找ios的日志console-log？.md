---
layout: page_with_comment
title: "如何用grep命令筛选，查找iOS的日志console log？"
date: "2016-05-12"
categories: 
  - "ios"
  - "mac"
tags: 
  - "console"
  - "filter"
  - "find"
  - "grep"
  - "ios"
  - "控制台"
  - "查找"
  - "筛选"
---

在iOS开发中，除了断点之外，一个最常见的调试方法就是查看iOS的log，我们在代码中经常会通过NSLog输出大量日志，然后查看日志，看看是否出现了什么异常情形。

然而，随着项目不断进展，iOS的log也越来越多，这导致我们常常需要在冗长的log中寻找需要的某几行log。令人感到遗憾的是，Xcode的Console只有一个find功能，其他功能都没有。

如果我们可以像在命令行一样用grep等工具对iOS的console进行筛选，那该多好啊。

我经过搜索，终于发现了这个工具https://github.com/rpetrich/deviceconsole

这是一个可以在Mac上显示iOS的console的工具，github上保存的是工具的源代码，编译后，你就得到一个名为deviceconsole的可执行文件，运行deviceconsole，它就将usb连接到Mac上的iphone的console输出到了当前的terminal中，我只要执行deviceconsole | grep "Hello World"，就可以只查看带Hello World文字的日志了。

此外，还可以deviceconsole > /tmp/console.log，这样子iOS的console就会重定向到/tmp/console.log了。

如果你希望只显示带“Hello World”的日志，你可以执行命令 tail -f /tmp/console.log | grep "Hello World"

如果你想要看之前输出的带有“Hello World”的日志，那么你可以执行命令 grep "Hello World" /tmp/console.log
