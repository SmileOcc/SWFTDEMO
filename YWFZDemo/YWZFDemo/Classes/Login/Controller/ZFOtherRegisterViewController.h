//
//  ZFOtherRegisterViewController.h
//  ZZZZZ
//
//  Created by YW on 28/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFRegisterModel.h"

typedef void(^RegisterHandler)(ZFRegisterModel *model);

@interface ZFOtherRegisterViewController : ZFBaseViewController

@property (nonatomic, strong) ZFRegisterModel   *model;

@property (nonatomic, copy) RegisterHandler   registerHandler;

@end
