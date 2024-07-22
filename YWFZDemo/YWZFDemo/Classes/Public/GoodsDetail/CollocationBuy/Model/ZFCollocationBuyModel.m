//
//  ZFCollocationBuyModel.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollocationBuyModel.h"


@implementation ZFCollocationBuyTabModel
@end


@implementation ZFUnfloatPriceInfo
@end


@implementation ZFCollocationGoodsModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"unfloatPriceInfo" : [ZFUnfloatPriceInfo class],
             };
}
@end

@implementation ZFCollocationBuyModel
@end


