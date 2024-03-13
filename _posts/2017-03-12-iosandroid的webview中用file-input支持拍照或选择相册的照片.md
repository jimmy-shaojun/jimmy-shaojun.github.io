---
layout: page_with_comment
title: "iOS/Android的WebView中用file input支持拍照或选择相册的照片"
date: "2017-03-12"
categories: 
  - "android"
  - "ios"
tags: 
  - "android"
  - "camera"
  - "ios"
  - "webview"
  - "相机"
---

如果我们的一个移动端的网页需要让用户上传一张照片，那么，通常而言，我们可以写了以下一段HTML代码

```
<input type='file' />

```

那么Mobile Web界面将会显示下面的一个控件，通过该控件，用户可以拍照或者选择手机中的文件而上传。

在iOS下，Mobile Safari会在你点击上面的控件之后弹出如下界面 [![Screen Shot 2017-03-12 at 下午6.44.31](/images/Screen-Shot-2017-03-12-at-下午6.44.31-1.png)](/images/Screen-Shot-2017-03-12-at-下午6.44.31-1.png)

在Android系统下，弹出的界面根据具体的Android版本（不同的厂商定制版本、不同的Android系统版本）不同而略有不同，不过，通常也会提供相机，相册等选项。下图为小米手机的例子。 [![IMG_20170312_184934](/images/IMG_20170312_184934.jpg)](/images/IMG_20170312_184934.jpg)

然而，如果你在原生的应用中内嵌了一个UIWebView/WKWebView（iOS）或者WebView（Android），你就会发现，原来在Mobile Safari和Chrome中可以正常运行的代码很有可能不能正常工作了。

在iOS系统下，你会发现，如果UIWebView所在的View Controller是通过presentViewController展示的，那么，你会发现，用户点击  后，你的iOS应用会出现一些奇怪的问题，如应用崩溃，如你在相册选择了照片之后，UIWebView所在的View Controller不见了，等等。

最后，我的解决方法是，不通过presentViewController展示UIWebView所在的View Controller，而是通过UINavigationController的pushViewController去展示View Controller。

而对于Android系统，应用内嵌的WebView本来就不支持使用文件上传功能，所以，<input type='file' />在Mobile Chrome上有效，到了应用内嵌的WebView中就无效了。

在Android上，我的解决方法是这样的，通过WebView的addJavascriptInterface注入一个camera对象，让WebView中的js代码通过camera对象从而唤起相机或者相册。

> webView.addJavascriptInterface(new DemoJavaScriptInterface(), "demo");

Javascript代码

> window.demo.camera();

假设DemoJavaScriptInterface的是位于WebViewActivity里面的一个内部类，且WebViewActivity有一个私有变量String mCameraPhotoPath，那么，DemoJavaScriptInterface代码如下

```
 final class DemoJavaScriptInterface {
        DemoJavaScriptInterface() {
        }

        @JavascriptInterface
        public void camera() {

                Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
                    // Create the File where the photo should go
                    File photoFile = null;
                    try {
                        photoFile = createImageFile();
                        takePictureIntent.putExtra("PhotoPath", mCameraPhotoPath);
                    } catch (Exception ex) {
                        // Error occurred while creating the File
                        Log.e("WebViewSetting", "Unable to create Image File", ex);
                    }

                    // Continue only if the File was successfully created
                    if (photoFile != null) {
                        mCameraPhotoPath = photoFile.getAbsolutePath();
                        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                                Uri.fromFile(photoFile));
                    } else {
                        takePictureIntent = null;
                    }
                }

                Intent contentSelectionIntent = new Intent(Intent.ACTION_GET_CONTENT);
                contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE);
                contentSelectionIntent.setType("image/*");

                Intent[] intentArray;
                if (takePictureIntent != null) {
                    intentArray = new Intent[]{takePictureIntent};
                } else {
                    intentArray = new Intent[0];
                }

                chooserIntent = new Intent(Intent.ACTION_CHOOSER);
                chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent);
                chooserIntent.putExtra(Intent.EXTRA_TITLE, "拍照或者选择图片");
                chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);

                Activity mContext = WebViewActivity.this;
                if (Build.VERSION.SDK_INT >= 23) {
                    int checkCallPhonePermission = ContextCompat.checkSelfPermission(mContext, Manifest.permission.CAMERA);
                    if (checkCallPhonePermission != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(mContext, new String[]{Manifest.permission.CAMERA}, REQUEST_CODE_ASK_CAMERA);
                        return;
                    }
                }

                WebViewActivity.this.startActivityForResult(chooserIntent, 101);

            }

    }

```

WebViewActivity中的onActivityResult方法代码如下

```
@Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            switch (requestCode) {
                case 101:
                    if(data == null){
                        String imageurl = mCameraPhotoPath;
                        //相机拍好的照片就保存在路径imageurl中
                    }
                    else{
                        Uri uri = data.getData();
                        //通过uri获取照片数据
                    }

                    break;

                default:
                    return;
            }
        }

    }

```
