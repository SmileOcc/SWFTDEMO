//
//  ZFOrderFailureViewController.h
//  ZZZZZ
//
//  Created by DBP on 16/12/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^OrderFailureBlock)(void);

@interface ZFOrderFailureViewController : ZFBaseViewController

@property (nonatomic, copy) OrderFailureBlock orderFailureBlock;

@end

