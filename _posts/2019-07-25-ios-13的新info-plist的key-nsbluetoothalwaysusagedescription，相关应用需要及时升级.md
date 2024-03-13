---
layout: page_with_comment
title: "iOS 13的新Info.plist的key NSBluetoothAlwaysUsageDescription，相关应用需要及时升级"
date: "2019-07-25"
categories: 
  - "ios"
tags: 
  - "bluetooth"
  - "ios"
  - "mobile"
  - "nsbluetoothalwaysusagedescription"
  - "osmo"
  - "大疆"
  - "手持稳定器"
  - "蓝牙"
---

iOS 13在隐私方面有了新的变化，其中一个变化对于视频录制类应用会有较大影响。那就是Privacy - Bluetooth Always Usage Description（NSBluetoothAlwaysUsageDescription）。 如果视频类应用支持手持稳定器，如大疆Osmo Mobile，而目前手持稳定器与手机之间都是通过蓝牙连接的，那么，App的Info.plist中需要添加该Key，否则，App在尝试连接手持稳定器的时候，会crash。

Crash的错误信息如下 This app has crashed because it attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSBluetoothAlwaysUsageDescription key with a string value explaining to the user how the app uses this data.
