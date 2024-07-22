//
//  ZFOrderReviewApi.m
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderReviewApi.h"
#import "NSStringUtils.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFOrderReviewApi() {
    NSString *_orderId;
    NSString *_goodsId;
}

@end

@implementation ZFOrderReviewApi
- (instancetype)initWithOrderId:(NSString *)orderId goodsId:(NSString *)goodsId {
    self = [super init];
    if (self) {
        self->_orderId = orderId;
        self->_goodsId = goodsId;
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

- (NSString *)requestPath {
    return ENCPATH;
}

- (BOOL)encryption {
    return NO;
}

- (id)requestParameters {
    return @{
             @"action"     :  @"review/get_sku_review_list",
             @"order_id"   : ZFToString(_orderId),
             @"token"       : TOKEN,
             @"is_enc"      : @"0",
             @"goods_id"   : ZFToString(_goodsId),
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
