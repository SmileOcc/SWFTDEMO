//
//  CartListApi.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/2.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "CartListApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation CartListApi

- (BOOL)enableCache {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

-(BOOL)encryption {
    return NO;
}

- (id)requestParameters {
    
    if ([AccountManager sharedManager].isSignIn) {
        return @{
                 @"action"   :  @"cart/get_cart_info",
                 @"token"    :  TOKEN,
                 @"is_enc"   :  @"0"
                 };
        
    }else{
        return @{
                 @"action"   :  @"cart/get_cart_info",
                 @"sess_id"  :  SESSIONID,
                 @"is_enc"   :  @"0"
                 };
    }
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

/// 请求的SerializerType
- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
