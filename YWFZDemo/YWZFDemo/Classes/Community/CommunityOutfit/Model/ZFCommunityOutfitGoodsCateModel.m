//
//  ZFCommunityOutfitCateModel.m
//  ZZZZZ
//
//  Created by YW on 2018/6/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitGoodsCateModel.h"

@implementation ZFCommunityOutfitGoodsCateModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"cateID" : @"cat_id",
             @"cateName" : @"cat_name"
             };
}

@end
