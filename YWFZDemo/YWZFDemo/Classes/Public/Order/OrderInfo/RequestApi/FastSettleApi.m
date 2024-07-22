//
//  FastSettleApi.m
//  ZZZZZ
//
//  Created by YW on 2017/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "FastSettleApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation FastSettleApi {
    NSString *_payertoken;
    NSString *_payerId;
}

-(instancetype)initWithPayertoken:(NSString *)payertoken payerId:(NSString *)payerId {
    if (self = [super init]) {
        _payertoken = payertoken;
        _payerId = payerId;
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
    return [NSStringUtils buildRequestPath:@""];
}


- (id)requestParameters {
    return @{
             @"action"     : @"cart/quick_checkout",
             @"sess_id"    : SESSIONID,
             @"token"      : TOKEN,
             @"payertoken" : _payertoken,
             @"payerId"    : _payerId,
             @"is_enc"   :  @"0"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}



- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
