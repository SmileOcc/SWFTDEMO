//
//  CategoryNewModel.h
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@interface CategoryNewModel : NSObject<YYModel>
/**
 * 分类ID
 */
@property (nonatomic, copy) NSString   *cat_id;

/**
 * 父类ID
 */
@property (nonatomic, copy) NSString   *parent_id;

/**
 * 分类名
 */
@property (nonatomic, copy) NSString   *cat_name;
/**
 * 子分类列表
 */
@property (nonatomic, strong) NSArray <CategoryNewModel *> *childrenList;

/**
 * SKU检索ID
 */
@property (nonatomic, copy) NSString   *cat_featuring;

/**
 * 图片URL
 */
@property (nonatomic, copy) NSString   *cat_pic;

/**
 * 默认排序方式
 */
@property (nonatomic, copy) NSString   *default_sort;

/**
 * 是否有下一级
 */
@property (nonatomic, copy) NSString   *is_child;

/**
 * 是否展开
 */
@property (nonatomic, assign) BOOL   isOpen;

/**
 * 是否选择
 */
@property (nonatomic, assign) BOOL   isSelect;

+ (instancetype)instanceWithDic:(NSDictionary *)dic;

@end
