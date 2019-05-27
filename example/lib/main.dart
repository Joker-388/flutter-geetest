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

  Future<dynamic> api1() async {
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse('https://www.geetest.com/demo/gt/register-slide'));
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
    var request = await httpClient.postUrl(Uri.parse('https://www.geetest.com/demo/gt/validate-slide'));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.add(utf8.encode(bodyString));
    var response = await request.close();
    var responseBody = await response.transform(Utf8Decoder()).join();
    print(responseBody);
    Map responseData = json.decode(responseBody);
    return (responseData);
  }

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

  /// show SDK version
  void _showSDKVersion() {
    FlutterGeetest.skdVersion().then((version) {
      _showSnackbarMsg('SDK_Version: $version');
    });
  }

  void _showSnackbarMsg(String msg) {
    _k.currentState.showSnackBar(SnackBar(content: Text(msg, style: TextStyle(fontSize: 16))));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          key: _k,
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Container(width: double.infinity, child: RaisedButton(onPressed: _showSDKVersion, child: Text('Version'))),
                Container(width: double.infinity, child: RaisedButton(onPressed: _launchGeetest1, child: Text('仅api1'))),
                Container(width: double.infinity, child: RaisedButton(onPressed: _launchGeetest2, child: Text('仅api1结果参数(gt,challenge,success)'))),
                Container(width: double.infinity, child: RaisedButton(onPressed: _launchGeetest3, child: Text('api1+api2'))),
                Container(width: double.infinity, child: RaisedButton(onPressed: _launchGeetest4, child: Text('api1结果参数+api2'))),
              ],
            ),
          )),
    );
  }

  GlobalKey<ScaffoldState> _k = GlobalKey<ScaffoldState>();
}