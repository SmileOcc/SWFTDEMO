//
//  ZFCOPVIPViewController.h
//  ZZZZZ
//
//  Created by YW on 2019/3/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  开通COD VIP 控制器

#import "ZFWebViewViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^controllerDidDismiss)(void);
@interface ZFCODVIPViewController : ZFWebViewViewController

@property (nonatomic, copy) controllerDidDismiss didDismissHandle;

@end

NS_ASSUME_NONNULL_END
