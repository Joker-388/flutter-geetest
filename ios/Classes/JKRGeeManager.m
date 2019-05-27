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

- (void)launchGeetestWithApi1:(NSString *)api1 api2:(NSString *)api2 challenge:(NSString *)challenge gt:(NSString *)gt success:(NSNumber *)success result:(nonnull FlutterResult)result{
    if (!api1.length && (!challenge.length || !gt.length || success.integerValue == -1)) {
        result([self dataToJsonString:@{@"msg":@"params error"}]);
        return;
    }
    _result = result;
    self.customRegisterAPI = !api1.length;
    self.customSecondaryValidate = !api2.length;
    [self initGeeManagerWithApi1:api1 api2:api2];
    if (!api1.length) {
        [self configGeeTestWithPublic_key:gt challenge:challenge success_code:success api2:api2];
    }
    [self.manager startGTCaptchaWithAnimated:YES];
}

- (void)initGeeManagerWithApi1:(NSString *)api1 api2:(NSString *)api2 {
    self.manager = [[GT3CaptchaManager alloc] initWithAPI1:api1 ? api1 : @"" API2:api2 ? api2 : @"" timeout:8];
    self.manager.delegate = self;
    [self.manager registerCaptcha:nil];
}

- (void)configGeeTestWithPublic_key:(NSString *)public_key challenge:(NSString *)challenge success_code:(NSNumber *)success_code api2:(NSString *)api2 {
    [self.manager configureGTest:public_key challenge:challenge success:[NSNumber numberWithInteger:success_code.integerValue] withAPI2:api2 ? api2 : @""];
}

- (BOOL)shouldUseDefaultRegisterAPI:(GT3CaptchaManager *)manager {
    return !self.customRegisterAPI;
}

- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager {
    return !self.customSecondaryValidate;
}

- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    if(_result) _result([self dataToJsonString:@{@"msg":@"user close gtview and cancel"}]);
    _result = nil;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    if(_result) _result([self dataToJsonString:@{@"msg":[NSString stringWithFormat:@"gaptcha error:%zd %@", error.code, error.localizedDescription]}]);
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
        if(_result) _result([self dataToJsonString:@{
                                                     @"data":@{
                                                             @"geetest_challenge":result[@"geetest_challenge"],
                                                             @"geetest_seccode":result[@"geetest_seccode"],
                                                             @"geetest_validate":result[@"geetest_validate"]
                                                             }
                                                     }]);
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
            if(_result) _result([self dataToJsonString:@{@"data":dict}]);
            _result = nil;
        } else {
            decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
            if(_result) _result([self dataToJsonString:@{@"msg":[NSString stringWithFormat:@"gaptcha error:%zd %@ data:%@", error.code, error.localizedDescription, dict]}]);
            
            _result = nil;
        }
    } else {
        decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        if(_result) _result([self dataToJsonString:@{@"msg":[NSString stringWithFormat:@"gaptcha error:%zd %@", error.code, error.localizedDescription]}]);
        _result = nil;
    }
}

- (NSString*)dataToJsonString:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
