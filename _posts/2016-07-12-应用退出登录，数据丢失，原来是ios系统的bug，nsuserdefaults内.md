---
layout: page_with_comment
title: "应用退出登录，数据丢失，原来是iOS系统的bug，NSUserDefaults内容随机消失"
date: "2016-07-12"
categories: 
  - "ios"
  - "互联网"
  - "安全"
---

最近，我突然发现用着用着很多应用就要我重新登录了，我自己的app在调试的时候，也经常发现原来保存的登录状态也消失了。经过调查，我发现，原因在于保存在NSUserDefaults中的登录信息没了，而保存在keychain和文件中的信息还有。

经过查找，我发现了如下信息，原来是iOS 9.3的一个bug，应用用于保存信息的NSUserDefaults的内容会随机消失。 https://forums.developer.apple.com/thread/44264

iOS 9.3.1 NSUserDefaults Wiped Bug?

elementarteilchen May 6, 2016 5:11 AM (in response to staminajim\_sg) Yes. It seems that the iOS just "forgets" to load the data sometimes. If this happens in my own App while debugging, I can easily kill the App and prevent that it will change the userdefaults, and the next time I lanuch it again, the settings are usually loaded just fine. The big problem is that when you are not debugging your own Apps, you do not have a chance to kill an App before it save any settings, and when an App does this, the old settings are overwritten and lost forever. （给staminajim\_sg的回复） 是的。这看起来是iOS似乎有时候忘记及时加载数据了。我在调试的时候常常发现这个现象发生，在这种情况下，我可以用杀掉app的方式防止我的app执行对NSUserDefaults的修改操作，这样子，下一次我再启动app，原来的设置都还在而且也会正确加载。最大的问题是，如果你不是在调试你的App，你就没有办法像我一样杀死App，这就导致App会执行写操作，原有的设置就会被覆盖掉了。

Rygen May 27, 2016 6:10 AM (in response to elementarteilchen) Also facing the same issue since 9.3, and now it persists on 9.3.2. I've had this issue happen with a first party app as well - Weather. It lost all the saved cities, about one month ago. Whatsapp is by far the worst in terms of data loss. You can't avoid some of it even if you're obsessively backing it up to iCloud every single time you use the app. I know of one person which is not using the iPhone as a development device and is also having the same problem, so this NSUserDefaults issue is probably not related to that. Which iPhone models are you seeing the issue on? Mine is a 5S. I've submitted a bug report to Apple. （给elementarteilchen的回复） 我从iOS 9.3版本开始就遇到这样的问题，现在已经升级到9.3.2了，问题依旧存在。 我最开始遇到这个问题，是一个月以前，在我的天气应用上，我的天气应用中保存的城市列表都消失了。 Whatsapp则是受到影响最大的，即便你经常通过iClound备份，你的数据也会丢失。 我知道一个案例，一个用户并不是将他的/她的iPhone作为开发设备，而他/她也遇到了类似的现象，这表明NSUserDefaults问题并不是因为iPhone被设置为开发设备的缘故。 大家在那些iPhone型号上遇到这个问题了？我的是iPhone 5S

ChaoticBox Jun 19, 2016 1:06 AM (in response to NeilFau) I've been seeing this as well but figured out a workaround for my own apps: If my keys aren't found, call resetStandardUserDefaults and try again. It shouldn't hurt to repeat that a few times before bailing and assuming it's a first-run, but so far it has always worked after the first reset. （给NeilFau的回复） 我也遇到了相同的问题，不过我找到了一个变通的方法。如果我的应用在启动的时候发现某个键值对应的值不存在，那么我会首先调用resetStandardUserDefaults，然后接着再试着获取该值。重复几次resetStandardUserDefaults的操作，如果这样仍然无法取到相应的值，那么可以认定这是首次运行。这样的操作并不繁琐复杂，但是截至到目前位置，我发现这个方案是有效的。

alexfit Jul 6, 2016 12:30 AM (in response to NeilFau) This has been happening to me for the last few months. By FAR, the most distressing bug I've encountered on iOS as a user. Can't use What's App, as I'm constantly losing chat history. Have to log in again to Evernote, Instagram. Settings and tips for many apps reset and I'm sent back to onboarding screens. For the first time, I've lost all trust in my iPhone. A thought of getting a "reliable" Android phone crossed my mind... I hope this is getting fixed, soon. （给NeilFau的回复） 这个问题在最近几个月一直困扰着我。到目前为止，这是我见过的最令人烦恼的一个iOS的bug。我不能用Whatsapp，因为我经常会丢失聊天记录。我不得不重复登录Evernote，Instagram。许多应用的设置和提示都被重置了，这导致我每次启动都见到欢迎界面。

这是我首次丧失了对iPhone的信任，我已经开始考虑买一个可靠的安卓手机了。

希望这个bug能够被尽快修复。
