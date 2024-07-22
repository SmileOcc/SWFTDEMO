//
//  FBLoginApi.m
//  ZZZZZ
//
//  Created by YW on 17/3/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "FBLoginApi.h"
#import "NSStringUtils.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation FBLoginApi
{
    NSMutableDictionary *_dict;
}

- (instancetype)initWithDict:(NSMutableDictionary *)dict{
    self = [super init];
    if (self) {
        _dict = dict;
    }
    return self;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [NSStringUtils buildRequestPath:@""];
}

- (id)requestParameters {
    return @{
             @"action"       : @"user/facebookLogin",
             @"sess_id"      : SESSIONID,
             @"fbuid"        : NullFilter(_dict[@"fb_id"]),
             @"email"        : NullFilter(_dict[@"email"]),
             @"sex"          : NullFilter(_dict[@"sex"]),
             @"access_token" : NullFilter(_dict[@"access_token"]),
             @"nickname"     : NullFilter(_dict[@"nickname"]),
             @"wj_linkid"    : [NSStringUtils getLkid],
             @"is_enc"       :  @"0",
             @"af_uid"       : ZFToString([AppsFlyerTracker sharedTracker].getAppsFlyerUID),
             @"birthday"     : _dict[@"birthday"],
             @"source"       : ZFToString(_dict[@"source"]),
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}



@end
