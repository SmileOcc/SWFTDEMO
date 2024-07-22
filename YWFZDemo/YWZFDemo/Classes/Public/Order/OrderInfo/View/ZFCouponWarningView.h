//
//  ZFCouponWarningView.h
//  ZZZZZ
//
//  Created by YW on 2017/12/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderManager.h"

@interface ZFCouponWarningView : UIView

@property (nonatomic, copy) NSString *couponAmount;

@property (nonatomic, assign) CurrentPaymentType   currentPaymentType;


@end
