---
layout: page_with_comment
title: "iPhone 6和6 plus的App Icon and Image Resolution Guide"
date: "2014-12-18"
categories: 
  - "ios"
---

Launch Screen Image

Retina HD 5.5 Landscape : 2208x1242 px

Retina HD 4.7 Portrait: 750x1334 px

Retina HD 5.5 Portrait: 1242x2208 px

Other Image

iPhone 6 plus引入了@3x概念，之前的@2x即points（点数） \* 2 =  pixels(像素数)

对应到@3x，即

@3x notation: if 1x = 60px, then 3x = 180px

iPhone 6的屏幕（\[UIScreen mainScreen\]）尺寸：

1\. 375x667 points, 750x1134 pixels (@2x的效果)，如果设置了Retina HD 4.7的Launch Image

2\. 320x568 points,  640x1136 pixels (@2x的效果)，如果**未设置**Retina HD 4.7的Launch Image

iPhone 6 Plus的屏幕（\[UIScreen mainScreen\]）尺寸：

1\. 414x736 points, 1242x2208 pixels(@3x的效果)，如果设置了Retina HD 5.5的Launch Image

2\. 320x568 points, 960x1704 pixels (@3x的效果)，如果**未设置**Retina HD 5.5的Launch Image

注:6 Plus实际的液晶屏分辨率为1080x1920，而app对应的分辨率是1242x2208，所以会有downscale sampling

此外，在Xcode 6中，Launch Screen也可以是一个xib，可以设置Launch Screen File为一个xib而不是设置一个Launch Image
