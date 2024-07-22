
//
//  ZFFreeGiftListModel.m
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFFreeGiftListModel.h"

@implementation ZFFreeGiftListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goods_list" : [ZFFreeGiftGoodsModel class],
             };
}
@end
