//
//  ZFUnpaidOrderAlertView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyOrdersModel;

typedef enum : NSUInteger {
    ZFCarHeaderAction_GoOrderDetail,
    ZFCarHeaderAction_CancelButton,
    ZFCarHeaderAction_PayButton,
} ZFUnpaidOrderAlertViewActionType;

typedef void(^UnpaidOrderAlertBlock)(ZFUnpaidOrderAlertViewActionType type);

NS_ASSUME_NONNULL_BEGIN

@interface ZFUnpaidOrderAlertView : UIView

+ (void)showUnpaidOrderAlertView:(MyOrdersModel *)orderModel
           unpaidOrderAlertBlock:(UnpaidOrderAlertBlock)unpaidOrderAlertBlock;

@end

NS_ASSUME_NONNULL_END
