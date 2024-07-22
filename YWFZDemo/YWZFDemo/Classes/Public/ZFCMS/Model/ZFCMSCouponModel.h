//
//  ZFCMSCouponModel.h
//  ZZZZZ
//
//  Created by YW on 2019/11/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"


@interface ZFCMSCouponModel : NSObject<YYModel, NSCoding>

@property (nonatomic, copy) NSString *idx;
@property (nonatomic, copy) NSString *get_begin_time;
@property (nonatomic, copy) NSString *get_over_time;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *youhuilv;
@property (nonatomic, copy) NSString *rate;

//=1 百分比 2 满减
@property (nonatomic, copy) NSString *fangshi;
@property (nonatomic, copy) NSString *currency;

@property (nonatomic, copy) NSString *left_rate;
@property (nonatomic, copy) NSString *use_range;

// 判断是否无限制 0 表示无限制 1 有限制 (无限制，不显示)
@property (nonatomic, copy) NSString *is_no_limit;



//自定义 coupon状态；<=1:可领取;2:已领取;3:已领取完
@property (nonatomic, assign) NSInteger couponState;
@property (nonatomic, copy) NSString *currentUserId;



@end

