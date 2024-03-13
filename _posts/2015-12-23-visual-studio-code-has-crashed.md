---
layout: page_with_comment
title: "Visual Studio Code has crashed!"
date: "2015-12-23"
categories: 
  - "misc"
---

今天升级了Visual Studio Code for OSX，结果发现启动后总是报错误“Visual Studio Code has crashed”。

最后在github上发现了以下解决方案：将输入法切换为系统默认的输入法，启动vscode的时候不要用第三方的输入法。

https://github.com/Microsoft/vscode/issues/1463
