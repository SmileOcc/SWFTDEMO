//
//  ZFOutfitCateModel.m
//  Zaful
//
//  Created by QianHan on 2018/6/5.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitCateModel.h"

@implementation ZFCommunityOutfitCateModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"cateID" : @"cat_id",
             @"cateName" : @"cat_name"
             };
}

@end
