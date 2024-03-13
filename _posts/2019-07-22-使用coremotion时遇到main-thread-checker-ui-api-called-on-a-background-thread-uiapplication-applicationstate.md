---
layout: page_with_comment
title: "使用CoreMotion时遇到Main Thread Checker: UI API called on a background thread: -[UIApplication applicationState]"
date: "2019-07-22"
categories: 
  - "ios"
tags: 
  - "applicationstate"
  - "coremotion"
  - "main-thread-checker"
---

> 2019年8月1日更新：根据本人测试，在iOS 13 Developer Beta 5，iPhone XS Max上，本bug已经不再出现，App调用CoreMotion不会再出现Main Thread Checker: UI API called on a background thread: -\[UIApplication applicationState\] 错误。

* * *

我近期以ProMovie为原型，开发一款iPhone的录像app，在开发的过程中，考虑到用户可能会锁定屏幕旋转，所以，我使用了CoreMotion判断设备当前的orientation，以此确定拍摄的视频的orientation。然而，在实际调试中，我发现，每次在我的iPhone XS Max iOS 12.3.1上运行，Xcode都会检测到以下错误。该错误不会导致应用崩溃，但是一直存在。最终，我只能像忽略warning一样忽略它，然而，与warning不一样之处在于，我可以想办法解决warning，却没办法解决此问题。

> Main Thread Checker: UI API called on a background thread: -\[UIApplication applicationState\] PID: 11696, TID: 3583674, Thread name: com.apple.CoreMotion.MotionThread, Queue name: com.apple.root.default-qos.overcommit, QoS: 0 Backtrace: 4 libobjc.A.dylib 0x000000022fc476f4 \+ 56 5 CoreMotion 0x00000002363c1d9c CoreMotion + 294300 6 CoreMotion 0x00000002363c22cc CoreMotion + 295628 7 CoreMotion 0x00000002363c21dc CoreMotion + 295388 8 CoreMotion 0x00000002363f001c CoreMotion + 483356 9 CoreMotion 0x00000002363f0060 CoreMotion + 483424 10 CoreFoundation 0x00000002309d627c \+ 28 11 CoreFoundation 0x00000002309d5b64 \+ 276 12 CoreFoundation 0x00000002309d0e58 \+ 2276 13 CoreFoundation 0x00000002309d0254 CFRunLoopRunSpecific + 452 14 CoreFoundation 0x00000002309d0f88 CFRunLoopRun + 84 15 CoreMotion 0x00000002363ef9f4 CoreMotion + 481780 16 libclang\_rt.asan\_ios\_dynamic.dylib 0x00000001053e1ef0 \_ZN6\_\_asan10AsanThread11ThreadStartEyPN11\_\_sanitizer16atomic\_uintptr\_tE + 192 17 libsystem\_pthread.dylib 0x000000023064e908 \+ 132 18 libsystem\_pthread.dylib 0x000000023064e864 \_pthread\_start + 48 19 libsystem\_pthread.dylib 0x0000000230656dcc thread\_start + 4 2019-07-22 16:56:00.955489+0800 VideoCamera\[11696:3583674\] \[reports\] Main Thread Checker: UI API called on a background thread: -\[UIApplication applicationState\] PID: 11696, TID: 3583674, Thread name: com.apple.CoreMotion.MotionThread, Queue name: com.apple.root.default-qos.overcommit, QoS: 0 Backtrace: 4 libobjc.A.dylib 0x000000022fc476f4 \+ 56 5 CoreMotion 0x00000002363c1d9c CoreMotion + 294300 6 CoreMotion 0x00000002363c22cc CoreMotion + 295628 7 CoreMotion 0x00000002363c21dc CoreMotion + 295388 8 CoreMotion 0x00000002363f001c CoreMotion + 483356 9 CoreMotion 0x00000002363f0060 CoreMotion + 483424 10 CoreFoundation 0x00000002309d627c \+ 28 11 CoreFoundation 0x00000002309d5b64 \+ 276 12 CoreFoundation 0x00000002309d0e58 \+ 2276 13 CoreFoundation 0x00000002309d0254 CFRunLoopRunSpecific + 452 14 CoreFoundation 0x00000002309d0f88 CFRunLoopRun + 84 15 CoreMotion 0x00000002363ef9f4 CoreMotion + 481780 16 libclang\_rt.asan\_ios\_dynamic.dylib 0x00000001053e1ef0 \_ZN6\_\_asan10AsanThread11ThreadStartEyPN11\_\_sanitizer16atomic\_uintptr\_tE + 192 17 libsystem\_pthread.dylib 0x000000023064e908 \+ 132 18 libsystem\_pthread.dylib 0x000000023064e864 \_pthread\_start + 48 19 libsystem\_pthread.dylib 0x0000000230656dcc thread\_start + 4

