//
//  CategoryDataManager.h
//  ListPageViewController
//
//  Created by YW on 10/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CategoryNewModel;

@interface CategoryDataManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, assign) BOOL   isVirtualCategory;

/**
 * 解析后台获取所有分类数据
 */
- (void)parseCategoryData:(NSArray<CategoryNewModel *>*)categoryArray;

/**
 * 获取所有 parent_id 为0的数据
 */
- (NSArray<CategoryNewModel *> *)queryRootCategoryData;


/**
 * 根据当前分类的 Parent_id 获取所有子类数据
 */
- (NSArray<CategoryNewModel *> *)querySubCategoryDataWithParentID:(NSString *)parentID;


@end
