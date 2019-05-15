#import "FlutterGeetestPlugin.h"
#import <GT3Captcha/GT3Captcha.h>

@interface FlutterGeetestPlugin ()<GT3CaptchaManagerDelegate, GT3CaptchaManagerViewDelegate>

@end

@implementation FlutterGeetestPlugin {
    FlutterResult _result;
    GT3CaptchaManager *_manager;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_geetest"
            binaryMessenger:[registrar messenger]];
  FlutterGeetestPlugin* instance = [[FlutterGeetestPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"initGeeTest" isEqualToString:call.method]) {
      if (!_manager) {
          _manager = [[GT3CaptchaManager alloc] initWithAPI1:nil API2:nil timeout:8.0];
          [_manager useLanguage:GT3LANGTYPE_ZH_CN];
          _manager.delegate = self;
          _manager.viewDelegate = self;
          [_manager registerCaptcha:nil];
          [_manager useVisualViewWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
      }
      result(nil);
  }  else if([@"configureGeeTest" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      [_manager configureGTest:arguments[@"gt_public_key"] challenge:arguments[@"gt_challenge"] success:arguments[@"gt_success_code"] withAPI2:nil];
      result(nil);
  } else if([@"startGTCaptcha" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      if (!_manager) {
          result(nil);
      } else {
          _result = result;
          [_manager startGTCaptchaWithAnimated:[arguments[@"animation"] boolValue]];
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

/// 验证错误处理
- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    _result(nil);
}

/// 通知已经收到二次验证结果, 在此处理最终验证结果
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {

}

/// 用户主动关闭了验证码界面
- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    _result(nil);
}

/// 验证初始化方法
- (void)gtCaptcha:(GT3CaptchaManager *)manager willSendSecondaryCaptchaRequest:(NSURLRequest *)originalRequest withReplacedRequest:(void (^)(NSMutableURLRequest * request))replacedRequest {

}

- (BOOL)shouldUseDefaultRegisterAPI:(GT3CaptchaManager *)manager {
    return NO;
}

- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager {
    return NO;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveCaptchaCode:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if (code.integerValue == 1) {
        _result(result);
    }
}

@end
