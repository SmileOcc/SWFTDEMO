//
//  CategorySortSectionView.h
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CategorySortSectionViewTouchHandler)(NSString *selectTitle ,BOOL isSelect);

@interface CategorySortSectionView : UITableViewHeaderFooterView

@property (nonatomic, copy)   NSString   *sortType;

@property (nonatomic, assign) BOOL       isSelect;

@property (nonatomic, copy) CategorySortSectionViewTouchHandler   categorySortSectionViewTouchHandler;

+ (NSString *)setIdentifier;

@end
