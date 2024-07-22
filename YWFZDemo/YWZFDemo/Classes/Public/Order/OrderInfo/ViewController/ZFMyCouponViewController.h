//
//  ZFMyCouponViewController.h
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFOrderManager.h"

@interface ZFMyCouponViewController : ZFBaseViewController

@property (nonatomic, copy) void(^applyCouponHandle)(NSString *couponCode, BOOL shouldPop);
@property (nonatomic, strong) NSArray *availableArray;
@property (nonatomic, strong) NSArray *disabledArray;
@property (nonatomic, copy) NSString *couponCode;
@property (nonatomic, copy) NSString *couponAmount;
@property (nonatomic, assign) CurrentPaymentType   currentPaymentType;

@end
