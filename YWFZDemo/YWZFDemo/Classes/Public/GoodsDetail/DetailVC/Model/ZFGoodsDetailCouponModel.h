//
//  ZFDetailCouponListModel.h
//  ZZZZZ
//
//  Created by YW on 2018/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFGoodsDetailCouponModel : NSObject
@property (nonatomic, strong) NSString *preferentialHead;
@property (nonatomic, strong) NSString *discounts;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *preferentialFirst;
// couponStatus 1:可领取;2:领券Coupon不存在;3:已领券;3:已领取完;4:没到领取时间;5:已过期;6:coupon 已领取完;7:赠送coupon 失败
@property (nonatomic, assign) NSInteger couponStats;
@property (nonatomic, strong) NSString *couponId;

///新增字段 免邮优惠券 1 免邮 0 不免邮
@property (nonatomic, assign) BOOL noMail;
@end

@interface ZFCouponMsgModel : NSObject
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *replace;
@property (nonatomic, copy) NSString *showCouponText;
@end
