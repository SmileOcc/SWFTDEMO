//
//  ZFSearchMapPageViewController.h
//  ZZZZZ
//
//  Created by YW on 23/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "WMPageController.h"
#import "ZFAppsflyerAnalytics.h"

@interface ZFSearchMapPageViewController : WMPageController

@property (nonatomic, strong) UIImage   *sourceImage;
// 统计参数
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

@end
