//
//  ZFOrderQuestionViewController.h
//  ZZZZZ
//
//  Created by YW on 2019/3/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  订单支付问卷调查视图

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZFOrderQuestionViewControllerDelegate <NSObject>

- (void)ZFOrderQuestionViewControllerDidClickBackToOrders;

- (void)ZFOrderQuestionViewControllerDidClickGontinueShopping;

@end

typedef void(^didClickBackToOrders)(void);
typedef void(^didClickShopping)(void);

@interface ZFOrderQuestionViewController : ZFBaseViewController

@property (nonatomic, copy) NSString *ordersn;

@property (nonatomic, copy) NSString *orderId;

@property (nonatomic, weak) id<ZFOrderQuestionViewControllerDelegate>delegate;

@property (nonatomic, copy) didClickBackToOrders didClickbackToOrdersBlockHandle;
@property (nonatomic, copy) didClickShopping didClickGoShoppingHandle;

@end

NS_ASSUME_NONNULL_END
