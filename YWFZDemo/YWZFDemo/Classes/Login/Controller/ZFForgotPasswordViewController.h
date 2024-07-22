//
//  ZFForgotPasswordViewController.h
//  ZZZZZ
//
//  Created by Tsang_Fa on 2018/6/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

@class YWLoginModel;

typedef void(^Completion)(void);

@interface ZFForgotPasswordViewController : ZFBaseViewController

@property (nonatomic, strong) YWLoginModel     *model;
@property (nonatomic, copy) Completion completion;

@end
