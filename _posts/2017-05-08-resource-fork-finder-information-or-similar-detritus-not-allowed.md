---
layout: page_with_comment
title: "resource fork, Finder information, or similar detritus not allowed"
date: "2017-05-08"
categories: 
  - "ios"
  - "mac"
tags: 
  - "code-signing"
  - "fork"
  - "ios"
  - "resource"
---

今天，我准备更新我的一个app，这个app很久以前上架的，当时还是iPhone 32位 CPU的时候，所以有必要更新一次。

然而，在编译过程中，我遇到了以下错误： `resource fork, Finder information, or similar detritus not allowed`

经过一番搜索，找到了解决方案。

http://stackoverflow.com/questions/39652867/code-sign-error-in-macos-sierra-xcode-8-resource-fork-finder-information-or

https://developer.apple.com/library/content/qa/qa1940/\_index.html

原来，MacOS的文件有三个fork，data fork, resource fork和Finder info。Data fork存储了文件的内容；resource fork保存了一些扩展信息，如什么应用创建了这个文件，又例如上次你打开这个txt文件的时候，正在显示的是第几行，等等； Finder Info则保存了文件所有者，创建者等信息。

从iOS 10和macOS Sierra开始，从安全考虑，app bundle中的文件将不能包含resource for和Finder info了。所以，我们必须去掉这两个信息，才能成功进行代码签名。具体如何去掉这两块信息，大家可以参考下面的说明。

```
40
Code signing fails with error 'resource fork, Finder information, or similar detritus not allowed'

Q:  When I build my app, code signing fails with the error "resource fork, Finder information, or similar detritus not allowed." What does this mean and what should I do about it?

A: This is a security hardening change that was introduced with iOS 10, macOS Sierra, watchOS 3, and tvOS 10.

Code signing no longer allows any file in an app bundle to have an extended attribute containing a resource fork or Finder info.

To see which files are causing this error, run this command in Terminal:

$ xattr -lr 

replacing  with the path to your actual app bundle.

Here's an example of this command in action:

$ xattr -lr Foo.app
/Applications/Foo.app: com.apple.FinderInfo:
00000000  00 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00  |................|
You can also remove all extended attributes from your app bundle with the xattr command:

$ xattr -cr 

Note that browsing files within a bundle with Finder's Show Package Contents command can cause Finder info to be added to those files. Otherwise, audit your build process to see where the extended attributes are being added

```
