---
layout: page_with_comment
title: "解决微信登录 “Scope 参数错误或没有Scope 权限” 问题"
date: "2016-03-23"
categories: 
  - "ios"
  - "互联网"
tags: 
  - "公众号"
  - "微信"
  - "运营"
---

目前，微信，微博登录已经成为各个手机应用不可或缺的登录方式之一了，如果谁的app还没有添加这两种登录方式，那么您就落后于市场主流了。

然而，微信登录功能增加后，还是要经常维护的，比如每年需要进行公众号的年检，如果您没有及时年检，那么，微信登录就会出现很多问题。

笔者近期在调试app的时候，就发现，点击app的微信登录按钮，跳转到微信后，微信提示“Scope 参数错误或没有Scope 权限”，这让我感到莫名其妙啊。怎么可能scope参数错误呢，微信的Api中，用于登录的是SendAuthReq这个class，我很确定我设置了SendAuthReq的scope属性，并且是正确的。这么看来，真实的原因就是没有scope权限了。

多试验了几次，发现，有几次不会出现这个“Scope 参数错误或没有Scope 权限”错误，微信也会正确跳转回app，并且也可以获取code，然而，这时候调用微信的sns/oauth2/access\_token API就会出现48001, api unauthorized错误。

最开始，我通过bing和google搜索了以上错误信息，结果，这个错误的根本原因多重多样。

1. 2014年微信增加了“网页授权”，如果不开启这个选项，那么就会出现本错误。http://www.w-nn.cn/jiaocheng/423.html
2. 还有人发现，scope参数在url中的位置不一样也会导致scope参数错误，http://my.oschina.net/u/202293/blog/387513。不过，笔者这里是iOS app用微信登录，所以可以排除这种可能
3. 还有一些论坛中开发者求助，然后过了一会，求助的人自问自答道：“解决”。http://bbs.youzan.com/forum.php?mod=viewthread&tid=1113。 笔者看到这里感到，既然解决了，为什么不把原因和解决方案共享出来呢。
4. mob.com的ShareSDK论坛也有人求助：http://bbs.mob.com/thread-20961-1-1.html，这个最后没有提到怎么解决的。
5. 此外，还发现了http://tieba.baidu.com/p/4081677132，其中提到 乐动力 微信登录异常，原因就是微信公众号年审还没通过。而这里面所说的登录异常，就是“Scope 参数错误或没有Scope 权限”

我这次遇到的问题，根源就在于公众号没年审，所以微信登录被停掉了。我找运营部门的同事进行以下公众号年审就行了。

以前都及时年审了，所以没遇到这个问题，近年来，微信公众号申请的越来越多，这下子每个人要负责很多个微信号，这导致很容易就会有某个微信号维护不及时。
