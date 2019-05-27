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
  
    /// 启动极验 <br></br>
    /// String [api1]: api1,SDK代处理的第一次验证接口 <br></br>
    /// String [api2]: api2,SDK代处理的第二次验证接口 <br></br>
    /// String [gt]: gt，自行处理api1获取的参数 <br></br>
    /// String [challenge]: challenge，自行处理api1获取的参数 <br></br>
    /// String [success]: success，自行处理api1获取的参数 <br></br>
    /// <br></br>
    /// {"msg":"xxxx", data:{"xxx":"xxx"}};
  
    static Future<Map<String, dynamic>> launchGeetest({String api1 = "", String api2 = "", String gt = "", String challenge = "", int success = -1}) async {
  
      var result = await _channel.invokeMethod('launchGeetest', {
        'api1': api1,
        'api2': api2,
        'gt': gt,
        'challenge': challenge,
        'success': success,
      });
      return json.decode(result);
    }
  
```

## 获取极验sdk版本

```dart
var version = await FlutterGeetest.skdVersion();
print("Geetest version $version");
```

## 使用极验默认验证

```dart
  /// api1+api2
  void _launchGeetest3() {
    FlutterGeetest.launchGeetest(
      api1: 'https://www.geetest.com/demo/gt/register-slide',
      api2: 'https://www.geetest.com/demo/gt/validate-slide',
    ).then((data) {
      print('Flutter_GeetestPlugin: data====>$data');
      if (data["data"] == null) {
        String errormsg = data["msg"];
        _showSnackbarMsg('$errormsg');
        return;
      }
      var result = data["data"];
      _showSnackbarMsg('$result');
    });
  }
```

## 自定义 注册步骤，使用默认二次验证

```dart
  /// api1结果参数+api2
  void _launchGeetest4() {
    api1().then((data){
      FlutterGeetest.launchGeetest(
        gt: data['gt'],
        challenge: data['challenge'],
        success: data['success'],
        api2: 'https://www.geetest.com/demo/gt/validate-slide',
      ).then((data) {
        print('Flutter_GeetestPlugin: data====>$data');
        if (data["data"] == null) {
          String errormsg = data["msg"];
          _showSnackbarMsg('$errormsg');
          return;
        }
        var result = data["data"];
        _showSnackbarMsg('$result');
      });
    });
  }
```

## 自定义 二次验证，使用默认注册步骤

```dart
  /// 仅api1 , 返回结果自行进行二次接口校验
  void _launchGeetest1() {
    FlutterGeetest.launchGeetest(
      api1: 'https://www.geetest.com/demo/gt/register-slide',
    ).then((data) {
      print('Flutter_GeetestPlugin: data====>$data');
      if (data["data"] == null) {
        String errormsg = data["msg"];
        _showSnackbarMsg('$errormsg');
        return;
      }
      api2(data["data"]).then((data){
        print("api2: $data");
        _showSnackbarMsg('$data');
      });
    });
  }
```

## 自定义 注册 和 二次验证

```dart
  /// 仅api1结果参数(gt,challenge,success),参数来自于自行接口获取
  void _launchGeetest2() {
    api1().then((data){
      print("!!!!! $data");
      FlutterGeetest.launchGeetest(
        gt: data['gt'],
        challenge: data['challenge'],
        success: data['success'],
      ).then((data) {
        print('Flutter_GeetestPlugin: data====>$data');
        if (data["data"] == null) {
          String errormsg = data["msg"];
          _showSnackbarMsg('$errormsg');
          return;
        }
        api2(data["data"]).then((data){
          print("api2: $data");
          _showSnackbarMsg('$data');
        });
      });
    });
  }
```