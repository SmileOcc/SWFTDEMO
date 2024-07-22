//
//  ZFOutfitBorderModel.m
//  Zaful
//
//  Created by QianHan on 2018/6/5.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitBorderModel.h"

@implementation ZFCommunityOutfitBorderModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"name" : @"name",
             @"imageURL" : @"img_url"
             };
}

@end
