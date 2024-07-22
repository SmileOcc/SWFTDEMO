//
//  ZFGoodsdetailCouponListView.h
//  ZZZZZ
//
//  Created by YW on 2018/8/19.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFGoodsDetailCouponModel;

#define kCouponListViewHeight (490)

@interface ZFGoodsdetailCouponListView : UIView

@property (nonatomic, copy) void (^getCouponBlock)(ZFGoodsDetailCouponModel *couponModel, NSIndexPath *indexPath);

/**
 * 是否显示优惠券列表
 */
- (void)convertCouponListView:(NSArray<ZFGoodsDetailCouponModel *> *)couponListData showCoupon:(BOOL)isShowCoupon;

/**
 * 点击领劵刷新列表
 */
- (void)refreshListData:(NSArray<ZFGoodsDetailCouponModel *> *)couponDataArr;

/**
 * 刷新领劵状态
 */
- (void)refreshCouponWithIndex:(NSIndexPath *)indexPath;

@end
