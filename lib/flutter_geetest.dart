import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class FlutterGeetest {
  static const MethodChannel _channel = const MethodChannel('flutter_geetest');

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
}
