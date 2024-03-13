---
layout: page_with_comment
title: "解决一个WKWebView在iOS 10上的Crash: Invalid parameter not satisfying: targetNode"
date: "2016-09-01"
categories: 
  - "ios"
tags: 
  - "crash"
  - "ios"
  - "ios10"
  - "wkwebview"
  - "xcode"
---

近日，我遇到了一个让我感到匪夷所思的问题。App使用了WKWebView展示内容，然而，一旦iOS 10的用户手指触摸了WKWebView，app就会立即崩溃，而iOS 9的用户就不会遇到这个问题。

经过调试，我发现Stack Trace和Exception如下

`Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid parameter not satisfying: targetNode' *** First throw call stack: (0x1864041c0 0x184e3c55c 0x186404094 0x186e8d82c 0x18cc98e4c 0x18c6f551c 0x18c78f364 0x18c20ec70 0x18c791b1c 0x18c791a78 0x18c790d34 0x18c20d34c 0x18c1ddf84 0x18c9b3008 0x18c9aca70 0x1863b2278 0x1863b1bc0 0x1863af7c0 0x1862de048 0x187d5f198 0x18c248bd0 0x18c243908 0x1000e58a0 0x1852c05b8) libc++abi.dylib: terminating with uncaught exception of type NSException`

而调试信息显示问题出现在UIGestureGraphEdge.m的第25行。 `Assertion failure in -[UIGestureGraphEdge initWithLabel:sourceNode:targetNode:directed:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3599.6/Source/GestureGraph/UIGestureGraphEdge.m:25`

这个文件是Apple的UIKit的一部分啊，难道这是Apple iOS 10的bug？

不管是不是iOS的系统的bug，我想还是找到一个解决方案或者说workaround的好。

最后发现，我原来在app启动的时候，在+(void)load方法中先创建好WKWebView，等到viewDidLoad的时候直接将WKWebView通过addSubView添加到View Controller的view上，这样就可以在viewDidLoad方法中节约了创建WKWebView的时间，可是这样子创建好的WKWebView，在iOS 10上，用户一旦进行了触摸操作，就会出现前面提到的崩溃。

如果我将创建WKWebView的时机稍微延后一些时间，如在load方法中，通过dispatch\_after延迟1到2秒再创建WKWebView，那么，WKWebView就可以正常处理用户的触摸操作，不会崩溃。

```
static NSMutableArray *webViews;
#define WKWebView_Cache_Create_Delay 2
+ (void)load{
    if(SYS_VERSION_LESS(9))return;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUInteger createDelay = 0;
        if(SYS_VERSION_GREATER_OR_EQUAL(10)){
            createDelay = WKWebView_Cache_Create_Delay;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(createDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            webViews = [[NSMutableArray alloc] init];
            [webViews addObject:[self createWKWebView]];
            [webViews addObject:[self createWKWebView]];
        });
        
    });

```

此外，在https://forums.developer.apple.com/thread/61432上，也有人遇到了只在iOS 10上才出现的Crash，而Crash的代码的位置也是UIGestureGraphEdge.m的第25行。

`flykk Aug 28, 2016 11:54 PM When I clicked the NavigationBar in my App,it crashed.It only crashes in iOS 10 .The console log is: Assertion failure in -[UIGestureGraphEdge initWithLabel:sourceNode:targetNode:directed:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3599.6/Source/GestureGraph/UIGestureGraphEdge.m:25`

翻译如下 当我点击我的app的NavigationBar的时候，它就崩溃了。这仅仅发生在iOS 10上。控制台的日志是 Assertion failure in -\[UIGestureGraphEdge initWithLabel:sourceNode:targetNode:directed:\], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3599.6/Source/GestureGraph/UIGestureGraphEdge.m:25

说实话，这个现象我没到过，但是，崩溃相关的文件和行数确是一样的。期待这位朋友找到解决方法。
