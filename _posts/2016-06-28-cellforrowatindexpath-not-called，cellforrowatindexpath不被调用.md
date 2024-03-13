---
layout: page_with_comment
title: "cellForRowAtIndexPath: not called，cellForRowAtIndexPath不被调用"
date: "2016-06-28"
categories: 
  - "ios"
---

今天遇到了一个神奇的事情 tableView:cellForRowAtIndexPath:这个方法，我的TableViewDataSource里已经实现了，可是，无论如何，都不会被调用。 我在numberOfRowsInSection和numberOfSectionsInTableView和cellForRowAtIndexPath三处都设置了断点，然而，前两个方法都得到了调用，唯独最后一个cellForRowAtIndexPath，无论如何都不会被调用。

我可以确定numberOfRowsInSection和numberOfSectionsInTableView都返回了非0的值。

最后我发现，我的DataSource还实现了 sectionIndexTitlesForTableView 和 titleForHeaderInSection 两个方法，只不过我都在这两个方法中返回了nil。

最后我删除了这两个方法的代码，结果，cellForRowAtIndexPath被系统调用了，我的TableView的内容也可以正常显示了！！！

目前我也不知道怎么回事，因为，sectionIndexTitlesForTableView和titleForHeaderInSection的返回值的声明是nullable的，而且之前这两个方法也是这么实现了，并且上个月，同样的情况，cellForRowAtIndexPath就被系统调用了。

这个事情实在让我百思不得其解，所以写一篇blog记录下来。
