//
//  ZFCollectionListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCollectionListModel.h"
#import "ZFGoodsModel.h"

@implementation ZFCollectionListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"data" : [ZFGoodsModel class]
             };
}

@end
