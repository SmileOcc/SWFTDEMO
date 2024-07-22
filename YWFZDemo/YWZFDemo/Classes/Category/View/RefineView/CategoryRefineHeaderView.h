//
//  CategoryRefineHeaderView.h
//  ListPageViewController
//
//  Created by YW on 3/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryRefineDetailModel;

typedef void(^DidSelectRefineSelectInfoViewCompletionHandler)(CategoryRefineDetailModel *model);

@interface CategoryRefineHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) DidSelectRefineSelectInfoViewCompletionHandler  didSelectRefineSelectInfoViewCompletionHandler;

@property (nonatomic, strong) CategoryRefineDetailModel   *model;

+ (NSString *)setIdentifier;

@end
