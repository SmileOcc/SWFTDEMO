//
//  ZFNativeBannerViewController.h
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//
// 跳转老原生专题

#import "ZFBaseViewController.h"

@interface ZFNativeBannerViewController : ZFBaseViewController

@property (nonatomic, copy) NSString   *specialId;     // 专题id
@property (nonatomic, copy) NSString   *specialTitle;  // 专题名称
// 来源: 供分享使用
@property (nonatomic, copy) NSString *deeplinkSource;

@end
