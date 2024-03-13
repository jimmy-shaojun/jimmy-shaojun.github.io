---
layout: page_with_comment
title: "在OSX 10.11 El Captain上安装pybonjour时遇到dlopen(libSystem.B.dylib, 6): image not found错误"
date: "2016-06-12"
categories: 
  - "ios"
  - "互联网"
tags: 
  - "python"
---

上一篇讲到，我需要安装PonyDebugger，而安装PonyDebugger需要安装pybonjour，然而，安装pybonjour时，又遇到了错误，错误信息如下， Traceback (most recent call last): File "setup.py", line 32, in import pybonjour File "/Users/huangshaojun/Downloads/Eichhoernchen-pybonjour-c63b48c/pybonjour.py", line 109, in \_libdnssd = ctypes.cdll.LoadLibrary(\_libdnssd) File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/ctypes/\_\_init\_\_.py", line 443, in LoadLibrary return self.\_dlltype(name) File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/ctypes/\_\_init\_\_.py", line 365, in \_\_init\_\_ self.\_handle = \_dlopen(self.\_name, mode) OSError: dlopen(libSystem.B.dylib, 6): image not found

我到github上也找到了对应的Issue 192 https://github.com/square/PonyDebugger/issues/192 Issue提到的解决方法是

```
well, okay i had to do a brew install python

```

即，不要用OSX内置的python，而用brew新安装一个python。

我并不想再新安装一个新的python，我还是希望用OSX内置的python，为此，我根据 http://stackoverflow.com/questions/32905322/oserror-dlopenlibsystem-dylib-6-image-not-found 的提示，修改了pybonjour.py

将

```
if sys.platform == 'darwin':
        _libdnssd = 'libSystem.B.dylib'
    else:

```

改为

```
if sys.platform == 'darwin':
        _libdnssd = '/usr/lib/libSystem.B.dylib'
    else:

```

这样用OSX内置的python就可以正确安装pybonjour了。
