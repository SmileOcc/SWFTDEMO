//
//  ZFReturnToBagApi.m
//  ZZZZZ
//
//  Created by YW on 2/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFReturnToBagApi.h"
#import "NSStringUtils.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@implementation ZFReturnToBagApi {
    NSString *_orderID;
    NSString *_forceId;
}


- (instancetype)initWithOrderID:(NSString *)orderID {
    self = [super init];
    if (self) {
        _orderID = orderID;
        _forceId = @"0";
    }
    return self;
}

- (instancetype)initWithorderID:(NSString *)orderID forceId:(NSString *)forceId
{
    self = [super init];
    if (self) {
        _orderID = orderID;
        _forceId = forceId;
    }
    return self;
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
             @"action"      :  @"order/return_to_bag",
             @"order_id"    :  NullFilter(_orderID),
             @"token"       :  TOKEN,
             @"is_enc"      :  @"0",
             @"force_add"   :  ZFToString(_forceId)
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
