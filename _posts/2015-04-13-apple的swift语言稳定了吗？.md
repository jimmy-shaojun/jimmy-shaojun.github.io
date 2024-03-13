---
layout: page_with_comment
title: "Apple的Swift语言稳定了吗？"
date: "2015-04-13"
categories: 
  - "ios"
  - "swift"
---

Apple推出了Swift语言，这引起了业内的广泛关注，然而，Swift仍然在迅速的演化之中，业内也不停地在讨论以下问题

1. Swift会替代Objective C吗
2. 我想开始iOS开发，该学习Obj-C还是Swift
3. 现在改用Objective C开发还是用Swift
4. 我们是否该从Objective C迁移到Swift

不过，如果你之前写了大量的Swift代码，那么，升级到Swift 1.2以后，你将遇到很多编译错误，例如以下的几个编译错误。

Method 'load()' defines Objective-C class method 'load', which is not permitted by Swift

Method 'abc()' with Objective-C selector 'abc' conflicts with getter for 'abc' from superclass 'Abc' with the same Objective-C selector

'AnyObject' is not convertible to 'NSDictionary'; did you mean to use 'as!' to force downcast?

'AnyObject' is not convertible to 'CALayer'; did you mean to use 'as!' to force downcast?

笔者在之前的项目中，也密切关注着Swift，不过，并没有急于大量将Swift应用到生产代码中，而是在几个小项目中试用了以下，这些代码到了1.2后，全部都编译出错，错误信息大多数都是上面几种情况。

虽然很快就找到了解决办法，可是，如果早几个月写了大量的Swift代码，现在却面临了1.2的改变而导致编译出错，全部都改过来也是挺烦的。

解决办法其实也不复杂。

其中第三和第四个其实就是as改为as!（即加上感叹号）

第二个，原来的readonly属性，我直接写了个 override func abc()->String!的方法，现在要改成

var abc:String!{ get{ return "abc" } }

即override属性，而不是override实现的方法了

第一个，不能重载load方法，目前只能把override的load的方法的swift code注释掉了，替代的办法没有。
