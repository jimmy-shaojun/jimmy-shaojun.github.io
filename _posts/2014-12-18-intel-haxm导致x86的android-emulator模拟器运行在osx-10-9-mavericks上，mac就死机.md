---
layout: page_with_comment
title: "Intel HAXM导致x86的android emulator模拟器运行在OSX 10.9 mavericks上，mac就死机"
date: "2014-12-18"
categories: 
  - "android"
---

2013年12月的时候，当时还用的OS X 10.9，用Mac开发android的时候遇到了一个烦人的问题，装上了HAXM，intel hardware accelerated execution manager以后，一运行android emulator x86，mac就死机了，无论按键盘还是移动鼠标，mac都不反应，只能长按电源键关机再开机。

刚开始还以为是意外，没想到重新启动mac后，再运行一次emulator，我的mac还是死机了。反复几次都如此。

最后，终于找到了

http://software.intel.com/forums/topic/477793

里面提到

 The hotfix is available for download! Please go to [http://software.intel.com/en-us/articles/intel-hardware-accelerated-execution-manager/](http://software.intel.com/en-us/articles/intel-hardware-accelerated-execution-manager/) . There is a hotfix for Microsoft Windows\* 8.1 and one for OS X 10.9. 

看来，原来是HAXM还不支持太新的操作系统的缘故啊，Windows 8.1和OSX 10.9都是这个原因。

我装上了这个hot fix以后，x86的emulator终于正常了，osx也不会死机了。
