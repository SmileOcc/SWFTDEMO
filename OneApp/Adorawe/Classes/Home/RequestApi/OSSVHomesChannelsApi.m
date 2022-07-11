//
//  HomeChannerApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomesChannelsApi.h"

@implementation OSSVHomesChannelsApi

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_ChannelIndex];
}

- (id)requestParameters {

//    NSString * sex = [[NSUserDefaults standardUserDefaults] stringForKey: kGenderKey];
    int sex = [OSSVAccountsManager sharedManager].account == nil ? 1 : [OSSVAccountsManager sharedManager].account.sex;
    //运营后台只维护女性角色的商品
    return @{
             @"sex"            : [NSString stringWithFormat:@"%d", sex]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
