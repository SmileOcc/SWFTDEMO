//
//  ZFVideoLiveCouponAlertView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailCouponModel.h"


@interface ZFVideoLiveCouponAlertView : UIView

- (instancetype)initWithFrame:(CGRect)frame couponModel:(ZFGoodsDetailCouponModel *)couponModel;

- (instancetype)initWithFrame:(CGRect)frame couponModel:(ZFGoodsDetailCouponModel *)couponModel isNew:(BOOL)isNew;

@property (nonatomic, assign) BOOL isNewAlert;

@property (nonatomic, strong) ZFGoodsDetailCouponModel *couponModel;

@property (nonatomic, copy) void (^receiveCouponBlock)(ZFGoodsDetailCouponModel *couponModel);
@property (nonatomic, copy) void (^closeBlock)(void);


/*
 * time: 设置自动隐藏时间
 * completion:
 */
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion;
@end
