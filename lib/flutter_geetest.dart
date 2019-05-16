import 'dart:async';
import 'package:flutter/services.dart';

class FlutterGeetest {
  static const MethodChannel _channel =
      const MethodChannel('flutter_geetest');

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

}

