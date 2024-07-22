//
//  ZFOrderDetailPaymentStatusTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailOrderModel.h"

typedef void(^ZFOrderDetailOrderTrakingInfoCompletionHandler)(void);

@interface ZFOrderDetailPaymentStatusTableViewCell : UITableViewCell
@property (nonatomic, strong) OrderDetailOrderModel             *model;
@property (nonatomic, copy) ZFOrderDetailOrderTrakingInfoCompletionHandler          orderDetailOrderTrakingInfoCompletionHandler;

@end
