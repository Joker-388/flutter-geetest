import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_geetest/flutter_geetest.dart';
import 'dart:io';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Future<dynamic> api1() async {
      var httpClient = HttpClient();
      var request = await httpClient.getUrl(Uri.parse('http://www.geetest.com/demo/gt/register-slide'));
      var response = await request.close();
      var responseBody = await response.transform(Utf8Decoder()).join();
      Map responseData = json.decode(responseBody);
      return responseData;
    }

    Future<dynamic> api2(Map<dynamic, dynamic> data) async {
      String bodyString = "";
      data.forEach((dynamic key, dynamic value) {
        bodyString += "$key=$value&";
      });
      var httpClient = HttpClient();
      var request = await httpClient.postUrl(Uri.parse('http://www.geetest.com/demo/gt/validate-slide'));
      request.headers.set('content-type', 'application/x-www-form-urlencoded');
      request.add(utf8.encode(bodyString));
      var response = await request.close();
      var responseBody = await response.transform(Utf8Decoder()).join();
      print(responseBody);
      Map responseData = json.decode(responseBody);
      return(responseData);
    }

    // 自定义 注册 和 二次验证
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

    // 自定义 二次验证
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

    // 自定义 注册步骤
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

    // 使用极验默认验证
    void geeTestDefault() async {
      var version = await FlutterGeetest.skdVersion();
      print("Geetest version $version");
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

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(onPressed: geeTestDefault, child: Icon(Icons.add)),
        ),
      ),
    );
  }
}
