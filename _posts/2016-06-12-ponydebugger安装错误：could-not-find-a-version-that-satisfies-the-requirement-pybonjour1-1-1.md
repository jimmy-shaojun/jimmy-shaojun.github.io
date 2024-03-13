---
layout: page_with_comment
title: "PonyDebugger安装错误：Could not find a version that satisfies the requirement pybonjour==1.1.1"
date: "2016-06-12"
categories: 
  - "ios"
  - "互联网"
tags: 
  - "ponydebugger"
  - "python"
---

之前一直用Reveal，不过Reveal只能查看View Hierarchy，而我听说PonyDebugger不仅仅可以查看View Hierarchy，还能debug network traffic和view core data，所以决定也集成PonyDebugger。

到PonyDebugger的主页（https://github.com/square/PonyDebugger）一看，发现README中有一个Quick Start，这个Quick Start提到首先要运行如下代码安装ponyd

```
curl -s https://cloud.github.com/downloads/square/PonyDebugger/bootstrap-ponyd.py | \
  python - --ponyd-symlink=/usr/local/bin/ponyd ~/Library/PonyDebugger

```

我运行了以后，遇到如下错误

```
Collecting pybonjour==1.1.1 (from ponyd)
  Could not find a version that satisfies the requirement pybonjour==1.1.1 (from ponyd) (from versions: )
No matching distribution found for pybonjour==1.1.1 (from ponyd)
Traceback (most recent call last):
  File "", line 2462, in 
  File "", line 946, in main
  File "", line 1794, in after_install
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/subprocess.py", line 540, in check_call
    raise CalledProcessError(retcode, cmd)

```

随后，我用关键字

```
Could not find a version that satisfies the requirement pybonjour==1.1.1 
```

进行搜索，发现了Issue #186 https://github.com/square/PonyDebugger/pull/186，此issue表明pybonjour的问题已经于2016年2月27日解决了。可是，我为什么仍然遇到了这个问题呢。

接下来，Issue 185解决了我的疑惑 https://github.com/square/PonyDebugger/issues/185，其中 justinseanmartin 在3月15日提到

```
I was able to clone and then install using python setup.py install. It isn't as convenient as the command from the readme, will look into getting the script fixed up as well.

```

Issue 188 https://github.com/square/PonyDebugger/issues/188 中，justinseanmartin也提到了，

```
Dupe of #100. You should be unblocked by:

git clone git@github.com:square/PonyDebugger.git
cd PonyDebugger
python setup.py install

Please confirm this works for you. I've logged #189 to track fixing the install script and/or instructions.

```

这说明，pybonjour问题的解决方案，还没有应用到https://cloud.github.com/downloads/square/PonyDebugger/bootstrap-ponyd.py，所以，用Quick Start的方式安装仍然有问题，我们目前还是需要把PonyDebugger的git库clone到本地，再进行安装。
