//
//  CategoryVirtualViewController.h
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface CategoryVirtualViewController : ZFBaseViewController
/**
 * 参数链接
 */
@property (nonatomic, copy) NSString   *argument;

/**
 * 虚拟分类标题
 */
@property (nonatomic, copy) NSString   *virtualTitle;
/**
 * coupon使用入口带过来的参数
 */
@property (nonatomic, copy) NSString   *coupon;

@end

