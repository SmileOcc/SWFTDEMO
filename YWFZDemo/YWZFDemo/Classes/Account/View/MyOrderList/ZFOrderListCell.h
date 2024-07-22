//
//  ZFOrderListCell.h
//  ZZZZZ
//
//  Created by 602600 on 2020/1/7.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrdersModel.h"

typedef void(^OrderListOrderBackToCartCompletionHandler)(void);
typedef void(^OrderListOrderPayNowCompletionHandler)(void);
typedef void(^OrderListOrderTrakingInfoCompletionHandler)(void);
typedef void(^OrderListReviewShowCompletionHandler)(void);
typedef void(^OrderListRefundCompletionHandler)(void);
typedef void(^OrderListCODCheckAddressCompletionHandler)(void);

@interface ZFOrderListCell : UITableViewCell

@property (nonatomic, strong) MyOrdersModel     *model;

@property (nonatomic, copy) OrderListOrderBackToCartCompletionHandler           orderListOrderBackToCartCompletionHandler;
@property (nonatomic, copy) OrderListOrderPayNowCompletionHandler               orderListOrderPayNowCompletionHandler;
@property (nonatomic, copy) OrderListOrderTrakingInfoCompletionHandler          orderListOrderTrakingInfoCompletionHandler;
@property (nonatomic, copy) OrderListReviewShowCompletionHandler                orderListReviewShowCompletionHandler;
@property (nonatomic, copy) OrderListRefundCompletionHandler                    orderListRefundCompletionHandler;
@property (nonatomic, copy) OrderListCODCheckAddressCompletionHandler           orderListCODCheckAddressCompletionHandler;

@end


