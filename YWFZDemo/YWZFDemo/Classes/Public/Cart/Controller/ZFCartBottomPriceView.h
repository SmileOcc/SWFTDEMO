//
//  ZFCartBottomPriceView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCartListResultModel;

typedef enum : NSUInteger {
    PayPalBtnActionType,
    CheckoutOutBtnActionType,
} ZFCartBottomPriceViewActionType;

typedef NS_ENUM(NSInteger, ZFCartListBlocksType) {
    ZFCartListBlocksTypeNormal = 0,
    ZFCartListBlocksTypeDiscount = 1,
    ZFCartListBlocksTypeUnavailable = 2,
    ZFCartListBlocksTypeFreeGift = 9,
    ZFCartListBlocksTypeCouponDetailsCode, //非服务器返回 V4.5.x
    ZFCartListBlocksTypeRecommendGoods //非服务器返回 V4.5.7
};

typedef void(^CartOptionViewActionBlock)(ZFCartBottomPriceViewActionType actionType);

@interface ZFCartBottomPriceView : UIView

@property (nonatomic, strong) ZFCartListResultModel *model;

@property (nonatomic, copy) CartOptionViewActionBlock cartOptionViewActionBlock;

/**
 * 刷新按钮状态
 */
- (void)refreshButtonEnabledStatus:(BOOL)isEnabled;

- (void)invalidateTipTimer;

@end
