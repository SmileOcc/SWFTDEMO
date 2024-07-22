//
//  ZFGoodsDetailOutfitsModel.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailOutfitsModel.h"

@implementation ZFDetailOutfitsPicModel

@end


@implementation ZFGoodsDetailOutfitsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"outfitsId"  : @"id",
             @"picModel"   : @"pic",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"picModel" : [ZFDetailOutfitsPicModel class]
             };
}
@end
