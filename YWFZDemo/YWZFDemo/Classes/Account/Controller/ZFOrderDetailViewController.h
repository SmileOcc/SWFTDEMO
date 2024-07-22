//
//  ZFOrderDetailViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
@class OrderDetailOrderModel;

typedef void(^ZFOrderDetailReloadListInfoCompletionHandler)(OrderDetailOrderModel *statusModel);

@interface ZFOrderDetailViewController : ZFBaseViewController
@property (nonatomic, copy) NSString            *orderId;
@property (nonatomic, copy) NSString            *contactLinkUrl;

@property (nonatomic, copy) ZFOrderDetailReloadListInfoCompletionHandler        orderDetailReloadListInfoCompletionHandler;

///修改地址
- (void)requestChangeAddress:(NSString *)orderSn;
///是否未付款订单，用于显示修改地址页面顶部的提示
@property (nonatomic, assign) BOOL addressNoPayOrder;

@end
