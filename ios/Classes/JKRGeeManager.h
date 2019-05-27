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
- (void)launchGeetestWithApi1:(NSString *)api1 api2:(NSString *)api2 challenge:(NSString *)challenge gt:(NSString *)gt success:(NSNumber *)success result:(FlutterResult)result;;

@end

NS_ASSUME_NONNULL_END
