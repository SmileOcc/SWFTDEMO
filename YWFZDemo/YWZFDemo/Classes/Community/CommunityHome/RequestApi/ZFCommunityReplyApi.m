


//
//  ZFCommunityReplyApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityReplyApi.h"
#import "AccountManager.h"
#import "Constants.h"

@interface ZFCommunityReplyApi () {
    NSDictionary *_dict;
}

@end

@implementation ZFCommunityReplyApi
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
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
             @"type"        : @"10",
             @"loginUserId" : USERID ?: @"0",
             @"reviewId"    : _dict[@"reviewId"],
             @"content"     : _dict[@"content"],
             @"replyId"     : _dict[@"replyId"],
             @"replyUserId" : _dict[@"replyUserId"],
             @"isSecondFloorReply" : _dict[@"isSecondFloorReply"],
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
