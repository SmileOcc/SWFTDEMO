//
//  ZFCarCouponDetailsCodeHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//
// <优惠券明细信息>

#import <UIKit/UIKit.h>

@class ZFCartListResultModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCarCouponDetailsCodeHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) ZFCartListResultModel *cartListResultModel;

@property (nonatomic, copy) void(^addCodesHandler)(void);

@end

NS_ASSUME_NONNULL_END
