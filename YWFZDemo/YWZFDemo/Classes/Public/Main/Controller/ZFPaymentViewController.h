//
//  ZFPaymentViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/9/19.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  弹出支付页面控制器

#import "ZFBaseViewController.h"

typedef NS_ENUM(NSInteger, PaymentStatus) {
    PaymentStatusUnknown,
    PaymentStatusDone,
    PaymentStatusCancel,
    PaymentStatusFail,
};

typedef void(^ZFPaymentViewCallBackBlock)(PaymentStatus);

typedef void(^ZFPaymentViewLoadBlock)(void);

typedef void(^ZFPaymentViewFastPayCallBackBlock)(NSString *token, NSString *payId);

@interface ZFPaymentViewController : ZFBaseViewController

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) ZFPaymentViewCallBackBlock block;

@property (nonatomic, copy) ZFPaymentViewLoadBlock loadBlock;

//快捷支付回调
@property (nonatomic, copy) ZFPaymentViewFastPayCallBackBlock fastCallBackHandler;

@end
