//
//  ZFGeshopSiftPopListView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDataManager.h"

@class ZFGeshopSectionModel, ZFGeshopSiftItemModel;

// 新版分类
typedef NS_ENUM(NSInteger, ZFCategoryColumnDataType) {
    ZFCategoryColumn_CategoryType = 2019,
    ZFCategoryColumn_SortType,
    ZFCategoryColumn_RefineType
};

@interface ZFGeshopSiftPopListView : UIView


@property (nonatomic, copy) void(^selectedCategoryBlock)(ZFGeshopSiftItemModel *);

@property (nonatomic, copy) void(^categoryCompletionAnimation)(BOOL isShow);

@property (nonatomic, assign, readonly) ZFCategoryColumnDataType dataType;

- (void)setCategoryData:(ZFGeshopSectionModel *)sectionModel
               dataType:(ZFCategoryColumnDataType)dataType;

- (void)openCategoryListView;

- (void)dismissCategoryListView;

@end
