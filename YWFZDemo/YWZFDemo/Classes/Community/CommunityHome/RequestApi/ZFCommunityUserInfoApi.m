


//
//  ZFCommunityUserInfoApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityUserInfoApi.h"
#import "Constants.h"

@interface ZFCommunityUserInfoApi () {
    NSString *_userid;
}

@end

@implementation ZFCommunityUserInfoApi
- (instancetype)initWithUserid:(NSString *)userid {
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
             @"app_type": @"2",
             @"site" : @"ZZZZZcommunity" ,
             @"type" : @"9",
             @"directory" : @"34",
             @"userId" : _userid ?: @"0",
             @"loginId" : USERID
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
