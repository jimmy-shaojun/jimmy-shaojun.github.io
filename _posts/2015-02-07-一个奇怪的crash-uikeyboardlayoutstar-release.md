---
layout: page_with_comment
title: "一个奇怪的Crash [UIKeyboardLayoutStar release]"
date: "2015-02-07"
categories: 
  - "ios"
tags: 
  - "arc"
  - "objc"
  - "runtime"
  - "swizzle"
---

今天写代码的时候，突然发现如果我在键盘出现的状态下，按下Home键使得App从Foreground切换到Background的时候，App就会触发一个exception导致crash，这个crash的信息在我看来很奇怪。

> \[UIKeyboardLayoutStar release\]: message sent to deallocated instance

我最初看了都不明白，怎么会是这个地方crash呢？这显然不是自己的代码，而且现在都是ARC了，一般不应该出现一个release相关的错误才最啊。

经过搜索，发现所有的线索都指向一个SafeKit的库https://github.com/JJMM/DurexKit，用了这个库的应用都出现了这个错误。并且我不是第一个遇到此问题的人。这个DurexKit可以处理数组越界，Dictionary nil等问题。例如，您要取得一个只有两个对象的NSArray的第三个元素的值，该库会自动返回nil，如果您要给Dictionary的某个key设置nil，该库会自动忽略这个操作。

http://code4app.com/ios/DurexKit%E5%AE%89%E5%85%A8%E5%B7%A5%E5%85%B7%E5%8C%85/5325b421933bf0463d8b49ec

> [冷月天涯](http://code4app.com/member/5460490b933bf00f648b46d5)
> 
> 2015-02-05 10:50:06
> 
> 回复
> 
> 用了这个,只要触发了键盘，然后挂后台，再回应用必挂，抛这个错\*\*\* -\[UIKeyboardLayoutStar release\]: message sent to deallocated instance 求解
> 
> 　　 [安洛熙"](http://code4app.com/member/54781f03933bf06a148b5f4a) 　 　
> 
> 2014-11-28 15:09:56
> 
> 回复
> 
> 用了这个,只要触发了键盘，然后挂后台，再回应用必挂，抛这个错\*\*\* -\[UIKeyboardLayoutStar release\]: message sent to deallocated instance

我针对此进行了验证，果然，就是这个库造成的问题！（额外提一句，我司的代码用的还是较早版本的该库）。

最开始，我想，干脆去掉这个库，不用了。去掉后，发现运行App就出错，出错的原因是某处代码会把nil给设置到NSMutableDictionary中，而NSMutableDictionary不能储存nil。结果，我还不能直接把该库给从工程中移除。

最后想想，怎么办呢，看来只能改一改代码了。

首先第一步，需要确定该改哪里，接下来就要确定该怎么改。

经过一阵子的comment/uncomment操作，最终发现，如果不swizzle NSArray的objectAtIndex，App就不会出现UIKeyboardLayoutStar的exception。

该怎么改呢？有一个经验，就是，涉及比较多runtime的代码，最好不要用arc，所以我决定把我司用到的几个文件改为MRC。

仔细看了那几个文件，发现还是比较好改的。只需要做如下改动就行了

1. 初始化所有的NSError变量声明，原代码都是NSError \*err;的形式，在ARC下没问题的，compiler都给自动初始化为nil了，但是MRC下不行
2. 把NSError从函数返回的时候，加上autorelease

按照上面两点改好后，再到build phase里给那几个m文件加上-fno-objc-arc flag

接下来又测试了几次，UIKeyboardLayoutStar release这个exception没有再出现，问题解决。

顺便再多说几句，DurexKit的作者也提到了某几个文件不要用ARC。

> [CUSLayout](http://code4app.com/member/512ee6d26803fa655c000000)
> 
> 2014-04-09 17:48:58
> 
> 回复
> 
> @habib狂鳄-- : 这两个发现一个缺陷，已经修正了，请试一下最新版，最新版如果用源码需要把NSObject+SafeKit标记为-fno-objc-arc，或者直接用静态库

不过作者所指的那个文件不能解决我这个问题，因为本文的问题是由于swizzle了NSArray的方法引起的，而不是NSObject。
