---
layout: page_with_comment
title: "一个小问题Phabricator的部分界面无法本地化"
date: "2017-08-22"
tags: 
  - "phabricator"
  - "php"
---

最近我进行了一些Phabricator本地化的工作，在这个过程中，我发现Phabricator的一小部分界面始终无法翻译，即使我在[PhabricatorCNChineseTranslation.php](https://github.com/liuqian1990/phabricator-zh_CN)中添加了相应的翻译项。

这部分无法翻译的界面是下图中的"Tag"这样的文字。 [!["Tag"无法被翻译](/images/pha_translate.png)](/images/pha_translate.png)

Phabricator是通过[pht](https://secure.phabricator.com/book/libphutil/function/pht/)函数实现本地化的，pht('User')将会返回User的本地化翻译，如果没有可用的翻译，那么就会返回'User'自身。

如果我们深入Phabricator的代码，我们不难发现，上图中的"Tag"之所以无法翻译，是因为这个"Tag"来源于[PhabricatorProjectIconSet](https://secure.phabricator.com/book/phabdev/class/PhabricatorProjectIconSet/)类的如下代码。

```
private static function getIconSpecifications() {
  return PhabricatorEnv::getEnvConfig('projects.icons');
}

```

上述代码其实是从Phabricator的配置项projects.icons中载入"Tag", "Project"等配置。 这个配置项其实就是一串JSON [![projects.icons](/images/projects.icons_.png)](/images/projects.icons_.png)

不难看出，无论如何，载入projects.icons的时候，Phabricator不会对projects.icons这个配置项的内容进行任何pht操作，这也就导致"Tag"等文本不会被翻译了。

我在自己的本地代码中，对PhabricatorProjectIconSet进行了如下改动，即在getIconSpec和getIconName函数上加上pht的调用。这样就可以实现本地化翻译了。但是，这样的改动是不符合Phabricator的pht规范的，即传入给pht的参数必须是scala string value，而由于下面的代码的缘故，我们并不能保证pht($value)的$value是一个scala value，理论上也可能是一个array（projects.icons是一个可以任意修改的配置项，所以我们并不能保证$value是scala），所以，我的代码是不能通过[arc](https://secure.phabricator.com/book/phabricator/article/arcanist/) lint的。

```
 public static function getIconName($key) {
    $spec = self::getIconSpec($key);
    return pht(idx($spec, 'name', null));
  }

 private static function getIconSpec($key) {
    $icons = self::getIconSpecifications();
    foreach ($icons as $icon) {
      if (idx($icon, 'key') === $key) {
        $spec_local = array();
        foreach ($icon as $key => $value) {
          if ($key == 'name') {
            $spec_local['name'] = pht($value);
          } else {
            $spec_local[$key] = $value;
          }
        }
        return $spec_local;
      }
    }

    return array();
  }

```

简而言之，上述的代码只是一个补丁，仍然不是最好的方案，但是至少能够保证翻译了。
