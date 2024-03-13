---
layout: page_with_comment
title: "再思考是否将CocoaPods生成的Pods/目录加入到代码库"
date: "2016-01-07"
categories: 
  - "ios"
---

CocoaPods是一个流行的Cocoa依赖管理工具，Mac和iOS的开发团队几乎都在使用CocoaPods。我们只需要编写Podfile，并在之中指定依赖的库，然后在命令行运行pod install，CocoaPods就会从自动安装上各种依赖，并生成Pods/目录和Podfile.lock，其中，Pods目录包含了工程所依赖的各种库的源文件或者二进制lib文件（库的作者有可能选择发布已经编译好的二进制文件而非源文件，如PayPal SDK），Podfile.lock则包含了所安装的库的版本信息，这包括版本号和hash值。

我们必须把Podfile.lock和Podfile添加到版本库，这样，别的团队成员check out工程的时候，同时也会得到Podfile.lock和Podfile，这样，他/她再次运行pod install的时候，CocoaPods就可以确保安装同样版本的库。

对于是否将Pods目录加入到代码库，一直以来都没有固定的结论，CocoaPods官方文档本身也针对添加到代码库和不添加到代码库的两种情形都给出了相应的操作文档。

两种方式其实都各有利弊。如果添加到代码库的话，最大的问题就是代码重复，因为依赖的库都是可以从网络下载的，再次添加到代码库是一种代码冗余，同时，很多库发布的是二进制版本，如PayPal SDK，这些库通常都很大，所以你会发现一个工程的源代码还没写多少，代码库就已经几个GB大了。这个问题其实挺严重的。

如果不添加到代码库的话，另外一个问题就会非常严重，那就是很多Pod可能会消失，即CocoaPods的master repo还有对应的pod spec，但是pod spec指向的地址已经404 not found了，我不止一次看到这样的情形了。所以，很有可能出现的问题就是，两三年前的版本你已经无法重新编译了。

还有一个麻烦的事情就是切换分支的时候，常常会需要pod install，否则就是this sandbox is not in sync with错误。如果pod install需要下载一些比较大的framework，那就需要开发人会员等待很长时

基于以上考虑，我个人的建议是，保险起见，把Pods目录一起加入到代码库中，代码库膨胀得快一些也可以接受了。

如果不想把Pods加入到代码库，那么，考虑到大多数的开源库都是放在github上，我建议还是要在github上及时fork这些库到公司内部的代码库中，并及时同步，但不要同步delete操作，防止有一天原作者因为各种原因把github上的工程给删除了。不过，一些知名的库，如AFNetworking，我们应该还不需要担心这个，但，如果你用了一些个人作者的库，那一定要fork一份，切不可不fork。
