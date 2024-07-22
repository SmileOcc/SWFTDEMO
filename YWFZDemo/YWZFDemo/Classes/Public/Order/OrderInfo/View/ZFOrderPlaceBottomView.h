//
//  ZFOrderPlaceBottomView.h
//  ZZZZZ
//
//  Created by YW on 2018/8/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  提交订单页面底部提交按钮视图

#import <UIKit/UIKit.h>
#import "ZFOrderAmountDetailModel.h"
#import "ZFOrderManager.h"

@protocol ZFOrderPlaceBottomViewDelegate <NSObject>

///点击了支付按钮
-(void)ZFOrderPlaceBottomViewDidClickPlaceOrderButton;

@end

@interface ZFOrderPlaceBottomView : UIView

@property (nonatomic, weak) id<ZFOrderPlaceBottomViewDelegate>delegate;
@property (nonatomic, strong) ZFOrderAmountDetailModel *detailModel;
@property (nonatomic, assign) BOOL isFast;
@property (nonatomic, assign) BOOL placeOrderButtonState;
@property (nonatomic, assign) CurrentPaymentType currentPaymentType;
@property (nonatomic, assign) BOOL isShowRewardPoints;
@property (nonatomic, strong) ZFOrderCheckInfoDetailModel   *checkOutModel;
@property (nonatomic, assign) BOOL isCenterShow; /// 没有积分与首单送copon提示，则价格居中显示

/**
 * 改变价格视图的状态
 * status YES 隐藏 NO 显示
 */
- (void)exchangePriceViewStatus:(BOOL)status;

@end
