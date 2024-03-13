---
layout: page_with_comment
title: "NSDateFormatter性能优化"
date: "2017-09-19"
categories: 
  - "ios"
---

近期在某个项目上，遇到了一个NSDateFormatter的性能问题。

不知何故，app中需要把将近一千个字符串转换为NSDate类型，运行后发现，转换居然要600ms以上，实在是不可忍受。最开始，我发现代码是每次进行转换都新创建一个NSDateFormatter对象，既然如此，我就进行了第一步优化，创建并缓存了全局的NSDateFormatter对象。可是，再次运行后发现，这个优化居然没有效果！！！怎么回事，不是苹果自己的文档说的“[Cache Formatters for Efficiency](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html)”吗？

我用Instrument对应用进行了Profile，发现，创建一个NSDateFormatter并不消耗太长时间，反而是stringFromDate和dateFromString这两个方法耗时间，相比之下，创建NSDateFormatter的时间完全可以忽略不计。

最后，发现NSDateFormatter性能实在是太差，只能用sqlite了。

```
        sqlite3_stmt *statement = NULL;
        sqlite3_prepare_v2(db, "SELECT strftime('%s', ?);", -1, &statement, NULL);
        
        sqlite3_bind_text(statement, 1, [str UTF8String], -1, SQLITE_STATIC);
        sqlite3_step(statement);
        sqlite3_int64 interval = sqlite3_column_int64(statement, 0);
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];

```

strftime可以将yyyy-MM-dd HH:mm:ss这样的字符串转换为timestamp，然后再根据timestamp创建NSDate对象，这样比直接dateFromString要快很多。

同样，stringFromDate性能也很差，我最后直接用

```
calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];

```

获取到NSDateComponents，然后用

```
[NSString stringWithFormat:@"%4ld-%02ld-%02ld", components.year, components.month, components.day];

```

这样的代码获取字符串的日期和时间。

经过Instrument的Profiling，我发现calendarWithIdentifier:这个方法才是真的消耗时间，所以我缓存了NSCalendar对象。

结论，优化NSDateFormatter的结果就是别用NSDateFormatter。
