//
//  ZFOfflineOrderSuccessViewController.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  线下支付成功页面控制器

#import "ZFBaseViewController.h"
#import "ZFOrderPayTools.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    ZFOfflinePayName_Boleto,
    ZFOfflinePayName_PagoEfctivo
}ZFOfflinePayName;

typedef void(^checkOrderBlock)(void);

@interface ZFOfflineOrderSuccessViewController : ZFBaseViewController

@property (nonatomic, strong) ZFOrderPayResultModel *orderResultModel;

@property (nonatomic, copy) checkOrderBlock checkOrderHandler;

@end

NS_ASSUME_NONNULL_END
