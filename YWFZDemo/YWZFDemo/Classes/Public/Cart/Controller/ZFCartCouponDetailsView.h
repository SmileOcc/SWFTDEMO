//
//  ZFCartCouponDetailsView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//
// 购物车 底部价格视图下拉箭头显示优惠券详细信息

#import <UIKit/UIKit.h>
@class ZFCartListResultModel;

typedef enum : NSUInteger {
    ZFCartCouponDetailsView_TapMaskBgActionType,
    ZFCartCouponDetailsView_CloseActionType,
    ZFCartCouponDetailsView_FinishDismissActionType,
} ZFCartCouponDetailsViewActionType;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCartCouponDetailsView : UIView

@property (nonatomic, strong) ZFCartListResultModel *cartListResultModel;

@property (nonatomic, copy) void (^couponDetailsViewBlock) (ZFCartCouponDetailsViewActionType actionType);

- (void)showCouponInfoView:(BOOL)show popHeight:(CGFloat)popHeight;

@end

NS_ASSUME_NONNULL_END
