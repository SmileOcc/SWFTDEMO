//
//  OSSVAccountsOrderDetailVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

typedef void(^CallbackFromOrderList)(void);

@interface OSSVAccountsOrderDetailVC : STLBaseCtrl

/*接收外部传进来的参数*/
- (instancetype)initWithOrderId:(NSString*)orderId;

/*订单ID*/
@property (nonatomic,strong) NSString *orderId;

@property (nonatomic,strong) CallbackFromOrderList callback;

@end
