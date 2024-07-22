//
//  ZFCommunityCheckCommissionApi.m
//  ZZZZZ
//
//  Created by YW on 2018/9/19.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityCheckCommissionApi.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation ZFCommunityCheckCommissionApi


- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

-(BOOL)encryption {
    return YES;
}

-(BOOL)isCommunityRequest{
    return YES;
}

- (id)requestParameters {
    return @{
             @"type"           : @"9",
             @"app_type"       : @"2",
             @"site"           : @"ZZZZZcommunity",
             @"loginUserId"    : USERID ?: @"0",
             @"directory"      : @"1",
             @"version"        : ZFToString(ZFSYSTEM_VERSION),
             @"token"          : ZFToString(TOKEN),
             @"lang"           : [ZFLocalizationString shareLocalizable].nomarLocalizable
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
