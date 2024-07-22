//
//  ZFCommunityFriendsResultApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFriendsResultApi.h"
#import "Constants.h"

@interface ZFCommunityFriendsResultApi () {
    NSInteger _curPage;
    NSInteger _pageSize;
    NSString *_keyWord;
}

@end

@implementation ZFCommunityFriendsResultApi

- (instancetype)initWithkeyWord:(NSString *)keyWord andCurPage:(NSInteger)curPage pageSize:(NSInteger)pageSize {
    if (self = [super init]) {
        _curPage = curPage;
        _pageSize = pageSize;
        _keyWord = keyWord;
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
             @"site"        :   @"ZZZZZcommunity",
             @"type"        :   @"9",
             @"directory"   :   @"57",
             @"loginUserId" :   USERID,
             @"key_word"    :   _keyWord,
             @"page"        :   @(_curPage),
             @"pageSize"    :   @(_pageSize),
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

