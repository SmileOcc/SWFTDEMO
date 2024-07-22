//
//  OrderMyCouponApi.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/18.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "OrderMyCouponApi.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation OrderMyCouponApi

{
    NSString *_code;
}

-(instancetype)initWithCouponCode:(NSString *)code{
    
    self = [super init];
    if (self) {
        _code = code;
    }
    return self;
}
- (BOOL)enableCache {
    return YES;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    
    return @{
             @"action"     :  @"cart/check_coupon",
             @"coupon"     :  ZFToString(_code),
             @"token"      : (ISLOGIN ? TOKEN : @""),
             @"sess_id"    : (ISLOGIN ? @"" : SESSIONID),
             @"is_enc"    :  @"0"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
