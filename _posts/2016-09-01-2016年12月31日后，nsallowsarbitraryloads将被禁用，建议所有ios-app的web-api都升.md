---
layout: page_with_comment
title: "2016年12月31日后，NSAllowsArbitraryLoads将被禁用，建议所有iOS App的Web API都升级为HTTPS"
date: "2016-09-01"
categories: 
  - "ios"
  - "php"
  - "互联网"
  - "安全"
tags: 
  - "ats"
  - "https"
  - "ios"
  - "ios10"
  - "tls"
---

苹果的iOS 10正式版本马上就要发布了，而自iOS 10开始，苹果对于网络安全将更加重视，2016年12月31日以后，你将不能用NSAllowsArbitraryLoads来禁止App Transport Security了。

简单说，苹果坚持，你的所有的Web API请求都必须使用https，而如果你需要使用WebView加载外部的网页，考虑到你无法控制外部的网站，苹果引入了新的NSAllowsArbitraryLoadsInWebContent，允许WebView可以加载任意的网页。 `The new NSAllowsArbitraryLoadsInWebContent key for your Info.plist file gives you a convenient way to allow arbitrary web page loads to work while retaining ATS protections for the rest of your app.` 如果你需要在App中加载任意的网页，那么，你可以在Info.plist中添加NSAllowsArbitraryLoadsInWebContent，这样，你可以加载非安全的http页面，同时保证你的app的其他方面仍然受到App Transport Security的保护。

对于许多公司来说，API团队近期有一项非常重要的工作，也就是，如果你们的Web API仍然是通过明文的http进行调用的，那么，你们需要尽快将API的endpoint升级为https。

如果大家真的来不及升级到https，那怎么办呢。我突然想到，苹果只是禁止了NSAllowsArbitraryLoads，但是我们还是可以NSExceptionDomains，将API对应的域名添加到例外列表中的。

The following listing represents the overall structure of the NSAppTransportSecurity dictionary, showing all possible keys, all of which are optional. Keep this structure in mind as you configure each element of the dictionary, as needed, for your app: 以下代码是NSAppTransportSecurity字典的结构模型。该模型列举了所有可能的键值对，这些键值对都是非必须的。您可以根据这个结构中所示的键值对的信息来编辑Info.plist中的NSAppTransportSecurity字典。

```
NSAppTransportSecurity : Dictionary {
    NSAllowsArbitraryLoads : Boolean
    NSAllowsArbitraryLoadsInMedia : Boolean
    NSAllowsArbitraryLoadsInWebContent : Boolean
    NSAllowsLocalNetworking : Boolean
    NSExceptionDomains : Dictionary {
         : Dictionary {
            NSIncludesSubdomains : Boolean
            NSExceptionAllowsInsecureHTTPLoads : Boolean
            NSExceptionMinimumTLSVersion : String
            NSExceptionRequiresForwardSecrecy : Boolean   // Default value is YES
            NSRequiresCertificateTransparency : Boolean
        }
    }
}

```
