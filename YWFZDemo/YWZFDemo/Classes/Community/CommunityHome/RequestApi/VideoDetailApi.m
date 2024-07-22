//
//  VideoDetailApi.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "VideoDetailApi.h"
#import "Constants.h"

@implementation VideoDetailApi {
    NSString *_videoId;
}

- (instancetype)initWithVideoId:(NSString *)videoId {
    self = [super init];
    if (self) {
        _videoId = videoId;
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
             @"directory" : @"52",
             @"loginUserId" : USERID,
             @"id" : _videoId,
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
