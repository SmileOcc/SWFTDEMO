//
//  ZFOrderReviewInfoModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderReviewImageInfoModel.h"
#import "ZFOrderSizeModel.h"
#import "GoodsDetailsReviewsSizeModel.h"
#import "ZFCouponYouHuiLvModel.h"

@interface ZFOrderReviewInfoModel : NSObject
@property (nonatomic, copy) NSString *review_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *order_id;
@property (nonatomic, copy) NSString *rate_overall;

@property (nonatomic, strong) NSArray<ZFOrderReviewImageInfoModel *> *reviewPic;
@property (nonatomic, strong) GoodsDetailsReviewsSizeModel *reviewSize;

@property (nonatomic, copy) NSString *review_success_point;

@property (nonatomic, strong) ZFCouponYouHuiLvModel *review_success_coupon;
@property (nonatomic, strong) ZFCouponYouHuiLvModel *review_success_coupon1;

@end
