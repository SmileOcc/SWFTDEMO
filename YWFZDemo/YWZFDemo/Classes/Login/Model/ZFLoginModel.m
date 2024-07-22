//
//  YWLoginModel.m
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginModel.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"

@implementation YWLoginModel


- (BOOL)isCountryEU {
    //根据国家ip来判断,  country_eu : 0         1 欧盟字段标识
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    NSString *country_eu = ZFToString(initializeModel.country_eu);
    return [country_eu boolValue];
}

- (NSString *)register_ad {
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    return initializeModel.copywriting.registerStr;
}

- (NSString *)login_ad {
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    return initializeModel.copywriting.login;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}


@end
