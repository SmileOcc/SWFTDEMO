//
//  ZFHackerPointModel.m
//  ZZZZZ
//
//  Created by YW on 2018/9/5.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFHackerPointModel.h"

@implementation ZFHackerPointModel

@end

@implementation ZFHackerPointOrderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.order_real_pay_amount = @"";
        self.order_pay_way = @"";
        self.order_market_type = @"";
        self.order_point_value = @"";
        self.order_point_amount = @"";
        self.order_shipping_way = @"";
        self.order_origin_amount = @"";
        self.order_discount_amount = @"";
    }
    return self;
}

@end

@implementation ZFHackerPointGoodsModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.goods_market_type = @"";
        self.goods_storage_num = @"";
        self.goods_pay_discount = @"";
        self.goods_origin_amount = @"";
        self.goods_real_pay_amount = @"";
    }
    return self;
}

@end
