//
//  OSSVAccounteOrdersDetaileGoodsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteOrdersDetaileGoodsModel.h"

@implementation OSSVAccounteOrdersDetaileGoodsModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsName" : @"goods_name",
             @"goodsAttr" : @"goods_attr",
             @"goodsThumb" : @"goods_thumb",
             @"goodsId" : @"goods_id",
             @"goodsNumber" : @"goods_number",
             @"isReview" : @"is_review",
             @"cat_name" : @"cat_name",
             @"wareHouseName" : @"warehouse_name",
             @"orderId" : @"order_id",
             };
}


// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"money_info" : [OSSVOrdereMoneyeInfoModel class]};
}

@end
