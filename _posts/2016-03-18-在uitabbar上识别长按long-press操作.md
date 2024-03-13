---
layout: page_with_comment
title: "在UITabBar上识别长按(long press)操作"
date: "2016-03-18"
categories: 
  - "ios"
  - "互联网"
tags: 
  - "uitabbar"
  - "手势"
---

大家或许都知道，现在的智能手机都支持各种手势操作，如长按，单手指或者多手指滑动或点击，随着技术的发展，屏幕还可以识别按压的力度。

在iOS上，我们可以通过Tap/Pan/Pinch/Swipe/Rotate/LongPress Gesture Recognizer来识别各种手势，所以，在UITabBar上识别Long Press(长按)手势其实并不困难，只需要在tab bar上添加一个Long Press Gesture Recognizer就好了。

然而，以上的方案存在一个小小的瑕疵。iOS默认的tab bar，在你点击某一个tab bar button后，就会选中该button对应的item，而如果是tab bar controller的话，就会切换到对应的view controller。实际上，UITabBar在检测到用户按下以后，而不是按下然后拿起手指之后，就选中了对应的bar item，所以，tab bar在识别long press之前，就已经认为用户进行了一次tap。

实际上，更好的方案是，识别long press的话，就不要识别tap了。这就要求，我们需要修改tab bar识别tap的逻辑，即，用户必须touch down（按下）然后touch up（手指离开屏幕），才算一次，而非tab bar默认的行为，touch down就开始处理tap事件。

我采取的措施是，扩展UITabBar，在Tab Bar的view里添加一个overlay view，即这个view确保在Tab Bar的其他subviews的上面，由这个overlay view去识别Tap Gesture，当识别到Tap操作后，根据点击的坐标识别用户点击了哪一个tab bar item。

```
_overlayView = [[UIView alloc] init];
_overlayView.backgroundColor = [UIColor clearColor];
[self addSubview:_overlayView];
self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
[_overlayView addGestureRecognizer:self.overlayGestureRecognizer];

```

```
- (void)tapGesture:(UIPanGestureRecognizer*)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:
        {
            NSInteger touchUpItemIndex = [self barButtonItemIndexAtPoint:point];
            if (touchUpItemIndex != NSNotFound) {
                //touch up inside event
                UITabBarItem *item = [self.items objectAtIndex:touchUpItemIndex];
                //接下来，将selectedItem设置为item，并调用享用的delegate方法。
            }
        }
        break;
    }
}

```

  以上代码的重点，就在于barButtonItemIndexAtPoint的实现。一个比较简单的实现就是，

```
CGFloat itemWidth = self.view.frame.size.width / self.items.count;
NSInteger index = point.x / itemWidth;

```