然而，令我感到困惑的是，Stack Trace给出的信息表明这应该是CoreMotion自己的问题。

我通过搜索，发现Stackoverflow上有相应的问题和回答 https://stackoverflow.com/questions/54607856/main-thread-checker-warning-with-coremotion-only-appearing-on-2018-model-iphone 根据该问答，2018款的iPhone都可以复现此问题。这样看来，这是一个iPhone的bug了。

我于是拿来了我的iPhone 6s进行测试，果然，在我的iPhone 6s iOS 12.3.1上，我的app并不会复现此问题。

然而，经过搜寻，我又发现了如下的bug report https://openradar.appspot.com/46210367

有人报告，在使用UIInterpolatingMotionEffect时，也会出现UI API called on a background thread: -\[UIApplication applicationState\] Thread name: com.apple.CoreMotion.MotionThread 错误，且该错误仅在iPhone XS上出现，在iPhone X，6s和6s Plus上则不能复现此错误。因此，该report认为，bug与新的硬件相关，具体什么原因，未知。需要注意的是，该bug report提到的iOS版本为12.1，而截止到本文写作之时，iOS已经升级到了12.3.1，很快就要一年了，该bug仍然存在。

> A new instance of CMMotionManager results in a Thread Checker warning Originator: futuretap Number: rdar://46210367 Date Originated: 22-Nov-2018 10:46 AM Status: Duplicate/31658500/Closed Resolved: Product: iOS + SDK Product Version: 12.1 Classification: Serious Bug Reproducible: Always Summary: This is a duplicate of radar #45003816. We encounter the same issue when using UIInterpolatingMotionEffect. The Main Thread Checker kicks in on an iPhone XS@12.1. iPhone X@12.1.1, iPhone 6s@11.4.1, iPhone 6s Plus@11.4.1 all work fine so it seems to depend on the new hardware.
> 
> Creating a new instance of CMMotionManager always results in a Thread Checker exception
> 
> Main Thread Checker: UI API called on a background thread: -\[UIApplication applicationState\] PID: 9123, TID: 1958556, Thread name: com.apple.CoreMotion.MotionThread, Queue name: com.apple.root.default-qos.overcommit, QoS: 0 Backtrace: 4 libobjc.A.dylib 0x00000002079d7894 \+ 56 5 CoreMotion 0x000000020e2387a4 CoreMotion + 305060 6 CoreMotion 0x000000020e238cd8 CoreMotion + 306392 7 CoreMotion 0x000000020e238be8 CoreMotion + 306152 8 CoreMotion 0x000000020e26a3cc CoreMotion + 508876 9 CoreMotion 0x000000020e26a42c CoreMotion + 508972 10 CoreFoundation 0x0000000208770888 \+ 28 11 CoreFoundation 0x000000020877016c \+ 276 12 CoreFoundation 0x000000020876af54 \+ 1016 13 CoreFoundation 0x000000020876a844 CFRunLoopRunSpecific + 452 14 CoreFoundation 0x000000020876b5a8 CFRunLoopRun + 84 15 CoreMotion 0x000000020e269d64 CoreMotion + 507236 16 libsystem\_pthread.dylib 0x00000002083e5a04 \+ 132 17 libsystem\_pthread.dylib 0x00000002083e5960 \_pthread\_start + 52 18 libsystem\_pthread.dylib 0x00000002083eddf4 thread\_start + 4 2018-10-04 12:09:35.737994+0200 test\[9123:1958556\] \[reports\] Main Thread Checker: UI API called on a background thread: -\[UIApplication applicationState\] PID: 9123, TID: 1958556, Thread name: com.apple.CoreMotion.MotionThread, Queue name: com.apple.root.default-qos.overcommit, QoS: 0
> 
> Comments Happening for me as well, lot of things getting impacted, and yeah only happens on XS, XS Max, and XR
> 
> By jchaudhry at May 6, 2019, 11:36 p.m. (reply...) This issue still happens. Should I file yet another bug report with Apple?
> 
> By aruslan at April 2, 2019, 6:34 p.m. (reply...) Any update on this issue, seems like this is massively impacting a lot of projects
> 
> By xuehao.hu at March 29, 2019, 6:11 a.m. (reply...)
