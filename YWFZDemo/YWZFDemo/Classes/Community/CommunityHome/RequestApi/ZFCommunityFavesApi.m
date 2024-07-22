
//
//  ZFCommunityFavesApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFavesApi.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCommunityFavesApi () {
    NSInteger _currentPage;
    NSString *_listUserId;
}
@end

@implementation ZFCommunityFavesApi

- (instancetype)initWithcurrentPage:(NSInteger)currentPage listUserId:(NSString *)listUserId {
    self = [super init];
    if (self) {
        _currentPage = currentPage;
        _listUserId = listUserId;
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
             @"directory"       : @(33),
             @"site"            : @"ZZZZZcommunity",
             @"userId"          : USERID ?: @"0",
             @"listUserId"      : ZFToString(_listUserId),
             @"pageSize"        : @"15",
             @"curPage"         : @(_currentPage),
             @"app_type"  : @"2"
             };
}


- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
