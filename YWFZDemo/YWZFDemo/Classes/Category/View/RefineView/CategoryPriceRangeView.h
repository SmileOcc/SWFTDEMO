//
//  CategoryPriceRangeView.h
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryRefineSectionModel;

typedef void(^PriceRangeSelectedCompletionHandler)(float selectedMinimum,float selectedMaximum);

@interface CategoryPriceRangeView : UIView

@property (nonatomic, strong) CategoryRefineSectionModel   *model;

@property (nonatomic, copy) PriceRangeSelectedCompletionHandler   priceRangeSelectedCompletionHandler;

@end
