
//
//  ZFOrderDeatailListModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDeatailListModel.h"


@implementation ZFChildOrderInfoModel
@end

@implementation ZFRefundReasonModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"reasonId" : @"child",
             @"otherReason" : @"other",
             };
}

@end

@implementation ZFOrderDetailChildModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"goods_list" : [OrderDetailGoodModel class],
             };
}
@end


@implementation ZFRefundOrderModel
@end


@implementation ZFOrderDeatailListModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"child_order" : [ZFOrderDetailChildModel class],
             @"refund_order_list" : [ZFRefundOrderModel class],
             @"refund_select_info" : [ZFRefundReasonModel class],
            };
}

- (NSInteger)totalGoodsNums
{
    if (_totalGoodsNums > 0) {
        return _totalGoodsNums;
    }
    NSInteger totalGoodsNums = 0;
    NSInteger childOrderCount = self.child_order.count;
    for (int i = 0; i < childOrderCount; i++) {
        ZFOrderDetailChildModel *childModel = self.child_order[i];
        NSInteger childModelGoodsListCount = childModel.goods_list.count;
        for (int j = 0; j < childModelGoodsListCount; j++) {
            OrderDetailGoodModel *goodsModel = childModel.goods_list[j];
            totalGoodsNums += goodsModel.goods_number.integerValue;
        }
    }
    return totalGoodsNums;
}



@end
