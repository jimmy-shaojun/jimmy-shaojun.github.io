---
layout: page_with_comment
title: "Solve a prolem: openjdk20 requires a full Xcode installation, which was not found on your system"
date: "2024-09-22"
tags:
  - "openjdk"
  - "xcode"
  - "macports"
---

I want to install openjdk via macports on macOS 15 Sequoia but got below error message.

```bash
% sudo port install openjdk20
Password:
Error: Port openjdk20 requires a full Xcode installation, which was not found on your system.
Error: You can install Xcode from the Mac App Store or https://developer.apple.com/xcode/
Error: Follow https://guide.macports.org/#project.tickets if you believe there is a bug.
Error: Processing of port openjdk20 failed
```

However, I already have XCode installed.

I then check

```bash
% xcode-select -p
/Library/Developer/CommandLineTools
```

and use `xcode-select` like below and solve this problem.

```bash
% sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
% sudo port install openjdk20 openjdk22 openjdk23 openjdk17      
--->  Computing dependencies for openjdk20
The following dependencies will be installed: 
 autoconf
 bash
 brotli
 cctools
 cmake-bootstrap
 freetype
 gmake
 libpng
 lzip
 m4
 openjdk20-bootstrap
Continue? [Y/n]: y
```