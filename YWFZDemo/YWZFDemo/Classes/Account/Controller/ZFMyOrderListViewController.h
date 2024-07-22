//
//  ZFMyOrderListViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFMyOrderListViewController : ZFBaseViewController

/**结算页未支付成功: 来源订单ID*/
@property (nonatomic, copy) NSString             *sourceOrderId;

/// 客服参数
@property (nonatomic, assign) BOOL isFromChat;
@property (nonatomic, copy) void (^selectedOrderHandle)(NSString *orderSN);

@end
