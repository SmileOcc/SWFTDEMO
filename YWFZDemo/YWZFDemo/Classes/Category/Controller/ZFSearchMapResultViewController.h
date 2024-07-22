//
//  ZFSearchMapResultViewController.h
//  ZZZZZ
//
//  Created by YW on 8/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFAppsflyerAnalytics.h"

@class ZFSearchImageModel;

@interface ZFSearchMapResultViewController : ZFBaseViewController

@property (nonatomic, strong) NSArray   *pageArrays;
///growingIO 统计
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, assign) NSInteger totalCount;
// 统计参数
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

@end
