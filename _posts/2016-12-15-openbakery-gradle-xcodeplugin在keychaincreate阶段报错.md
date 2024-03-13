---
layout: page_with_comment
title: "openbakery gradle-xcodePlugin在keychainCreate阶段报错"
date: "2016-12-15"
categories: 
  - "ios"
  - "mac"
---

我在iOS的项目中使用了gradle-xcodePlugin进行打包工作，然而，最近gradle-xcodePlugin一直报如下错误。

`:archive :keychainCreate FAILED  FAILURE: Build failed with an exception.  * What went wrong: Execution failed for task ':keychainCreate'. > Command failed to run (exit code 1): 'security set-key-partition-list -S apple: -k -D -t private'`

我将 `security set-key-partition-list -S apple: -k -D -t private` 在终端中执行的话，会遇到如下错误信息。 `security: SecKeychainItemSetAccessWithPassword: The user name or passphrase you entered is not correct.`

我在https://github.com/openbakery/gradle-xcodePlugin/issues/316 看到，已经有人报告了一个类似的issue。 原来gradle-xcodePlugin的作者为了解决issue 316而在0.14.5中添加了'security set-key-partition-list -S apple: -k -D -t private'命令。正是这个命令导致了我的打包失败。

最终，我改用了0.14.4版本的gradle-xcodePlugin，就可以正常打包了。
