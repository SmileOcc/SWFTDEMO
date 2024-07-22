//
//  ZFCommunityOutfitsApi.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitsApi.h"
#import "Constants.h"

@interface ZFCommunityOutfitsApi () {
    NSInteger _currentPage;
}

@end

@implementation ZFCommunityOutfitsApi
- (instancetype)initWithcurrentPage:(NSInteger)currentPage {
    self = [super init];
    if (self) {
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
             @"type"            : @(9),
             @"directory"       : @(60),
             @"site"            : @"ZZZZZcommunity",
             @"userId"          : USERID ?: @"0",
             @"size"            : @"10",
             @"page"            : @(_currentPage),
             @"app_type"        : @"2"
             };
}


- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
