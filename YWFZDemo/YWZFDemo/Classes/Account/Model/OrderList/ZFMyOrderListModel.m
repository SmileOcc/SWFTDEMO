
//
//  ZFMyOrderListModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListModel.h"

@implementation ZFMyOrderListModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"data" : [MyOrdersModel class]
             };
}

@end
