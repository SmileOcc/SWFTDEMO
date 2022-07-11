//
//  OSSVCartWareHouseModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  仓库模型，包括商品列表模型

#import <Foundation/Foundation.h>
#import "OSSVCartGoodsModel.h"

@interface OSSVCartWareHouseModel : NSObject
//"wid": "2",
//"subtotal": 94.546,
//"active_save": 23.154,
//"coupon_save": 0,
//"shipping_cod": true,
//"paymen_cod": true,
//"insurance": 2.89,
//"shipping_cost": 0,
//"cod_cost": 0,
//"is_show_subtotal": 1,
//goods_list

@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *subtotal;
@property (nonatomic, copy) NSString *activeSave;                   ///<满减活动优惠金额
@property (nonatomic, copy) NSString *couponSave;                   ///<优惠券优惠金额
@property (nonatomic, copy) NSString *insurance;                    ///<物流保险金额
@property (nonatomic, copy) NSString *shippingCost;                 ///<物流运费
@property (nonatomic, copy) NSString *codCost;                      ///<COD费用
@property (nonatomic, assign) BOOL isShowSubtotal;                  ///<是否显示小计，用于界面视图控制
@property (nonatomic, strong) NSArray *goodsList;                   ///<物流仓库下的商品列表
@property (nonatomic, copy) NSString *pointSave;                    ///<积分优惠金额
@property (nonatomic, copy) NSString *disCountSave;                 ///<支付方式的优惠金额>
@end
