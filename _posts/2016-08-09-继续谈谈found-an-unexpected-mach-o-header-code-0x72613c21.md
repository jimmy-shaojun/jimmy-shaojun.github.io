---
layout: page_with_comment
title: "继续谈谈Found an unexpected Mach-O header code: 0x72613c21"
date: "2016-08-09"
categories: 
  - "ios"
  - "swift"
---

在 [之前一篇文章](https://huang.sh/2016/07/xcode-8-beta-2%e8%bd%ac%e6%8d%a2%e5%8e%9fswift-2-2%e4%bb%a3%e7%a0%81%e5%88%b0swift-3-0%e5%90%8e%e6%8a%a5%e9%94%99found-an-unexpected-mach-o-header-code-0x72613c21/)中，我提到，我使用Xcode 8 Beta 2打开之前的工程，并将Swift 2.2的代码转换为Swift 3之后，再度编译工程，Xcode就会报错误`Found an unexpected Mach-O header code: 0x72613c21`。

正好，Apple Developer Forums也有[一个Thread](https://forums.developer.apple.com/thread/50969)提到了0x72613c21错误。 该文指出问题出在Fabrics/Crashlytics上，如果你遇到了`Found an unexpected Mach-O header code: 0x72613c21`错误，那可能是你集成了Fabric/Crashlytics，并且版本不够新，因为许多人反应，移除Crashlytics后就好了，或者升级Crashlytics到3.7.2也可以。

不过，我当时的做法既不是移除Crashlytics，也不是升级Crashlytics，而是直接废除了Swfit代码，完全用Objective-C重新实现了原来Swift代码所实现的功能。

该Thread的最后一篇回复是这么说的：

> diego.trevisan Aug 1, 2016 2:02 PM (in response to davidfromsparks) This is finally fixed in Beta 4!
> 
> diego.trevisan 2016年8月1日，下午 2:02 (回复：davidfromsparks) 这个问题终于在Beta 4中解决了！

看到8月1日的回复，我可以郑重告诉大家，如果你遇到了0x72613c21错误，并且还在用Xcode 8 Beta 4之前的版本，那请首先尝试升级Xcode 8到Beta 4或更新版本。

> diego.trevisan Jul 31, 2016 3:43 PM (in response to jmac) I have just another dependency which is Alamofire and it is build from their new swift2.3 branch. Anyway, removing Fabric/Crashlytics solves the problem. Just tried adding them again, and the error appears :/ 我的工程中有一个依赖Alamofire，而Alamofire是以swift2.3的分支编译的。无论如何，我将Fabric/Crashlytics从工程中移除了，Xcode 8就不会报错，而我一旦将Fabric/Crashlytics添加到工程中，那么错误就会重新出现。
> 
> jmac Jul 31, 2016 4:33 PM (in response to diego.trevisan) This would be an interesting test: - Take the Fabric.framework and Crashlytics.framework that you have from the installer, and try linking them by hand with a sample project with no other dependencies. Based on what you're seeing, I would expect that it would not be able to build with Xcode 8 and that you would see the same Mach-O error.
> 
> 如果你通过Fabric的安装包集成了Fabric.framework 和 Crashlytics.framework，并尝试在一个样例工程中仅仅链接这两个framework，且不包含其他的依赖. 那么，根据你所看见的，我预计Xcode 8无法成功编译该工程并且会报告Mach-O错误。 Then, try installing Fabric/Crashlytics in your project via Cocoapods. I was installing them via pods when they worked for me (and the older versions that I had were from the installer). I had assumed that the difference was just the old ones vs the new ones, but it's possible that something about the way crashlytics links them ends up being different from what the installer does.
> 
> 接下来，你可以试着用Cocoapods而不是Fabric的安装包集成Fabric/Crashlytics。我用Cocoapods集成Fabric/Crashlytics，这不会导致Mach-O错误（当然，我用Cocoapods安装的是新版本的Fabric/Crashlytics，而之前用安装包安装的Fabric/Crashlytics的版本旧一些）。我估计导致错误的原因仅仅是Fabric/Crashlytics的版本的新旧，新版本的没问题，旧版本的有问题，但是，或许也还有别的可能性，或许用安装包安装的Fabric/Crashlytics在Xcode链接静态库的时候与Cocoapods的方式有着细微的差别，而这个差别导致了Mach-O错误。
