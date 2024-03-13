---
layout: page_with_comment
title: "iOS UILabel显示了重叠文字（gets combined, superimposed, overlapped）"
date: "2016-06-29"
# categories: 
#   - "ios"
tags: 
  - "combined"
  - "ios"
  - "overlapped"
  - "superimposed"
  - "uilabel"
  - "重叠"
---

[![Screen Shot 2016-06-30 at 12.07.11 AM](/images/Screen-Shot-2016-06-30-at-12.07.11-AM.png)](/images/Screen-Shot-2016-06-30-at-12.07.11-AM.png)

今天调试遇到了一个问题，上图是一个UILabel的截图，该UILabel的text属性实际上是“21张”，然而，如果你仔细看这张截图的话，似乎可以看出，大约是一个“21张”文字的渲染结果叠加了一个“10张”文字的渲染效果。通常，出现这种情况，我的第一反应是我是不是重复的addSubView了，导致多个UILabel相重叠了。

然而，仔细检查了代码，并且用Reveal查看了View层次结构后，我确认了一点，没有多个UILabel重叠，确实只有那一个UILabel并且就是该UILabel把“21张”渲染成了上图的模样。

最后发现，问题在于UILabel的backgroundColor不能设置为nil，也不能设置为透明色。只要给UILabel设置了背景色，这个问题就解决了。

而且，我发现这不是个例，早在2012年，2013年就已经有人遇到这个问题，而且，根据Stackoverflow.com提供的线索，这似乎是iOS 5开始才有的问题（看后面的If I try it on an iPhone 4, the previous text of the label doesn't disappear）。如今，iOS 10都快要正式版了，没想到这个问题还在。

最后，给大家忠告，一定要仔细检查UILabel的背景，千万不要把backgroundColor设置成透明色或者nil。

参考资料如下

http://www.cocoachina.com/bbs/read.php?tid=257298 主题 : UILabel背景为透明时，刷新文字会和旧文字重叠 楼主 ： 发表于: 2013-03-06 17:04

把label的背景色从默认（也就是clear color）设成其他颜色，问题就解决了。

如果有时候需要label背景透明，那又该怎么办呢？

http://stackoverflow.com/questions/2271144/setting-transparent-background-for-uilabel-for-iphone-application

Nullifying the backgroundColor works fine at first, but if you subsequently change the label's text, the new text will be superimposed on the old. Very weird. – Wienke Sep 27 '12 at 19:50 （编者注：这是2012年9月27日的评论，原问题发表于2010年4月29日。将backgroundColor属性设置为nil，最开始你会发现能如你所愿，然后，随后你就会发现，如果你更改了label的text属性，新的文本会重叠在旧的文本之上。非常奇怪。）

http://stackoverflow.com/questions/10373119/uilabels-new-text-gets-combined-with-previous-text-when-testing-on-real-iphone#

I have some UILabel objects in my app, and I change their value when a button is pressed. It works fine in the simulator and on old iPhones, but If I try it on an iPhone 4, the previous text of the label doesn't disappear, it shows behind the the new text (well, sometimes it disappears and only the correct text appears, but most of the times it doesn't work right). （编者注：提问者说道，在模拟器和比iPhone 4老的iPhone上，一切正常，可是，如果是iPhone 4，UILabel设置了新的文本的话，旧的文本仍然显示在新的文本的后面，这正如本文最开始的截图所显示的那样。） asked Apr 29 '12 at 14:53

I can tell you it's not a bug, and not common. I'm guessing that you have a transparent background behind UILabel? And redraw might not be correctly handled in the background view. You might want to post more about your view hierarchy. – He Shiming Apr 29 '12 at 17:08 （编者注：后面有人评论，我可以告诉你，这不是bug，也不常见。 我猜测你的UILabel一定有一个透明的背景，而redraw操作或许不能正确处理透明背景的情况。你或许应该告诉大家你的视图层次结构的详细信息。）
