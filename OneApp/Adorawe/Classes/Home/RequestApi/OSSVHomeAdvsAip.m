//
//  HomeAdvApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeAdvsAip.h"

@implementation OSSVHomeAdvsAip

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_BannerPopupWindow];
}

- (id)requestParameters {
    int sex = [OSSVAccountsManager sharedManager].account == nil ? 2 : [OSSVAccountsManager sharedManager].account.sex;
    
    NSMutableDictionary *params = @{
        @"sex"       : [NSString stringWithFormat:@"%d", sex]
        }.mutableCopy;
    if ([OSSVAccountsManager sharedManager].isSignIn && USERID) {
        NSString* tokenString = [NSString stringWithFormat:@"%@",STLToString(USER_TOKEN)];
        [params setObject:tokenString forKey:@"token"];
    }


    return params;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
