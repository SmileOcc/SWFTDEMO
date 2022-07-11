//
//  STLBannerHomeFloatApi.m
// XStarlinkProject
//
//  Created by odd on 2021/3/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBannersHomesFloatAip.h"

@implementation OSSVBannersHomesFloatAip

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_BannerHomeFloat];
}

- (id)requestParameters {
//    int sex = [OSSVAccountsManager sharedManager].account == nil ? 2 : [OSSVAccountsManager sharedManager].account.sex;

    NSDictionary *params = @{};
            if ([OSSVAccountsManager sharedManager].isSignIn && USERID) {
                NSString* tokenString = [NSString stringWithFormat:@"%@",STLToString(USER_TOKEN)];
                params = @{@"token":tokenString};
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
