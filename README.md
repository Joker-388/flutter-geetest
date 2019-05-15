# flutter_geetest

可以在flutter上面使用极验行为验证框架

## 集成

```dart
dependencies:
  flutter_geetest:
    git: https://github.com/Joker-388/flutter-geetest.git
```

## 接口

```dart
// 初始化极验
Future initGeeTest();
// 配置极验，传入自行通过服务器的api接口获取的配置数据对极验进行配置
Future configureGeeTest(String gt_public_key, String gt_challenge, String gt_success_code);
// 开始行为验证，调用极验界面，回调需要向服务器进行二次验证的数据
Future<dynamic> startGTCaptcha(bool animation);
```

## 行为验证步骤

行为验证需要极验服务器和自己服务器同步进行，客户端需要做的就是首先通过initGeeTest方法初始化客户端本地的极验框架，然后请求服务器的api1接口，获取到gt_public_key、gt_challenge、gt_success_code三个字段的数据。

然后通过通过这三个字段调用configureGeeTest方法配置极验，调用startGTCaptcha方法开始验证，通过这个方法返回的参数，调用服务器的api2接口，通过与服务器约定的回调数据来判定验证是否通过。

## 完整使用步骤事例

1.初始化极验
```dart
await FlutterGeetest.initGeeTest();
```
2.调用自己服务器的api1接口
```dart
var httpClient = HttpClient();
// 后台的api1接口，请求url和方式看后台怎么定
var request = await httpClient.getUrl(Uri.parse('http://www.geetest.com/demo/gt/register-slide'));var response = await request.close();
var responseBody = await response.transform(Utf8Decoder()).join();
Map responseData = json.decode(responseBody);
```
3.利用将api1接口返回的配置极验
```dart
// 取决于自己后台服务器api1接口的数据格式
if (responseData['success'] != 1) {
	print('api1验证未通过');
    return;
} 
await FlutterGeetest.configureGeeTest(responseData['gt'], responseData['challenge'], responseData['success'].toString());
```
4.调用极验验证界面开始验证
```dart
Map<dynamic, dynamic> api2Data = await FlutterGeetest.startGTCaptcha(true);
```
5.startGTCaptcha接口返回需要向服务器的api2接口传递的参数，调用api2接口验证
```dart
String bodyString = "";
api2Data.forEach((dynamic key, dynamic value) {
    bodyString += "$key=$value&";
});
var httpClient = HttpClient();
// 自己后台的接口api2，请求URL和请求参数设定取决于服务器
var request = await httpClient.postUrl(Uri.parse('http://www.geetest.com/demo/gt/validate-slide'));
request.headers.set('content-type', 'application/x-www-form-urlencoded');
request.add(utf8.encode(bodyString));
var response = await request.close();
var responseBody = await response.transform(Utf8Decoder()).join();
Map responseData = json.decode(responseBody);
// 这里的验证条件和返回的数据格式取决于自己的后台服务器
if (responseData['status'] == 'success') {
    print('验证成功');
} else {
    print('验证失败');
}
```

