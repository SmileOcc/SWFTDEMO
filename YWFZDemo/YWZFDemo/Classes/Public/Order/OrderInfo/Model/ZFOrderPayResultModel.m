//
//  ZFOrderPayResultModel.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderPayResultModel.h"

@implementation ZFOrderPayResultModel

- (BOOL)isOXXOPayment
{
    if ([self.payChannelCode.lowercaseString isEqualToString:@"oxxo"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isBoletoPayment
{
    if ([self.payChannelCode.lowercaseString isEqualToString:@"boleto"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPagoefePayment
{
    if ([self.payChannelCode.lowercaseString isEqualToString:@"pagoefe"]) {
        return YES;
    }
    return NO;
}

@end
