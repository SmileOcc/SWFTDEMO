//
//  OrderDetailOrderModel.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "OrderDetailOrderModel.h"
#import "YWCFunctionTool.h"

@implementation OrderDetailOrderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hacker_point = [ZFHackerPointOrderModel new];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"VATModel" : @"vattax"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"hacker_point" : [ZFHackerPointOrderModel class]
             };
}

- (BOOL)isOfflinePayment
{
    if (!ZFToString(self.pay_name).length) {
        return NO;
    }
    NSString *lowPayName = self.pay_name.lowercaseString;
    if ([lowPayName containsString:@"oxxo"] || [lowPayName isEqualToString:@"boleto"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isKlarnaPayment
{
    if (!ZFToString(self.pay_name).length) {
        return NO;
    }
    NSString *lowPayName = self.pay_name.lowercaseString;
    if ([lowPayName isEqualToString:@"klarna"]) {
        return YES;
    }
    return NO;
}

@end
