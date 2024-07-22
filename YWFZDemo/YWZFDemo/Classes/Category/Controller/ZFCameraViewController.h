//
//  ZFCameraViewController.h
//  ZZZZZ
//
//  Created by YW on 15/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFCameraViewController : ZFBaseViewController

@property (nonatomic, assign) BOOL isReturnSourceVC;

@property (nonatomic, copy) void (^photoBlock)(UIImage *iamge);

@property (nonatomic, copy) NSString *phtotTipString;

@end
