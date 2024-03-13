---
layout: page_with_comment
title: "解决问题：React Native Error building DependencyGraph:  Error: Naming collision detected"
date: "2015-12-16"
categories: 
  - "android"
  - "ios"
  - "nodejs"
  - "react"
---

React Native是Facebook出品的一款支持iOS和Android的跨平台开发框架，可以让工程师用reactjs编写iOS和Android应用，不过在使用过程中，我们都会遇到一些问题。

如 https://github.com/facebook/react-native/issues/3440 里所说的一样，如果你再一个React Native工程中还是用了cocoapods，那么你就可能遇到Pods/目录下和工程当前目录下都有node\_modules，从而导致以下错误

Error building DependencyGraph: Error: Naming collision detected: /Users/dev/Documents/Xcode/react-native/AwesomeProject/Pods/React/Libraries/vendor/react/platformImplementations/universal/worker/UniversalWorkerNodeHandle.js collides with /Users/dev/Documents/Xcode/react-native/AwesomeProject/node\_modules/react-native/Libraries/vendor/react/platformImplementations/universal/worker/UniversalWorkerNodeHandle.js at HasteMap.\_updateHasteMap (HasteMap.js:123:13) at HasteMap.js:95:28 at tryCallOne (/Users/jimmy/Documents/Xcode/react-native/AwesomeProject/node\_modules/react-native/node\_modules/promise/lib/core.js:37:12) at /Users/jimmy/Documents/Xcode/react-native/AwesomeProject/node\_modules/react-native/node\_modules/promise/lib/core.js:103:15 at flush (/Users/jimmy/Documents/Xcode/react-native/AwesomeProject/node\_modules/react-native/node\_modules/promise/node\_modules/asap/raw.js:50:29) at doNTCallback0 (node.js:417:9) at process.\_tickCallback (node.js:346:13)

 

怎么办呢？目前知道的有个办法

定制projectRoots

在工程目录下执行命令 ./node\_modules/react-native/packager/packager.sh --projectRoots \`pwd\`/src --projectRoots \`pwd\`/node\_modules
