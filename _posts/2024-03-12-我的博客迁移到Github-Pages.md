---
layout: page_with_comment
title: "我的博客已经迁移到Github Pages"
date: "2024-03-12"
tags: 
  - "misc"
  - "liquid"
  - "github"
---

今天，我将我的博客 huang.sh 从wordpress迁移到了Github Pages

第一步，我参考[Export Your Website’s Content](https://wordpress.com/support/export/)将我的wordpress导出为export.xml
[![export-all-button](/images/export-all-button.png)](/images/export-all-button.png)
[![download-export-file](/images/download-export-file.png)](/images/download-export-file.png)

第一步，我创建了github repo jimmy-shaojun/jimmy-shaojun.github.io.git

第二部，我将该repo clone到本地，然后执行转换
```
git clone git@github.com:jimmy-shaojun/jimmy-shaojun.github.io.git
```

第三步，我参考[Moving my Blog from Wordpress to Github Pages](https://haralduebele.github.io/2021/02/10/Moving-my-Blog-from-Wordpress-to-Github-Pages/), 使用[wordpress-export-to-markdown](https://github.com/lonekorean/wordpress-export-to-markdown)将wordpress export.xml转换为markdown

```
jimmy-shaojun.github.io % npx wordpress-export-to-markdown

Starting wizard...
? Path to WordPress export file? export.xml
? Path to output folder? _posts
? Create year folders? Yes
? Create month folders? No
? Create a folder for each post? No
? Prefix post folders/files with date? Yes
? Save images attached to posts? Yes
? Save images scraped from post body content? Yes
? Include custom post types and pages? No
```

第四步，我修改了_posts目录下的md文件，并将_posts/images 移动到 ./images，使之达到现在的效果

第五步，我创建了 _layouts/page_with_comment.html，添加了基于[utterances](https://utteranc.es/)的comment功能