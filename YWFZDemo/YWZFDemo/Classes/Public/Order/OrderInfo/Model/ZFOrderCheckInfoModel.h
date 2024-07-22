//
//  ZFOrderCheckInfoModel.h
//  ZZZZZ
//
//  Created by YW on 23/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderCheckInfoDetailModel.h"
#import "CheckOutGoodListModel.h"

typedef NS_ENUM(NSUInteger, PaymentProcessType){
    // 老的支付流程
    PaymentProcessTypeOld   = 1,
    // 拆单支付流程
    PaymentProcessTypeNew   = 2,
    //标示没有商品可以下单
    PaymentProcessTypeNoGoods = -1,
};

@interface ZFOrderCheckInfoModel : NSObject
@property (nonatomic, strong) ZFOrderCheckInfoDetailModel                       *order_info;
@property (nonatomic, assign) NSInteger                                         node;                       //1 cod方式， 2 online方式 3.组合方式
@property (nonatomic, assign) BOOL                                              isBackToCart;               // 是否返回购物车

@end
