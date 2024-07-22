//
//  CommunityReplyApi.m
//  Yoshop
//
//  Created by YW on 16/7/18.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "CommunityReplyApi.h"
#import "Constants.h"

@implementation CommunityReplyApi {
    NSDictionary *_dict;
}

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
    return NO;
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

             @"site" : @"ZZZZZcommunity",
             @"type" : @"10",
             @"loginUserId" : USERID,
             
             @"reviewId" : _dict[@"reviewId"] ?: @"",
             @"content" : _dict[@"content"] ?: @"",
             @"replyId" : _dict[@"replyId"] ?: @"",
             @"replyUserId" : _dict[@"replyUserId"] ?: @"0",
             @"isSecondFloorReply" : _dict[@"isSecondFloorReply"] ?: @"",
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
