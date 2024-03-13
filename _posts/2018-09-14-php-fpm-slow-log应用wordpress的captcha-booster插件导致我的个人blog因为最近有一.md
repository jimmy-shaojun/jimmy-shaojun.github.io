---
layout: page_with_comment
title: "[php-fpm slow log应用]wordpress的Captcha Booster插件导致我的个人blog因为最近有一段时间无法访问"
date: "2018-09-14"
categories: 
  - "php"
tags: 
  - "captcha"
  - "log"
  - "php"
  - "slow"
---

我的blog最近有一段时间不能访问了，总是报504 Gateway Timeout。 具体原因如下。

我用php-fpm作为fastcgi server，nginx通过reverse proxy连接到php-fpm，然后php-fpm执行wordpress代码并将html数据返回给用户。

我的wordpress的编辑后台添加了Captcha Booster插件，这样登录界面就有captcha了。然而，没想到就是这个插件，导致了我的blog无法访问。

我通过启用了php-fpm的slow log，发现问题出在plugins/wp-captcha-booster/wp-captcha-booster.php:552

```
[14-Sep-2018 16:55:58.866159]  [pool www] pid 31454
script_filename = /usr/share/nginx/wordpress/wp-admin/index.php
[0x00007f5ea7fe2398] file_get_contents() /usr/share/nginx/wordpress/wp-content/plugins/wp-captcha-booster/wp-captcha-booster.php:552
[0x00007f5ea7fe21b8] get_ip_location_captcha_booster() /usr/share/nginx/wordpress/wp-content/plugins/wp-captcha-booster/wp-captcha-booster.php:576
[0x00007f5ea7fe2060] blocking_visitors_captcha_booster() /usr/share/nginx/wordpress/wp-content/plugins/wp-captcha-booster/wp-captcha-booster.php:901
[0x00007fffb287fcb0] user_functions_for_captcha_booster() unknown:0
[0x00007f5ea7fe1ef8] call_user_func_array() /usr/share/nginx/wordpress/wp-includes/class-wp-hook.php:286
[0x00007f5ea7fe1dd0] apply_filters() /usr/share/nginx/wordpress/wp-includes/class-wp-hook.php:310
[0x00007f5ea7fe1c70] do_action() /usr/share/nginx/wordpress/wp-includes/plugin.php:453
[0x00007f5ea7fe1ab8] do_action() /usr/share/nginx/wordpress/wp-settings.php:450
[0x00007f5ea7fe1990] +++ dump failed

```

在Captcha Booster的代码中

wordpress/wp-content/plugins/wp-captcha-booster/wp-captcha-booster.php 550到559行

```
                        $api_call  = TECH_BANKER_SERVICES_URL . '/api/getipaddress.php?ip_address=' . $ip_address;
                        if ( ! function_exists( 'curl_init' ) ) {
                                $json_data = @file_get_contents( $api_call );  // @codingStandardsIgnoreLine.
                        } else {
                                $ch = curl_init();  // @codingStandardsIgnoreLine.
                                curl_setopt( $ch, CURLOPT_URL, $api_call );  // @codingStandardsIgnoreLine.
                                curl_setopt( $ch, CURLOPT_HTTPHEADER, array( 'Accept: application/json' ) );  // @codingStandardsIgnoreLine.
                                curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, 5 );  // @codingStandardsIgnoreLine.
                                curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );  // @codingStandardsIgnoreLine.
                                curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, false );  // @codingStandardsIgnoreLine.

```

上述代码中TECH\_BANKER\_SERVICES\_URL的常量的值为https://tech-banker-services.org

我发现，不知什么原因https://tech-banker-services.org已经不可用了，这导致这几行代码执行将不会成功。 而一开始我没有安装php-curl，这样，wordpress就会执行

```
$json_data = @file_get_contents( $api_call );  // @codingStandardsIgnoreLine.

```

所以这就导致wordpress会卡在这一行代码非常久，nginx也就无法及时获得数据，从而超时报504 Gateway Timeout了。

我现在临时的解决办法如下 首先安装php5-curl

```
> apt-get install php5-curl

```

接下来将

```
curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, 5 );

```

改为

```
curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, 1 );

```

这样子，wordpress执行的时候，只会被卡1秒了。
