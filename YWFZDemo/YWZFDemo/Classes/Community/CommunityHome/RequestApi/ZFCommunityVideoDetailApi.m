
//
//  ZFCommunityVideoDetailApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoDetailApi.h"
#import "Constants.h"

@interface ZFCommunityVideoDetailApi ()  {
    NSString *_videoId;
}

@end

@implementation ZFCommunityVideoDetailApi
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
             @"loginUserId" : USERID ?: @"0",
             @"id" : _videoId,
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
