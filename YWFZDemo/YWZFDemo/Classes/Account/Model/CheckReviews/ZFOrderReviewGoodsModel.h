//
//  ZFOrderReviewGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCouponYouHuiLvModel.h"

@interface ZFOrderReviewGoodsModel : NSObject
@property (nonatomic, copy) NSString            *goods_attr;
@property (nonatomic, copy) NSString            *goods_grid;
@property (nonatomic, copy) NSString            *goods_grid_app;
@property (nonatomic, copy) NSString            *goods_id;
@property (nonatomic, copy) NSString            *goods_name;
@property (nonatomic, copy) NSString            *goods_number;
@property (nonatomic, copy) NSString            *goods_price;
@property (nonatomic, copy) NSString            *goods_sn;
@property (nonatomic, copy) NSString            *goods_title;
@property (nonatomic, copy) NSString            *is_group_recommend;
@property (nonatomic, copy) NSString            *is_lang_show_cur;
@property (nonatomic, copy) NSString            *is_promote;
@property (nonatomic, copy) NSString            *is_review;
@property (nonatomic, copy) NSString            *market_price;
@property (nonatomic, copy) NSString            *order_currency;
@property (nonatomic, copy) NSString            *order_rate;
@property (nonatomic, copy) NSString            *promote_end_date;
@property (nonatomic, copy) NSString            *promote_price;
@property (nonatomic, copy) NSString            *promote_start_date;
@property (nonatomic, copy) NSString            *subtotal;
@property (nonatomic, copy) NSString            *url_title;
@property (nonatomic, copy) NSString            *attr_strs;

/// 首次提供积分
@property (nonatomic, copy) NSString                *review_info_extra_point;
/// show图片，额外积分
@property (nonatomic, copy) NSString                *review_show_extra_point;

@property (nonatomic, copy) NSString                *review_point;

@property (nonatomic, strong) NSArray<NSString *>   *review_tags;

@property (nonatomic, strong) ZFCouponYouHuiLvModel *review_show_extra_coupon;
@property (nonatomic, strong) ZFCouponYouHuiLvModel *review_coupon;
@end
