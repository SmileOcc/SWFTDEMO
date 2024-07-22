//
//  ZFTrackingPackageModel.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingPackageModel.h"
#import "ZFTrackingGoodsModel.h"
#import "ZFTrackingListModel.h"

@implementation ZFTrackingPackageModel


+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"track_goods" : [ZFTrackingGoodsModel class],
             @"track_list"  : [ZFTrackingListModel class]
             };
}

@end
