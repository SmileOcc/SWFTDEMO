
//
//  ZFCommunityMessageCountApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessageCountApi.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityMessageCountApi () {
    NSString *_userid;
}

@end

@implementation ZFCommunityMessageCountApi
- (instancetype)initWithUserid:(NSString *)userid{
    self = [super init];
    if (self) {
        _userid = userid;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
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
             @"site"        : @"ZZZZZcommunity",
             @"type"        : @"9",
             @"directory"   : @"59",
             @"app_type"    : @"2",
             @"user_id"     : ZFToString(_userid)
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
