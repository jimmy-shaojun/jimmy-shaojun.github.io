---
layout: page_with_comment
title: "说说ITMS-90682: can't contain 16-bit or P3 assets if the app supports iOS 8 or earlier"
date: "2016-10-29"
# categories: 
#   - "ios"
#   - "mac"
tags: 
  - "imac"
  - "ios"
  - "ipad"
  - "iphone"
  - "mac"
  - "macbook"
  - "macos"
  - "p3"
  - "photoshop"
---

昨日，我在工作中听到我部门打包好的IPA，到了测试的时候，一旦测试的手机是iOS 8或者9.2的手机，应用总是会随机崩溃。最后，同事们找到了原因，具体原因见 http://stackoverflow.com/questions/39404285/xcode-8-build-crash-on-ios-9-2-and-below

> When I build my app with Xcode 8 GM Seed and run it on an iOS 9.2 below device OR simulator, I get strange EXC\_BAD\_ACCESS crashes during app startup or a few seconds after the app launched. The crash always happens in a different spot (adding a subview, \[UIImage imageNamed:\], app delegate's main method etc). I don't get those crashes when I run it on iOS 9.3+ or 10 and I don't get them when I build with Xcode 7 and run on iOS 9.2 and below. Has anyone else experiences something similar? Is this a known issue with Xcode 8?
> 
> 当我用Xcode 8 GM Seed打包应用并在iOS 9.2或者更低版本的设备或模拟器运行的时候，我总是会在应用启动时或启动后的数秒之内遇到EXC\_BAD\_ACCESS，而崩溃的地方每次都不一样，如addSubView,\[UIImage imageNamed:\]甚至main方法。如果我在9.3或者10上运行，或者我用Xcode 7执行编译工作，然后运行在9.2以及以下的设备上，这些错误都不会发生。有没有人遇到类似的事情呢，这是不是Xcode 8的一个问题？

而解决的方法在这里讲了https://forums.developer.apple.com/thread/60919?start=0&tstart=0。简单说，Xcode认为你的图片资源中包含了16位或者P3的资源，所以打包的时候会进行相应的处理，但是，只有9.3或者更高版本才支持这样的资源，所以到了9.2就会崩溃。

此时，我想说说什么是[P3](https://en.wikipedia.org/wiki/DCI-P3)资源。P3指的是[DCI-P3](https://en.wikipedia.org/wiki/DCI-P3)或者说[DCI/P3](https://en.wikipedia.org/wiki/DCI-P3)，一种数字电影投影所用的色域标准，它能比sRGB显示更多的颜色。苹果在推出5k显示屏的new iMac的时候（2015年10月），引入了DCI-P3，随后9.7寸的iPad Pro（2016年3月推出，推出时iOS 9.3系统）、iPhone 7（2016年9月推出，iOS 10系统）和2016的MacBook Pro都使用了DCI-P3色域。即苹果公司的iOS 9.3系统支持DCI-P3色域，而iPad Pro作为第一个支持DCI-P3的iPad，使用的是iOS 9.3。这也就解释了为什么我们之前打包的IPA到了9.2的设备上就会不正常。

那么，如何判断一个图片是不是P3的图片呢，其实很简单，就是要看这个图片的Color Profile是什么，通常来说，一个图片应该没有内嵌Color Profile或者内嵌sRGB的Color Profile。下面一个例子，我进行了两张图片的对照，左边为P3的png，右边为普通的png。[![P3和非P3图片对照](/images/P3_and_ordinary_png.png)](/images/P3_and_ordinary_png.png)

不难发现，左侧的图片有内嵌的Color Profile：Display，而右侧的常规的图片没有内嵌的Profile。那问题来了，为什么Color Profile: Display是P3资源呢？Display难道等于DCI-P3吗？

这里需要说明的是，Display指的是制作图片的人所使用的电脑的显示器所使用的Color Profile，具体这个Profile是什么，那要看制作者的电脑上的Display对应的Color Profile是什么，如果制作者使用的是5k的iMac，那么Display对应的Profile就是P3了。 下图为笔者的MacBook Pro的Photoshop新建一个图像的对话框。 [![display_and_display_p3](/images/Display_and_Display_P3.png)](/images/Display_and_Display_P3.png) 我们看到，默认的是Display，即用户当前显示器所使用的Color Profile，此外，还有许多Color Profile可以选择，如Display P3，这就是DCI-P3色域的Color Profile。如果你用的是5k的new iMac，那么Display就等于Display P3，如果你用的是别的Mac，比如笔者的2013的MacBook Pro，那么Display就等于sRGB。

下图为2016的MacBook Pro的技术规格，请大家注意“广色域(P3)”这几个字。这就是前面提到的P3 assets中P3的含义。 [![2016 MacBook Pro的显示屏采用了广色域P3](/images/2016MacBookProP3.png)](/images/2016MacBookProP3.png)

解决方法如下，摘录自https://forums.developer.apple.com/thread/60919?start=0&tstart=0，我就不翻译了。当然，最好是设计师在设计资源的时候，如果使用的是5k的iMac或者2016年新推出的MacBook Pro，那么，不要选择默认的Display选项，要选择sRGB，这样图片资源就可以用于支持iOS 8和iOS 9.2版本的工程了。

> You can find 16-bit or P3 assets by running “assetutil” on the asset catalog named in the error message from iTunes Connect. The following steps outline the process: 1. Create an Inspectable .ipa file. In the Xcode Organizer (Xcode->Window->Organizer), select an archive to inspect, click “Export...", and choose "Export for Enterprise or Ad-Hoc Deployment". This will create a local copy of the .ipa file for your app. 2. Locate that .ipa file and change its the extension to .zip. 3. Expand the .zip file. This will produce a Payload folder containing your .app bundle. 4. Open a terminal and change the working directory to the top level of your .app bundle cd path/to/Payload/your.app 5. Use the find tool to locate Assets.car files in your .app bundle as shown below: find . -name 'Assets.car' 6. Use the assetutil tool to find any 16-bit or P3 assets, in each Assets.car your application has as shown below. : sudo xcrun --sdk iphoneos assetutil --info /path/to/a/Assets.car > /tmp/Assets.json 7. Examine the resulting /tmp/Assets.json and look for any contents containing “DisplayGamut": “P3” and its associated “Name". This will be the name of your imageset containing one or more 16-bit or P3 assets. 8. Replace those assets with 8-bit / sRGB assets, then rebuild your app. Update: If your Deployment Target is set to either 8.3 or 8.4 and you have an asset catalog then you will receive this same error message, even if you do not actually have 16-bit or P3 assets. In this case you will either need to lower your Deployment Target to 8.2, or move it up to 9.x.
