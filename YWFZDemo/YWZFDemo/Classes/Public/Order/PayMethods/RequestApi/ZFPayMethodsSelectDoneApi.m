

//
//  ZFPayMethodsSelectDoneApi.m
//  Zaful
//
//  Created by liuxi on 2017/10/13.
//  Copyright © 2017年 Y001. All rights reserved.
//

#import "ZFPayMethodsSelectDoneApi.h"


@implementation ZFPayMethodsSelectDoneApi{
    NSString *_payCode;
    NSArray *_parametersArray;
}

- (instancetype)initWithPayCoder:(NSString *)payCode parametersArray:(NSArray *)parametersArray {
    if (self = [super init]) {
        _payCode = payCode;
        _parametersArray = parametersArray;
    }
    return self;
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
    return  @{
              @"action"                  :   @"cart/checkout_info",
              @"token"                   :   TOKEN,
              @"is_enc"                  :   @"0",
              @"order_group"  : @{
                      @"pay_node"       : _payCode,
                      @"order_info"     : _parametersArray
                      },
              };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
