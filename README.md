# flutter_geetest

可以在flutter上面使用极验行为验证框架，支持原生极验的自定义配置功能，支持自定义api1步骤、api2步骤、全部使用极验默认流程三种方式。

[![preview](https://github.com/Joker-388/flutter-geetest/blob/master/geetest.gif)](http://www.jianshu.com/u/95d5ea0acd19)&nbsp;

## 集成

```dart
dependencies:
  flutter_geetest:
    git: https://github.com/Joker-388/flutter-geetest.git
```

## 接口

```dart
  /// 极验sdk版本
  static Future<String> skdVersion() async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  
   /// 初始化极验
   /// String [api1]: 注册接口，如果自定义注册步骤，可以忽略，否则必须传。
   /// String [api2]: 二次验证接口，如果自定义二次验证步骤，可以忽略，否则必须传。
   /// bool [customRegisterAPI]: 默认true，是否自定义注册步骤。如果需要使用极验默认的注册步骤，必须传false。
   /// bool [customSecondaryValidate]:  默认true，是否自定义二次验证步骤。如果需要使用极验默认的二次验证步骤，必须传false。
  static Future<bool> initGeeTest({String api1 = "", String api2 = "", bool customRegisterAPI = true, bool customSecondaryValidate = true}) async {
    var result = await _channel.invokeMethod(
        'initGeeTest',
        {
          'api1':api1,
          'api2':api2,
          'customRegisterAPI':customRegisterAPI,
          'customSecondaryValidate':customSecondaryValidate
        }
    );
    return result;
  }

  /// 配置极验
  /// 如果自定义注册步骤，必须调用此接口，将api1接口返回的相应字段传入。
  /// String [publicKey]: 来自api1接口返回。
  /// String [challenge]: 来自api1接口返回。
  /// String [successCode]: 来自api1接口返回。
  /// String [api2]: 如果需要使用极验默认的二次验证，必须传入api2。如果使用自定义的二次验证，忽略参数。
  static Future configureGeeTest(String publicKey, String challenge, String successCode, {String api2 = ""}) async {
    var result = await _channel.invokeMethod(
        'configureGeeTest',
        {
          'public_key':publicKey,
          'challenge':challenge,
          'success_code':successCode,
          'api2':api2,
        }
    );
    return result;
  }

  /// 开始验证
  /// bool [animation]: 是否使用动画
  static Future<dynamic> startGTCaptcha({bool animation = true}) async {
    var result = await _channel.invokeMethod(
        'startGTCaptcha',
        {
          'animation':animation,
        }
    );
    return result;
  }
```

## 获取极验sdk版本

```dart
var version = await FlutterGeetest.skdVersion();
print("Geetest version $version");
```

## 使用极验默认验证

```dart
    void geeTestDefault() async {
      await FlutterGeetest.initGeeTest(api1: 'http://www.geetest.com/demo/gt/register-slide', api2: 'http://www.geetest.com/demo/gt/validate-slide', customRegisterAPI: false, customSecondaryValidate: false);
      var api2Result = await FlutterGeetest.startGTCaptcha();
      // 取决于服务器返回的数据，约定的成功字段是否满足
      print(api2Result);
      if (api2Result['status'] == 'success') {
        print("验证成功 $api2Result");
      } else {
        print('验证失败');
      }
    }
```

## 自定义 注册步骤，使用默认二次验证

```dart
    void geeTestCustomApi1() async {
      // 初始化极验
      bool initSuccess = await FlutterGeetest.initGeeTest(customSecondaryValidate: false);
      if (initSuccess == false) {
        print('初始化极验失败');
        return;
      }

      // 请求自己服务器的api1接口
      Map<String, dynamic> api1Result = await api1();
      if (api1Result['success'] != 1) {
        print('验证失败！api1未通过');
        return;
      }

      // 自定义配置极验
      bool configSuccess = await FlutterGeetest.configureGeeTest(api1Result['gt'], api1Result['challenge'], api1Result['success'].toString(), api2: 'http://www.geetest.com/demo/gt/validate-slide');
      if (configSuccess == false) {
        print('极验自定义配置失败');
        return;
      }

      var api2Result = await FlutterGeetest.startGTCaptcha();
      print(api2Result);
      if (api2Result['status'] == 'success') {
        print("验证成功 $api2Result");
      } else {
        print('验证失败！二次验证未通过');
      }
    }
```

## 自定义 二次验证，使用默认注册步骤

```dart
    void geeTestCustomApi2() async {
      // 初始化极验
      bool initSuccess = await FlutterGeetest.initGeeTest(api1: 'http://www.geetest.com/demo/gt/register-slide', customRegisterAPI: false);
      if (initSuccess == false) {
        print('初始化极验失败');
        return;
      }

      Map<dynamic, dynamic> api2Data = await FlutterGeetest.startGTCaptcha();
      print('极验返回api2需要的基本参数 $api2Data');

      if (api2Data == null) {
        print('验证失败！行为验证未通过');
        return;
      }

      // 请求自己服务器的api2接口进行二次验证
      var api2Result = await api2(api2Data);

      if (api2Result['status'] == 'success') {
        print("验证成功 $api2Result");
      } else {
        print('验证失败！二次验证未通过');
      }
    }
```

## 自定义 注册 和 二次验证

```dart
    // 自定义 一次验证 和 二次验证
    void geeTestCustomApi1AndApi2() async {
      // 初始化极验
      bool initSuccess = await FlutterGeetest.initGeeTest();
      if (initSuccess == false) {
        print('初始化极验失败');
        return;
      }

      // 请求自己服务器的api1接口
      Map<String, dynamic> api1Result = await api1();
      if (api1Result['success'] != 1) {
        print('验证失败！api1未通过');
        return;
      }

      // 自定义配置极验
      bool configSuccess = await FlutterGeetest.configureGeeTest(api1Result['gt'], api1Result['challenge'], api1Result['success'].toString(), );
      if (configSuccess == false) {
        print('极验自定义配置失败');
        return;
      }

      // 调用极验验证界面开始验证
      Map<dynamic, dynamic> api2Data = await FlutterGeetest.startGTCaptcha();
      print('极验返回api2需要的基本参数 $api2Data');

      if (api2Data == null) {
        print('验证失败！行为验证未通过');
        return;
      }

      // 请求自己服务器的api2接口进行二次验证
      var api2Result = await api2(api2Data);

      if (api2Result['status'] == 'success') {
        print("验证成功 $api2Result");
      } else {
        print('验证失败！二次验证未通过');
      }
    }
```