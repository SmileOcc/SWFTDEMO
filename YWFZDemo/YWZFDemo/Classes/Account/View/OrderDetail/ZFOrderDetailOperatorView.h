//
//  ZFOrderDetailOperatorView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailOrderModel.h"

typedef void(^ZFOrderDetailCheckReviewCompletionHandler)(void);
typedef void(^ZFOrderDetailRefundCompletionHandler)(void);
typedef void(^ZFOrderDetailCancelCompletionHandler)(void);
typedef void(^ZFOrderDetailOrderBackToCartCompletionHandler)(void);
typedef void(^ZFOrderDetailOrderPayNowCompletionHandler)(void);
typedef void(^ZFOrderDetailOrderTrakingInfoCompletionHandler)(void);

@interface ZFOrderDetailOperatorView : UIView

@property (nonatomic, strong) OrderDetailOrderModel             *model;

@property (nonatomic, copy) ZFOrderDetailCheckReviewCompletionHandler               orderDetailCheckReviewCompletionHandler;
@property (nonatomic, copy) ZFOrderDetailRefundCompletionHandler                    orderDetailRefundCompletionHandler;
@property (nonatomic, copy) ZFOrderDetailCancelCompletionHandler                    orderDetailCancelCompletionHandler;
@property (nonatomic, copy) ZFOrderDetailOrderBackToCartCompletionHandler           orderDetailOrderBackToCartCompletionHandler;
@property (nonatomic, copy) ZFOrderDetailOrderPayNowCompletionHandler               orderDetailOrderPayNowCompletionHandler;
@property (nonatomic, copy) ZFOrderDetailOrderTrakingInfoCompletionHandler          orderDetailOrderTrakingInfoCompletionHandler;

//用于订单详情页，确认倒计时提示确定中心点
@property (nonatomic, strong, readonly) UIButton          *rightButton;      //第二个按钮

/**
 *  改变价格标签的状态
 *  status YES 隐藏价格标签 NO 显示价格标签
 */
- (void)operatorViewExchangePriceViewStatus:(BOOL)status;

@end
