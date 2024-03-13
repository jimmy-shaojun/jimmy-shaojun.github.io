---
layout: page_with_comment
title: "Xcode 8 Beta 2转换原Swift 2.2代码到Swift 3.0后报错Found an unexpected Mach-O header code: 0x72613c21"
date: "2016-07-14"
categories: 
  - "ios"
  - "swift"
---

今天试用了Xcode 8 Beta 2，尝试将之前Swift 2.2的代码转换为Swift 3.转换的过程一波三折，Swift 3改动十分大。

诸如dispatch\_after这些在Swift 3中都改成了DispatchQueue.main.after这种形式，其次，很多Objc的对象也改了翻译的名字，如Swift 2.2中UIScreen.mainScreen()变成了UIScreen.main()。其实这些都还好，Xcode都可以帮我自动转换好。

还有一个令人非常烦恼的就是objc代码的导入机制的变化，如果你有很多旧的代码还没有用nonnull这些关键字修饰objc的属性和方法的话，你就会发现，原来在Swift 2.2中，导入的objc属性或者方法参数是默认unwrapped的，到了Swift 3中，变成了默认不unwrapped了，而这些代码你必须手动去修改。

然而，最令我感到意外的是，到了最后，Xcode在copy swift libraries的时候，又报了错误 error: Found an unexpected Mach-O header code: 0x72613c21

用这个错误信息去找，看上去最符合的信息就是https://github.com/CocoaPods/CocoaPods/issues/5598，该issue中提到要设置ALWAYS\_EMBED\_SWIFT\_STANDARD\_LIBRARIES=NO，然而，我的所有的build settings都已经是ALWAYS\_EMBED\_SWIFT\_STANDARD\_LIBRARIES=NO了，可是Xcode还是会报错Found an unexpected Mach-O header code: 0x72613c21。最后，我只能认为是Xcode 8 Beta 2的一个bug了。

Swift 从1到2，从2到3，都完全没有考虑向后兼容（[Backward Compatibility](https://en.wikipedia.org/wiki/Backwards-compatibility)），这只能说明Swift其实连个半成品都不算，各位学习Swift可以，千万不要用在实际的工程中，否则，坑死你。
