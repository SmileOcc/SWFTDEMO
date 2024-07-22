//
//  MyOrdersModel.h
//  Yoshop
//
//  Created by YW on 16/6/7.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyOrderGoodListModel.h"
#import "ZFBaseOrderModel.h"

@interface MyOrdersModel : ZFBaseOrderModel

@property (nonatomic, copy) NSString *order_currency;

@property (nonatomic, copy) NSString *order_time;

@property (nonatomic, strong) NSArray<MyOrderGoodListModel *> *goods;

@property (nonatomic, copy) NSString *promote_pcode;

// 用于显示 boletoBancario 支付状态
@property (nonatomic, copy) NSString *pay_status;

/// 用于主页弹框提示有未支付订单描述
@property (nonatomic, copy) NSString *order_message;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *contact_us;

///通过后台返回的数据计算的值，默认为1，总商品条数
@property (nonatomic, assign, readonly) NSInteger totalCount;

///通过后台返回的数据计算的值，默认为0, 显示商品条数
@property (nonatomic, assign, readonly) NSInteger leaveCount;

@property (nonatomic, copy) NSString *pay_left_time;

@property (nonatomic, copy) NSString *countDownCartTimerKey;
@end

