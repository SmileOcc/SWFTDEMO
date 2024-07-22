//
//  ZFCMSCouponItemBaseView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSCouponBaseView.h"

//自定义 coupon状态；<=1:可领取;2:已领取;3:已领取完
typedef NS_ENUM(NSInteger, ZFCMSCouponState) {
    ZFCMSCouponStateCanReceive = 1,
    ZFCMSCouponStateHadReceive = 2,
    ZFCMSCouponStateNoCounts = 3,
    ZFCMSCouponStateUnknow,
};


@interface ZFCMSCouponItemView : ZFCMSCouponBaseView

@property (nonatomic, copy) void (^tapBlock)(void);


@end



@interface ZFCMSCouponBigItemBaseView : ZFCMSCouponItemView

@end


@interface ZFCMSCouponMediumItemBaseView : ZFCMSCouponItemView

@end


@interface ZFCMSCouponTrisectionItemBaseView : ZFCMSCouponItemView

@end

@interface ZFCMSCouponQuarterItemBaseView : ZFCMSCouponItemView

@end
