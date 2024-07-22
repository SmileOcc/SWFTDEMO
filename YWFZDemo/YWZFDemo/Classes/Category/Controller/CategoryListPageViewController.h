//
//  CategoryListPageViewController.h
//  ListPageViewController
//
//  Created by YW on 1/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "CategoryNewModel.h"

@interface CategoryListPageViewController : ZFBaseViewController

@property (nonatomic, strong) CategoryNewModel   *model;

@property (nonatomic, assign) BOOL   isFromDeepLink;
@property (nonatomic, assign) BOOL   isViewAll;

@property (nonatomic, copy)   NSString                    *selectedAttrsString;
@property (nonatomic, copy)   NSString                    *price_max;
@property (nonatomic, copy)   NSString                    *price_min;
@property (nonatomic, copy)   NSString                    *currentSort; // 显示界面上的文案
@property (nonatomic, copy)   NSString                    *sortIndex; // url 返回的排序参数


@end
