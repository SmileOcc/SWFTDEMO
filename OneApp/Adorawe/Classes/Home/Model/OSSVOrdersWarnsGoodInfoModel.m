//
//  OrderWarnGoodsInfoModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdersWarnsGoodInfoModel.h"

@implementation OSSVOrdersWarnsGoodInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodsThumb" : @"goods_thumb",
             @"goodsId" : @"goods_id",
             };
}

@end
