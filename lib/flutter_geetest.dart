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
  /// 1=>场景1处理完成回调，return {code:1} <br></br>
  /// 2=>场景2一次验证完成，回调要求进行二次验证,return {code:2,geetest_challenge:xx,geetest_seccode:xx,geetest_validate:xx} <br></br>
  /// 3=>请求出错回调,返回错误信息，return {code:3,msg:xx} <br></br>
  static Future<Map<String, dynamic>> launchGeetest({String api1 = "", String api2 = "", String gt = "", String challenge = "", int success = -1}) async {
    //场景1(代处理接口模式): api1,api2都不为空，使用SDK处理，api1请求获取json(包含gt,challenge,success)启动弹窗验证，完成后请求api2二次验证，完成后回调
    //场景2(自处理接口模式)：gt,challenge,success都不为空，SDK启动弹窗验证，完成后返回进行要求二次验证
    //场景3：api1,api2之一为空字符串，则校验场景2，场景2仍然存在空字符串，返回失败提示参数异常信息
    var result = await _channel.invokeMethod('launchGeetest', {
      'api1': api1,
      'api2': api2,
      'gt': gt,
      'challenge': challenge,
      'success': success,
    });
    return json.decode(result);
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
