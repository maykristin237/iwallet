#可以加入 -dontwarn 语句对第三方库进行报错屏蔽
#-dontwarn io.flutter.**

#-keep class io.flutter.app.** { *; }
#-keep class io.flutter.plugin.**  { *; }
#-keep class io.flutter.util.**  { *; }
#-keep class io.flutter.view.**  { *; }
#-keep class io.flutter.**  { *; }
#-keep class io.flutter.plugins.**  { *; }
#-keep class com.wk.wallet_kit.**  { *; }

-keep class org.bitcoinj.**  { *; }
-keep class org.consenlabs.tokencore.**  { *; }
-keep class com.sevenblock.walletsdk.**  { *; }
-keep class com.sevenblock.hardware_lib.**  { *; }
#-keep class com.umeng.** {*;}
# -keep class com.google.firebase.** { *; } // uncomment this if you are using firebase in the project -dontwarn io.flutter.embedding.** -ignorewarnings

-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}