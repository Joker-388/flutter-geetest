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
      if (responseData['success'] == 1) {
        return responseData;
      } else {
        return null;
      }
    }

    Future<dynamic> configGeeTest(Map<String, dynamic> data) async{
      await FlutterGeetest.configureGeeTest(data['gt'], data['challenge'], data['success'].toString());
    }

    Future<dynamic> startGeeTest() async {
      var api2Data = await FlutterGeetest.startGTCaptcha(true);
      return api2Data;
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
      print(responseData);
      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    }

    void geeTest() async {
      print('初始化极验');
      await FlutterGeetest.initGeeTest();

      print('请求自己服务器的api1接口');
      Map<String, dynamic> api1Result = await api1();
      print("api1回调参数: $api1Result");
      if (api1Result == null) {
        print('验证失败！api1未通过');
        return;
      }

      print('用api返回参数配置极验');
      await configGeeTest(api1Result);

      print('极验验证');
      Map<dynamic, dynamic> api2Data = await startGeeTest();
      print('极验返回api2需要的基本参数 $api2Data');

      if (api2Data == null) {
        print('验证失败！行为验证未通过');
        return;
      }
      print('请求自己服务器的api2接口');
      bool success = await api2(api2Data);

      if (success) {
        print('验证成功！');
      } else {
        print('验证失败！api2未通过');
      }
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          //Text('Running on: $_platformVersion\n')
          child: FlatButton(onPressed: geeTest, child: Icon(Icons.add)),
        ),
      ),
    );
  }
}
