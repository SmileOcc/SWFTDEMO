//
//  OSSVOrderInfoeModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCartGoodsModel.h"

@interface OSSVOrderInfoeModel : NSObject

@property (nonatomic, copy) NSString *orderSn;
@property (nonatomic, copy) NSString *orderAmount;
@property (nonatomic, copy) NSString *orderShippingCost;
@property (nonatomic, copy) NSString *orderCoupon;
@property (nonatomic, strong) NSArray *goodsList;
/*西联支付返回订单详情URL*/
@property (nonatomic, copy) NSString *orderDesc;
//@property (nonatomic, copy) NSString *payment;

/**Cod支付: Cod */
@property (nonatomic, copy) NSString *payCode;
@property (nonatomic, copy) NSString *codOrderAmount;
@end
