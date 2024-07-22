//
//  ZFCommunityOutfitsListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitsListModel.h"
#import "ZFCommunityOutfitsModel.h"
@implementation ZFCommunityOutfitsListModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"outfitsList" : @"list",
             @"total" : @"total"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"outfitsList" : [ZFCommunityOutfitsModel class],
             };
}

@end
