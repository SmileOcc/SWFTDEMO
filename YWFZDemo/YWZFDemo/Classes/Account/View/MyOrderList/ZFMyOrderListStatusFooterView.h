//
//  ZFMyOrderListStatusFooterView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrdersModel.h"

typedef void(^OrderListOrderBackToCartCompletionHandler)(void);
typedef void(^OrderListOrderPayNowCompletionHandler)(void);
typedef void(^OrderListOrderTrakingInfoCompletionHandler)(void);
typedef void(^OrderListReviewShowCompletionHandler)(void);
typedef void(^OrderListRefundCompletionHandler)(void);
typedef void(^OrderListCODCheckAddressCompletionHandler)(void);

@interface ZFMyOrderListStatusFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) MyOrdersModel         *model;

@property (nonatomic, copy) OrderListOrderBackToCartCompletionHandler           orderListOrderBackToCartCompletionHandler;
@property (nonatomic, copy) OrderListOrderPayNowCompletionHandler               orderListOrderPayNowCompletionHandler;
@property (nonatomic, copy) OrderListOrderTrakingInfoCompletionHandler          orderListOrderTrakingInfoCompletionHandler;
@property (nonatomic, copy) OrderListReviewShowCompletionHandler                orderListReviewShowCompletionHandler;
@property (nonatomic, copy) OrderListRefundCompletionHandler                    orderListRefundCompletionHandler;
@property (nonatomic, copy) OrderListCODCheckAddressCompletionHandler           orderListCODCheckAddressCompletionHandler;

+ (BOOL)canShowReviewsBtn:(NSArray<MyOrderGoodListModel *> *)goodsListModel;

@end
