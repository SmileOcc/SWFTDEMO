//
//  OrderDetailApi.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "OrderDetailApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation OrderDetailApi
{
    NSString *_orderId;
}
-(instancetype)initWithOrderId:(NSString *)orderId {
    
    self = [super init];
    if (self) {
        _orderId = orderId;
    }
    return self;
}
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
    
    return @{
             @"action"      :   @"order/detail",
             @"token"       :   TOKEN,
             @"order_id"    :   _orderId,
             @"is_enc"       :  @"0"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
