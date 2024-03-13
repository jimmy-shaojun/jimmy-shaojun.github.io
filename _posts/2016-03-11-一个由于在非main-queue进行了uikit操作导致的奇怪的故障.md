---
layout: page_with_comment
title: "一个由于在非main queue进行了UIKit操作导致的奇怪的故障"
date: "2016-03-11"
categories: 
  - "ios"
---

今天调试app的时候，发现了一个奇怪的bug，当app需要pushViewController的时候，会出现一个奇怪的现象，就是push和pop的动画不会出现，即使animated参数都是YES。这个现象不是每次运行必然复现，而是运行10次，大概会有3到4次出现这个现象。

我经过试验，发现这个现象是从某天我开始编写某一个定制化的TabBar开始出现的，我将写这个控件之前的代码checkout出来，结果发现push/pop动画都一切正常，难道新的控件有什么bug。

经过一翻详细的检查，我发现其实导致这个bug的根本原因不是新的TabBar控件，而是我使用TabBar的代码存在问题，在background queue中进行了UIKit操作。

对于TabBar的每一个UITabBarItem，它的image和selectedImage都需要从网络下载，app在background queue下载image，然后resize到30x30，最后在main queue中赋值到tab bar item对应的属性。

问题就出在resize的步骤，我调用了UIImage的一个category的resizeImageToSize方法，这个方法会生成一个临时的UIImageView，将image view的size设置为目标image的size，从而实现resize。

所以，如果我要使用resizeImageToSize方法，那么我就必须在main queue中进行resize操作，而不能在background queue中进行resize操作。而这个方法不是我编写的，所以之前不知道这个方法会用到UIKit的东西，这导致我就无意中在background queue中进行了UIKit操作，而这次非法操作又没有导致app crash，所以我就没有第一时间想到可能是与UIKit和非main queue的问题。

发现了根本原因之后，我重写了resizeImageToSize方法，不再使用临时的UIImageView进行resize操作。

随后，我重新编译并运行app，多次操作后，push/pop动画的bug再也没有重现过，问题解决。

总结：如果你发现app突然变得很奇怪，有些时候，本来该有动画的，动画却没有出现，那么，几乎可以确定某一处代码在非main queue中进行了UIKit操作，而且这种操作不一定会导致crash。
