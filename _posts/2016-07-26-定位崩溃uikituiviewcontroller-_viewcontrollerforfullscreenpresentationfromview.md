---
layout: page_with_comment
title: "定位崩溃UIKit`+[UIViewController _viewControllerForFullScreenPresentationFromView:]:"
date: "2016-07-26"
# categories: 
#   - "ios"
---

问题描述 最近在开发中遇到了一个crash，该crash可以稳定复现，复现的步骤如下， 1 在一个navigation controller中，push一个包含scroll view的view controller 2 在该view controller中，点击一个按钮，然后push另一个包含了scroll view新的view controller。 3 pop当前的view controller，回到步骤1中的view controller 4 按iOS的status bar，此时，应用crash

遇到了可以稳定复现的crash，我的第一反应就是查看crash log。然而，令我感到意外的是，crash log显示，错误为 EXC\_BAD\_ACCESS (SIGBUS) KERN\_EXCEPTION\_PROTECTED crash log显示对应的代码为UIKit\`+\[UIViewController \_viewControllerForFullScreenPresentationFromView:\]:

[![崩溃时候的call stack](/images/crash_stack.png)](/images/crash_stack.png)

这岂不是表明，crash的代码位于iOS的系统中，而不是我自己写的代码，难道viewControllerForFullScreenPresentationFromView这个方法有什么bug？

但是，考虑到这个crash可以稳定复现，我仍然觉得这应该是我的某处代码没有写好的缘故，而不是iOS系统的bug。然而，从crash log无法直接定位到我的代码的具体位置，我一时也没有好的线索去定位错误代码。

为了找寻线索，我搜索了stackoverflow，然后还真的发现了一个类似的问题 http://stackoverflow.com/questions/30080990/ios-app-crashes-with-exc-bad-access-sigsegv-on-ipad-ios-7-1-1-device 。

这个问题的crash log如下 Exception Type: EXC\_BAD\_ACCESS (SIGSEGV) Exception Subtype: KERN\_INVALID\_ADDRESS at 0x0000000c Triggered by Thread: 0

Thread 0 Crashed: 0 libobjc.A.dylib 0x3b3a1626 objc\_msgSend + 6 1 UIKit 0x33301b46 +\[UIViewController \_viewControllerForFullScreenPresentationFromView:\] + 174 2 UIKit 0x33301614 -\[UIWindow \_scrollToTopViewsUnderScreenPointIfNecessary:resultHandler:\] + 428 3 UIKit 0x3330143e -\[\_UIScrollsToTopInitiatorView touchesEnded:withEvent:\] + 210 4 UIKit 0x3330134e -\[UIStatusBar touchesEnded:withEvent:\] + 334 5 UIKit 0x33255790 forwardTouchMethod + 228 6 UIKit 0x3310371c -\[UIWindow \_sendTouchesForEvent:\] + 524 7 UIKit 0x330fe6e6 -\[UIWindow sendEvent:\] + 754 8 UIKit 0x330d38e8 -\[UIApplication sendEvent:\] + 192 9 UIKit 0x330d1f92 \_UIApplicationHandleEventQueue + 7098 10 CoreFoundation 0x3087e258 \_\_CFRUNLOOP\_IS\_CALLING\_OUT\_TO\_A\_SOURCE0\_PERFORM\_FUNCTION\_\_ + 12 11 CoreFoundation 0x3087d726 \_\_CFRunLoopDoSources0 + 202 12 CoreFoundation 0x3087bf1a \_\_CFRunLoopRun + 618 13 CoreFoundation 0x307e6f0a CFRunLoopRunSpecific + 518 14 CoreFoundation 0x307e6cee CFRunLoopRunInMode + 102 15 GraphicsServices 0x356e065e GSEventRunModal + 134 16 UIKit 0x33132168 UIApplicationMain + 1132 17 MyApp 0x0029c0a0 main (main.m:16) 18 libdyld.dylib 0x3b8a4ab4 start + 0

我发现，这个crash log和我的crash log几乎一模一样，尽管这个stackoverflow的问题并没有人回答，然而，问题的一个comment还是给了我线索。

> It's not a memory leak problem. Somewhere you seem to be trying to access a deallocated object. – rmaddy May 6 '15 at 18:28

这么说，我遇到的crash也应该是deallocated object导致的了，那么，如果我能够定位到具体是哪一个deallocated object的话，那就可以进一步缩小排查的代码范围了。这时候，我应该用NSZombieEnabled选项来调试我的app了。

首先，启用Enable Zombie Objects选项。 [![NSZombieEnabled](/images/Screen-Shot-2016-07-26-at-11.50.02-PM.png)](/images/Screen-Shot-2016-07-26-at-11.50.02-PM.png) 我们都知道，iOS的运行时是用C和Objective C实现的，每一个对象都采用引用计数进行内存管理，如果某一个对象的引用计数为0了，那么该对象的内存就会被释放掉 ，而我们启用了Zombie Objects后，一个对象引用计数为0的时候，这个对象会被转换为一个Zombie对象，而不是直接释放掉，如果你向一个zombie对象发消息，那么调试器就会捕捉到这个操作，你就可以进一步定位具体错误了。

接下来，我用Enable Zombie Objects选项启动并调试app并且很容易地获取到了这条有效的调试信息。

> \[UIScrollView retain\]: message sent to deallocated instance 0x12eda1e00

从这条调试信息来看，问题与我的代码中声明的某一个UIScrollView对象有关，可是我怎么知道这是哪一个scroll view对象呢，这个scroll view对象在我的代码中用什么属性，什么变量去引用的呢？

我仔细观察了对应的源文件，我发现只有三个View Controller的属性的类型是UIScrollView，为此，我在dealloc的方法中设置了断点，在断点上获取对应的类型为UIScrollView的属性的指针，并记录下来，然后将记录下来的指针与Zombie对象的指针进行对比，经过多次反复的重现这个crash，我终于发现原来crash与是一个名为scrollView1的属性有关，每一次发生crash，deallocated instance一定是scrollView1这个属性的指针，无一例外。

我经过仔细对比，反复代码审查，终于发现了一处潜在的问题，那就是，我会在viewDidLoad之后，viewDidAppear之前就对scrollView执行Scroll操作，我总感觉有些不妥，似乎应该在viewDidAppear之后才能对scrollView进行scroll的。

我对代码进行了改动，凡是要对scrollView执行scroll动作的代码（即调用了UIScrollView setContentOffset方法），都一律延后到viewDidAppear之后进行。

修改代码后，我再次进行测试，这下子发现app不再崩溃了，运行十分正常，问题解决。

结论，千万不要在viewDidAppear之前，或者说，更准确的说，千万不要在当前的ViewController的view.window属性为nil的时候对UIScrollView进行setContentOffset操作，否则，你会发现你遇到了crash，并且crash的位置是UIKit\`+\[UIViewController \_viewControllerForFullScreenPresentationFromView:\]:。
