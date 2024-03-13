---
layout: page_with_comment
title: "iOS 8的Developer新选项 Enable UI Automation默认Off，需要自动化测试请设置为On"
date: "2015-01-09"
categories: 
  - "ios"
---

今天心血来潮，想要玩玩iOS的自动化测试，然而，却发现Instruments一直报错误"An error occurred while trying to run the script." 这是怎么回事呢。

最后发现是这么回事，iOS 8新增了开发者选项"Enable UI Automation"，默认情况下是Off，要用Instrument进行自动化测试，必须将该选项设置为On。

> **iOS 8 Enhancement:** iOS 8 includes a new Enable UI Automation preference under Settings > Developer, which allows third-party developers finer control of when their devices are available to perform automation. For physical iOS devices, this setting is off by default and must be enabled prior to performing any UI Automation. In the simulator, the setting is enabled by default.

[https://developer.apple.com/library/ios/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/UsingtheAutomationInstrument/UsingtheAutomationInstrument.html](https://developer.apple.com/library/ios/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/UsingtheAutomationInstrument/UsingtheAutomationInstrument.html)
