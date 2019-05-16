//
//  JKRGeeManager.h
//  flutter_geetest
//
//  Created by Joker on 2019/5/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKRGeeManager : NSObject

+ (instancetype)sharedManager;

- (void)geetestVersionWithResult:(FlutterResult)result;
- (void)initGeeManagerWithApi1:(NSString *)api1 api2:(NSString *)api2 customRegisterAPI:(BOOL)customRegisterAPI customSecondaryValidate:(BOOL)customSecondaryValidate result:(FlutterResult)result;
- (void)configGeeTestWithPublic_key:(NSString *)public_key challenge:(NSString *)challenge success_code:(NSString *)success_code api2:(NSString *)api2 result:(FlutterResult)result;
- (void)startGTCaptchaWithAnimated:(BOOL)animated result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
