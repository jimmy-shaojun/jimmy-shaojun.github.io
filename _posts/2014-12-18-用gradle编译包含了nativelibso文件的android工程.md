---
layout: page_with_comment
title: "用gradle编译包含了nativelib(so文件)的Android工程"
date: "2014-12-18"
categories: 
  - "android"
---

2014年7月，我进行了一个跨部门的项目，该项目包含iOS和Android版本，iOS版本很快就弄好了，但是Android版本却在配置管理上让我走了些弯路。

之前，我辅助开发的大多数Android项目都是用Maven管理的，这次却遇到了Gradle工程。

最开始遇到的问题是，我通过homebrew安装了1.12的gradle，结果Idea提示，请使用1.10版本的gradle，我想了想，算了，还是下一个1.10的吧。

接下来，倒是很顺利，编译通过，并且成功在手机和模拟器上运行，可是，恩，adb logcat中居然发现了UnsatisfiedLink！根据我的经验，这显然就是native lib没有打包进去的原因啊。把apk打开看，果然，所有的so文件都没有打包进去。

怎么办呢？到stackoverflow和gradle的网站上去查找，有各种的讨论，最后的解决方法却很简单。

工程中native lib的目录结构是
<pre>
libs

 |- x86

 |- armeabi

 | - a.so

 | - b.so
</pre>

最后我把libs/\*.so和libs/x86/\*.so libs/armeabi/\*.so打包到一个叫做native.jar文件中，jar文件内部的目录结构如下
<pre>
lib   // (注意，lib，不带s)

 |- x86

 |- armeabi

 | - a.so

 | - b.so
</pre>
然后，把native.jar放到libs目录下。

最后，gradle编译，运行，模拟器和手机上一切正常了
