
//
//  ZFCommunityStyleShowsApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityStyleShowsApi.h"
#import "Constants.h"

@interface ZFCommunityStyleShowsApi (){
    NSString *_userid;
    NSInteger _currentPage;
}

@end

@implementation ZFCommunityStyleShowsApi

- (instancetype)initWithUserid:(NSString *)userid currentPage:(NSInteger)currentPage {
    self = [super init];
    if (self) {
        _userid = userid ?: @"0";
        _currentPage = currentPage;
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
             @"site" : @"ZZZZZcommunity" ,
             @"type" : @"9",
             @"directory" : @"28",
             @"userId" : USERID,
             @"listUserId" : _userid,
             @"curPage" : @(_currentPage),
             @"pageSize" : @"15",
             @"app_type"    : @"2"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
