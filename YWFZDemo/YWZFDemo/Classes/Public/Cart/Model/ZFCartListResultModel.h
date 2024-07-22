//
//  ZFCartListResultModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@class ZFCartGoodsListModel, ZFMyCouponModel;


@interface ZFCartCouponListModel : NSObject <YYModel>
@property (nonatomic, strong) NSArray<ZFMyCouponModel *> *available;
@property (nonatomic, strong) NSArray<ZFMyCouponModel *> *disabled;
@end


@interface ZFOfferMessageMOdel : NSObject <YYModel>
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *disabled;
@property (nonatomic, copy) NSString *tips;
@end


@interface ZFCartListResultModel : NSObject <YYModel>
@property (nonatomic, strong) NSString              *totalAmount;
@property (nonatomic, assign) NSInteger             totalNumber;
@property (nonatomic, assign) BOOL                  is_show_fast_payment;
@property (nonatomic, copy) NSString                *cartRadioHint; // 国家广播提示语
@property (nonatomic, copy) NSString                *channel_save_total;
@property (nonatomic, copy) NSString                *full_save_total;
@property (nonatomic, strong) NSMutableArray<ZFCartGoodsListModel *> *goodsBlockList;
//免邮差价，如果大于0，可以去凑单商品列表页
@property (nonatomic, copy) NSString                *cart_shipping_free_amount;
@property (nonatomic, copy) NSString                *cart_shipping_free_amount_replace;//提示中的价格
@property (nonatomic, copy) NSString                *cartUserHint;//购物车底部提示文案

@property (nonatomic, copy) NSString                *student_discount_amount;
@property (nonatomic, copy) NSString                *cart_coupon_amount;
@property (nonatomic, copy) NSString                *cart_discount_amount;
@property (nonatomic, strong) ZFCartCouponListModel *couponListModel;
@property (nonatomic, copy) NSString                *coupon_code;
@property (nonatomic, strong) ZFOfferMessageMOdel   *offerMessageModel;


// ========================以下字段非服务端返回自己计算的====================================
//购物车不存在有效商品，只有失效商品或赠品时
@property (nonatomic, assign) BOOL                  isAllUnavailableGoodsOrNoGoods;
@property (nonatomic, copy) NSString                *productsTotalPrice;
@end
