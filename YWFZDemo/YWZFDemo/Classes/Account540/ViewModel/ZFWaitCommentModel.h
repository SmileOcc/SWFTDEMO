//
//  ZFWaitCommentModel.h
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCouponYouHuiLvModel.h"

@interface ZFWaitCommentModel : NSObject
@property (nonatomic, copy) NSString *get_point;
@property (nonatomic, copy) NSString *goods_thumb;
@property (nonatomic, copy) NSString *goods_grid;
@property (nonatomic, copy) NSString *goods_title;
@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *order_id;
@property (nonatomic, copy) NSString *point_msg;
@property (nonatomic, strong) ZFCouponYouHuiLvModel *coupon_msg;
@property (nonatomic, strong) ZFCouponYouHuiLvModel *second_coupon_msg;
@property (nonatomic, copy) NSString *goods_attr_str;

/// 自定义
@property (nonatomic, copy) NSMutableAttributedString *pointsAttr;

@end

@interface ZFMyCommentModel : NSObject
@property (nonatomic, copy) NSString *order_id;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, copy) NSString *rate_overall;
@property (nonatomic, copy) NSString *goods_attr_str;
@property (nonatomic, copy) NSString *goods_grid;
@property (nonatomic, copy) NSString *pros;
@property (nonatomic, copy) NSString *goods_title;
@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_sn;

@property (nonatomic, strong) ZFCouponYouHuiLvModel *coupon_msg;
@property (nonatomic, strong) ZFCouponYouHuiLvModel *second_coupon_msg;

@end
