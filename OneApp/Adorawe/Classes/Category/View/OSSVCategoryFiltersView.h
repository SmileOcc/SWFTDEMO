//
//  OSSVCategoryFiltersView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HideRefineViewCompletionHandler)(void);

/**
 分类筛选列表
 */
@interface OSSVCategoryFiltersView : UIView

@property (nonatomic, copy) void(^resetFilter)();
@property (nonatomic, copy) void(^applyFilter)();

@property (nonatomic, copy) HideRefineViewCompletionHandler   hideRefineViewCompletionHandler;

- (void)show;
- (void)dismiss;

- (void)configFilterItems:(NSArray *)filterItems;


- (NSString *)filterPriceCondition;
//- (NSString *)minPrice;
//- (NSString *)maxPrice;
- (NSDictionary *)filterItemIDs;    // 键为筛选类型的ID，值为筛选条件的ID字符串，用半角逗号隔开
- (BOOL)isFiltered;                 // 是否属于筛选中

@end
