//
//  ZFMyCouponViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewModel.h"

@class ZFMyCouponModel;
@interface ZFMyCouponViewModel : BaseViewModel <UITableViewDelegate, UITableViewDataSource>

///isSelectCallback 是否用户自己主动选择优惠券 1 是 0 不是
@property (nonatomic, copy) void(^itemSelectedHandle)(ZFMyCouponModel *model, BOOL hasChange, BOOL isSelectCallback);

@property (nonatomic, copy) void(^unUseCouponHandle)(BOOL isSelected);

- (instancetype)initWithAvailableCoupon:(NSArray <ZFMyCouponModel *>*)availableCoupon
                          disableCoupon:(NSArray <ZFMyCouponModel *>*)disableCoupon
                             couponCode:(NSString *)couponCode
                           couponAmount:(NSString *)couponAmount;

- (void)selectedBefore; // 开始进入的选择判断

/**
 * 校验coupon有效性
 */
- (void)checkEffectiveCoupon:(NSString *)couponCode  completion:(void (^)(id obj))completion;

- (void)removeOrDeselectDefaultCoupon:(UITableView *)tableView;

@end
