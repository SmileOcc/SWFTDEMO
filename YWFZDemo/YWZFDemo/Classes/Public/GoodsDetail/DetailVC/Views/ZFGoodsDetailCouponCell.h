//
//  ZFGoodsDetailCouponCell.h
//  ZZZZZ
//
//  Created by YW on 2018/8/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCouponBaseTableViewCell.h"
@class ZFGoodsDetailCouponModel;
typedef void (^ReceiveCouponBlock)(ZFGoodsDetailCouponModel *couponModel);

@interface ZFGoodsDetailCouponCell : ZFCouponBaseTableViewCell

@property (nonatomic, strong) ZFGoodsDetailCouponModel *couponModel;

@property (nonatomic, copy) ReceiveCouponBlock receiveCouponBlock;

@end
