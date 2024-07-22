//
//  ZFMyOrderListStatusHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrdersModel.h"

typedef void(^MyOrderListEnterDetailCompletionHandler)(void);
//未付款倒计时订单倒计时完成的回调
typedef void(^MyOrderListCountDownDoneBlock)(MyOrdersModel *model);

@interface ZFMyOrderListStatusHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) MyOrdersModel         *model;
@property (nonatomic, copy) MyOrderListEnterDetailCompletionHandler         myOrderListEnterDetailCompletionHandler;

@property (nonatomic, copy) MyOrderListCountDownDoneBlock countDownDoneBlock;
@end
