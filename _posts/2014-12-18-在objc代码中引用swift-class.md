---
layout: page_with_comment
title: "在Objc代码中引用Swift Class"
date: "2014-12-18"
categories: 
  - "ios"
---

最近写了几个Swift的Class，想要在Objc代码中用这几个Class，阅读Apple的《Use Swift with Cocoa and Objective-C》后，发现书中写到，"import the Xcode-generated header file for you swift code into any Objective-C .m file"，这也就是说，Xcode会为swift代码自动生成一个header文件，于是我到工程里找这个文件，居然没有找到。之后，尝试新建几个swift文件，也没有发现有新的h文件生成，这是怎么回事呢。

到stackoverflow上看问答，发现这个http://stackoverflow.com/questions/24062618/swift-to-objective-c-header-not-created-in-xcode-6

里面有一个回答提到：“**An actual file in the project is not created** (\[ProductModuleName\]-Swift.h). Cmd + Click on the import either generates it on-the-fly (and in-memory) so you can see how the linkage is done, or opens a file somewhere in some Xcode cache dir, but it's not in the project dir.

You need to set **Defines Module** project prop (in target's Build Settings) to **Yes** and if your module name has spaces or dashes - use \_ in all imports of the \[ProductModuleName\]-Swift.h file.

You can import it in all .h and .m files where you use swift types or you can import it in the .pch.

So if my Module (project) is named "Test Project", I would import it like this, in the .pch file of my project (just there):”

我随后在objc的m文件中添加了 #import "module\_name-Swift.h"，再进行build，就发现build成功了，而这个module\_name-swift.h文件并不存在于工程之中。
