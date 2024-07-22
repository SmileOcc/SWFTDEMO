

//
//  ZFCommunityDeleteApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityDeleteApi.h"
#import "Constants.h"

@interface ZFCommunityDeleteApi () {
    NSString *_deleteId;
    NSString *_userId;
}

@end

@implementation ZFCommunityDeleteApi

- (instancetype)initWithDeleteId:(NSString *)deleteId andUserId:(NSString *)userId
{
    if (self = [super init]) {
        _deleteId = deleteId;
        _userId = userId;
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
             @"type"        : @"9",
             @"site"        : @"ZZZZZcommunity",
             @"directory"   : @"55",
             @"userId"      : _userId ?: @"0",
             @"loginUserId" : USERID ?: @"0",
             @"isDelete"    : @"1",
             @"reviewId"    : _deleteId,
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
