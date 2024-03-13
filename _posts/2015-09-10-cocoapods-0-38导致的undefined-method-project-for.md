---
layout: page_with_comment
title: "cocoapods 0.38导致的undefined method `project' for #"
date: "2015-09-10"
categories: 
  - "ios"
---

公司的iOS项目，需要给QA打包Debug版本的测试包，因此，我需要把ONLY\_ACTIVE\_ARCH给设置为FALSE，我用的是以下pod代码实现的这个功能。

installer\_representation.project.targets.each do |target|

            target.build\_configurations.each do |config|

                config.build\_settings\['ONLY\_ACTIVE\_ARCH'\] = 'NO'

            end

end

本来以上代码一直运行正常的，直到cocoapods推出了0.38版本，结果pod install就会报如下错误

undefined method \`project' for #<Pod::Installer

原因也不复杂，如https://github.com/CocoaPods/CocoaPods/issues/3747所说的，“_you probably just want to change `project` to `pods_project`_”，原来0.38版本的pod，开发者做了一个巨大的改动，**“we made a major conceptual change in how we provide access for advanced users to hook into the installation process**”，结果就是project没了，改成pods\_project了。这下兼容性全破坏掉了。

那怎么办呢。难道全公司的人一瞬间全都升级成0.38？

好在pod是基于ruby的，最后我把以上代码改成

if defined? installer\_representation.project     installer\_representation.project.targets.each do |target|          target.build\_configurations.each do |config|                 config.build\_settings\['ONLY\_ACTIVE\_ARCH'\] = 'NO'             end end

if defined? installer\_representation.pods\_project     installer\_representation.pods\_project.targets.each do |target|          target.build\_configurations.each do |config|                 config.build\_settings\['ONLY\_ACTIVE\_ARCH'\] = 'NO'             end end

关于defined?，可以查看ruby的文档，http://ruby-doc.org/docs/keywords/1.9/Object.html#method-i-defined-3F

> The return value is `nil` if the expression cannot be resolved

所以，在0.38的pod中，defined? installer\_representation.project返回nil，在0.37中，则返回非nil。所以，0.38的pod中，下面一个if中的语句得到执行，0.37中，上面的if中的语句得到执行。我们的Podfile可以兼容0.38和0.37了。
