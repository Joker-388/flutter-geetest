#import "FlutterGeetestPlugin.h"
#import "JKRGeeManager.h"

@interface FlutterGeetestPlugin ()

@end

@implementation FlutterGeetestPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_geetest"
            binaryMessenger:[registrar messenger]];
  FlutterGeetestPlugin* instance = [[FlutterGeetestPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      [[JKRGeeManager sharedManager] geetestVersionWithResult:result];
  } else if ([@"launchGeetest" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      [[JKRGeeManager sharedManager] launchGeetestWithApi1:arguments[@"api1"] api2:arguments[@"api2"] challenge:arguments[@"challenge"] gt:arguments[@"gt"] success:arguments[@"success"] result:result];
  }
//  else if([@"initGeeTest" isEqualToString:call.method]) {
//      NSDictionary *arguments = [call arguments];
//      [[JKRGeeManager sharedManager] initGeeManagerWithApi1:arguments[@"api1"] api2:arguments[@"api2"]  customRegisterAPI:[arguments[@"customRegisterAPI"] boolValue]  customSecondaryValidate:[arguments[@"customSecondaryValidate"] boolValue]  result:result];
//  }  else if([@"configureGeeTest" isEqualToString:call.method]) {
//      NSDictionary *arguments = [call arguments];
//      [[JKRGeeManager sharedManager] configGeeTestWithPublic_key:arguments[@"public_key"] challenge:arguments[@"challenge"] success_code:arguments[@"success_code"] api2:arguments[@"api2"] result:result];
//  } else if([@"startGTCaptcha" isEqualToString:call.method]) {
//      NSDictionary *arguments = [call arguments];
//      [[JKRGeeManager sharedManager] startGTCaptchaWithAnimated:[arguments[@"animation"] boolValue] result:result];
//  } else {
//    result(FlutterMethodNotImplemented);
//  }
}

@end
