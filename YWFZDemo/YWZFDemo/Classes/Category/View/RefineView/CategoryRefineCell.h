//
//  CategoryRefineCell.h
//  ListPageViewController
//
//  Created by YW on 3/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryRefineCellModel;

//typedef void(^ChooseRefineInfoCompletionHandler)(CategoryRefineCellModel   *model);

@interface CategoryRefineCell : UITableViewCell

+ (NSString *)setIdentifier;

@property (nonatomic, assign) BOOL       isSelect;

@property (nonatomic,strong,readonly)  UILabel           *titleLabel;

//@property (nonatomic, copy) ChooseRefineInfoCompletionHandler   chooseRefineInfoCompletionHandler;

@end
