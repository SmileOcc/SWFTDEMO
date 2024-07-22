//
//  ZFNewVersionSettingVC.h
//  ZZZZZ
//
//  Created by YW on 2018/7/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFNewVersionSettingVC : ZFBaseViewController

@property (nonatomic, copy) void (^saveInfoBlock)(NSString *regionName, NSString *exchangeSignAndName, NSString *selectedLanguge);

@end
