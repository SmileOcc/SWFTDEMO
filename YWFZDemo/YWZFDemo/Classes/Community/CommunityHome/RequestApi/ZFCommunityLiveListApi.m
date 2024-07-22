//
//  ZFCommunityLiveListApi.m
//  ZZZZZ
//
//  Created by YW on 2019/4/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveListApi.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

@interface ZFCommunityLiveListApi () {
    NSInteger _page;//当前页
    NSInteger _size;//每页显示数量
}

@end

@implementation ZFCommunityLiveListApi

- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSInteger)pageSize{
    if (self = [super init]) {
        _page = curPage;
        _size = pageSize;
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

- (BOOL)isCommunityLiveRequest {
    return YES;
}


- (id)requestParameters {
    
    return @{
             @"site"           : @"ZZZZZ" ,
//             @"type"           : @"9",
//             @"directory"      : @"78",
             @"loginUserId"    : USERID ?: @"0",
             @"app_type"       : @"2",
             @"page"           : @(_page),
             @"pageSize"      : @(_size),
             @"version"        : ZFToString(ZFSYSTEM_VERSION),
             @"token"          : ZFToString(TOKEN),
             @"lang"           : [ZFLocalizationString shareLocalizable].nomarLocalizable,
             @"device"         : ZFToString([AccountManager sharedManager].device_id),
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

- (NSString *)baseURL {
    return [self communityLiveURLAppendPublicArgument:Community_Live_API(@"api/live/video-list")];
}
@end
