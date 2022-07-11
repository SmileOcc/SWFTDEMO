//
//  DiscoveryApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeDiscoverAip.h"
//#import <AppsFlyerLib/AppsFlyerTracker.h>

@implementation OSSVHomeDiscoverAip  {
    NSInteger _page;
    NSInteger _pageSize;
    NSString  *_channel_id;
}

- (instancetype)initWithDiscoveryPage:(NSInteger)page pageSize:(NSInteger)pageSize channelId:(NSString *)channelid{
    
    self = [super init];
    if (self) {
        _page = page;
        _pageSize = pageSize;
        _channel_id = channelid;
    }
    return self;
}

- (BOOL)enableCache {
    if (_page == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
}

- (NSString *)requestPath {
    // banner/bannerblock
    return [OSSVNSStringTool buildRequestPath:kApi_BannerList];
}

- (id)requestParameters {
    // 登录状态下，其实性别的判断，是根据 user_id ,此时 sex == @"2",已经不符合要求啦，如果要统一，需要在kGenderKey进行统一调整（首页，登录，注册，退出）
    // 非登录下，性别的判断是根据  sex “0”，“1”  来判断的
    // @"sex"         : [OSSVNSStringTool isEmptyString:sex] ? @"2" : sex, // 必选参数字符串 0男 1女 2默认)
    // NSString * sex = [[NSUserDefaults standardUserDefaults] stringForKey: kGenderKey];
    // 运营后台只维护女性角色商品
    
    int sex = [OSSVAccountsManager sharedManager].account == nil ? 1 : [OSSVAccountsManager sharedManager].account.sex;
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = @{
        @"channel_id"  : STLToString(_channel_id),
        @"sex"         : [NSString stringWithFormat:@"%d", sex], ///因为后台预发布没有发布，所以这里要传空, 其实要传1
        @"page"        : @(_page),
        @"page_size"   : @(_pageSize),
        @"adgroup"     : STLToString([us objectForKey:AFADGroup]), // 冷启动推荐
//             @"appsFlyerUID": [AppsFlyerTracker sharedTracker].getAppsFlyerUID
    }.mutableCopy;
    
    if ([OSSVAccountsManager sharedManager].isSignIn && USERID) {
        NSString* tokenString = [NSString stringWithFormat:@"%@",STLToString(USER_TOKEN)];
        [dict setObject:tokenString forKey:@"token"];
    }
    
    return dict;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
