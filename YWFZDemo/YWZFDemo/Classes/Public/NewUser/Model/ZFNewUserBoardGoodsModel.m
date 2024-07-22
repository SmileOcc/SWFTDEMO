//
//  ZFNewUserBoardGoodsModel.m
//  ZZZZZ
//
//  Created by mac on 2019/1/18.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserBoardGoodsModel.h"

@implementation ZFNewUserBoardGoodsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"board_list"     : [ZFNewUserBoardGoodsBoardList class],
             @"goods_list"     : [ZFNewUserBoardGoodsGoodsList class],
             };
}

@end

@implementation ZFNewUserBoardGoodsBoardList

@end


@implementation ZFNewUserBoardGoodsGoodsList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"seckill_info"     : [ZFNewUserBoardGoodsSeckillInfo class],
             @"cat_level_column"   : [ZFNewUserBoardGoodsCatLevelColumn class],
             };
}

@end


@implementation ZFNewUserBoardGoodsSeckillInfo

@end


@implementation ZFNewUserBoardGoodsCatLevelColumn

@end

