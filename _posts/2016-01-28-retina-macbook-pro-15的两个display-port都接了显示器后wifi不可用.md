---
layout: page_with_comment
title: "retina macbook pro 15的两个display port都接了显示器后wifi不可用"
date: "2016-01-28"
categories: 
  - "mac"
---

前天，我把自己的retina macbook pro 15的两个thunderbolt口都接上了4k的显示器，然后，显示器接上后，wifi突然不可用了，表现形式为，wifi符号显示已经连接上，然而，无论如何都上不了网，访问任何网站都是time out错误，如果把其中一个显示器断开的话，就可以上网了。

我到网上搜索了一下，发现了这个thread

https://discussions.apple.com/thread/4155096?start=30&tstart=0

标题写的是“My wifi drops when I plug in an external monitor through the thunderbolt port”。

里面提到

> **[Guza](https://discussions.apple.com/people/Guza)**Jul 9, 2014 8:25 AM [in response to raysian24](https://discussions.apple.com/message/19086376#19086376 "Go to message")
> 
> If hooking up a thunderbolt output for a display and your wifi stops working try the following.
> 
> If your using an apple airport express go to the finder.
> 
> 1\. Type in airport, then open airport utility.
> 
> 2\. Click on Base Station.
> 
> 3\. Click Edit.
> 
> 4\. Click Wireless.
> 
> 5\. Open Wireless Options tab.
> 
> 6\. Where you see the 2.4GHz Channel listed change it to 4.
> 
> 7\. where you see 5GHz Channel Change it to 149
> 
> 8\. Click save and apply.
> 
>  
> 
> That should do the trick.

总结下来，就是5GHz的wifi的channel设置为149，2.4GHz的wifi的channel设置为4。

我这样设置后，果然也成功了，接上两个4k显示器后，wifi连接也一切正常。
