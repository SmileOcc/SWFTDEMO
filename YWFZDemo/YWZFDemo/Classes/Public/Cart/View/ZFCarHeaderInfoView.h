//
//  ZFCarHeaderInfoView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyOrdersModel;

typedef enum : NSUInteger {
    ZFCarHeaderUI_EmptyData,
    ZFCarHeaderUI_WaitingPayment,
    ZFCarHeaderUI_ForNewUser,
} ZFCarHeaderInfoShowUIType;

typedef enum : NSUInteger {
    ZFCarHeaderAction_waitingForPayment,
    ZFCarHeaderAction_BuyAgain,
    ZFCarHeaderAction_PayButton,
    ZFCarHeaderAction_EmptyData,
    ZFCarHeaderAction_ShopWomen,
    ZFCarHeaderAction_ShopMen,
    ZFCarHeaderAction_ForNewUser,
} ZFCarHeaderInfoViewActionType;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCarHeaderInfoView : UITableViewHeaderFooterView

- (instancetype)initWithFrame:(CGRect)frame
                   showUIType:(ZFCarHeaderInfoShowUIType)showUIType
                   orderModel:(MyOrdersModel *)orderModel
        headerViewActionBlock:(void (^)(ZFCarHeaderInfoViewActionType type))headerViewActionBlock;

@end

NS_ASSUME_NONNULL_END
