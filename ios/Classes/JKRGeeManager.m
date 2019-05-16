//
//  JKRGeeManager.m
//  flutter_geetest
//
//  Created by Joker on 2019/5/16.
//

#import "JKRGeeManager.h"
#import <GT3Captcha/GT3Captcha.h>

@interface JKRGeeManager ()<GT3CaptchaManagerDelegate>

@property (nonatomic, strong) GT3CaptchaManager *manager;
@property (nonatomic, assign) BOOL customRegisterAPI;
@property (nonatomic, assign) BOOL customSecondaryValidate;

@end

@implementation JKRGeeManager {
    FlutterResult _result;
}

+ (instancetype)sharedManager {
    static JKRGeeManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JKRGeeManager alloc] init];
    });
    return instance;
}

- (void)geetestVersionWithResult:(FlutterResult)result {
    NSString *version = [NSString stringWithFormat:@"%@", [GT3CaptchaManager sdkVersion]];
    result(version);
}

- (void)initGeeManagerWithApi1:(NSString *)api1 api2:(NSString *)api2 customRegisterAPI:(BOOL)customRegisterAPI customSecondaryValidate:(BOOL)customSecondaryValidate result:(FlutterResult)result{
    self.manager = [[GT3CaptchaManager alloc] initWithAPI1:api1 ? api1 : @"" API2:api2 ? api2 : @"" timeout:8];
    self.manager.delegate = self;
    [self.manager registerCaptcha:nil];
    self.customRegisterAPI = customRegisterAPI;
    self.customSecondaryValidate = customSecondaryValidate;
    if (self.manager) {
        result(@YES);
    } else {
        result(@NO);
    }
}

- (void)configGeeTestWithPublic_key:(NSString *)public_key challenge:(NSString *)challenge success_code:(NSString *)success_code api2:(NSString *)api2 result:(FlutterResult)result {
    if (![self checkIfInitManagerWithResult:result]) return;
    [self.manager configureGTest:public_key challenge:challenge success:[NSNumber numberWithInteger:success_code.integerValue] withAPI2:api2 ? api2 : @""];
    result(@YES);
}

- (void)startGTCaptchaWithAnimated:(BOOL)animated result:(FlutterResult)result {
    if (![self checkIfInitManagerWithResult:result]) return;
    [self.manager startGTCaptchaWithAnimated:animated];
    _result = result;
}

- (BOOL)checkIfInitManagerWithResult:(FlutterResult)result{
    if (!self.manager) {
        result(@NO);
        return NO;
    }
    return YES;
}

- (BOOL)shouldUseDefaultRegisterAPI:(GT3CaptchaManager *)manager {
    return !self.customRegisterAPI;
}

- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager {
    return !self.customSecondaryValidate;
}

- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    if(_result) _result(nil);
    _result = nil;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    if(_result) _result(nil);
    _result = nil;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveCaptchaCode:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    // 自定义api1，不自定义api2的时候，不需要在这里拦截
    if (self.customRegisterAPI && !self.customSecondaryValidate) {
        return;
    }
    // 不自定义的时候不需要在这里拦截
    if (!self.customRegisterAPI && !self.customSecondaryValidate) {
        return;
    }
    // 不自定义api1，自定义api2的时候，这里需要拦截，全部都自定义的时候，这里也需要拦截
    if (code.integerValue == 1) {
        [self.manager closeGTViewIfIsOpen];
        if(_result) _result(result);
        _result = nil;
    }
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    if (!error) {
        [self.manager closeGTViewIfIsOpen];
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
        if (!err) {
            decisionHandler(GT3SecondaryCaptchaPolicyAllow);
            if(_result) _result(dict);
            _result = nil;
        } else {
            decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
            if(_result) _result(nil);
            _result = nil;
        }
    } else {
        decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        if(_result) _result(nil);
        _result = nil;
    }
}

@end
