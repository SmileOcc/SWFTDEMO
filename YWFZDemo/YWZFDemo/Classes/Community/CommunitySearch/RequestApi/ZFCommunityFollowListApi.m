//
//  ZFCommunityFollowListApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFollowListApi.h"
#import "Constants.h"

@interface ZFCommunityFollowListApi ()  {
    NSString *_curPage;
    NSString *_userId;
    ZFUserListType _userListType;
    
}
@end

@implementation ZFCommunityFollowListApi

- (instancetype)initWithCurPage:(NSString *)curPage userListType:(ZFUserListType)userListType userId:(NSString *)userId
{
    if (self = [super init]) {
        _curPage = curPage;
        _userId = userId;
        _userListType = userListType;
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
             @"directory"   : @"37",
             @"site"        : @"ZZZZZcommunity",
             @"followType"  : @(_userListType),
             @"userId"      : _userId,
             @"loginUserId" : USERID,
             @"pageSize"    : @"15",
             @"curPage"     : _curPage,
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
