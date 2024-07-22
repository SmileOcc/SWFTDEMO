//
//  ZFCommunityZegoLiveHistoryCommentApi.m
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityZegoLiveHistoryCommentApi.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityZegoLiveHistoryCommentApi () {
    NSString *_liveID;
    NSString * _curPage;
    NSString *_pageSize;
}

@end
@implementation ZFCommunityZegoLiveHistoryCommentApi

- (instancetype)initWithLiveID:(NSString *)liveID page:(NSString *)curPage pageSize:(NSString *)pageSize{
    if (self = [super init]) {
        _liveID = liveID;
        _curPage = curPage;
        _pageSize = pageSize;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
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

- (BOOL)isCommunityLiveRequest {
    return YES;
}


- (id)requestParameters {
    
    return @{
             @"site"           : @"ZZZZZ" ,
             @"loginUserId"    : USERID ?: @"0",
             @"app_type"       : @"2",
             @"id"             : ZFToString(_liveID),
             @"pageSize"       : ZFToString(_pageSize),
             @"page"        : ZFToString(_curPage),
             @"version"        : ZFToString(ZFSYSTEM_VERSION),
             @"token"          : ZFToString(TOKEN),
             @"lang"           : [ZFLocalizationString shareLocalizable].nomarLocalizable,
             @"device"         : ZFToString([AccountManager sharedManager].device_id),
             @"orderBy"        :@"asc",
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

- (NSString *)baseURL {
    return [self communityLiveURLAppendPublicArgument:Community_Live_API(@"api/live/video-message")];
}
@end
