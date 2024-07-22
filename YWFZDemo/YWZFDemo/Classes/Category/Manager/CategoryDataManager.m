//
//  CategoryDataManager.m
//  ListPageViewController
//
//  Created by YW on 10/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryDataManager.h"
#import "CategoryNewModel.h"

static NSString *const kGBCategoryDataPath        = @"/Library/AllCategory.dat";
static NSString *const kGBVirtualCategoryDataPath = @"/Library/VirtualCategory.dat";


@implementation CategoryDataManager {
    NSString *_categoryRootKey;
    NSMutableDictionary *_categoryMap;
    
}

+ (instancetype)shareManager {
    static CategoryDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager->_categoryMap   = [NSMutableDictionary dictionary];
    });
    return manager;
}

- (void)parseCategoryData:(NSArray<CategoryNewModel *> *)categoryArray {
    
    if (!categoryArray) {
        return;
    }
    
    [self saveLocalCategoryListWithArray:categoryArray];
    
    [_categoryMap removeAllObjects];
    
    [categoryArray enumerateObjectsUsingBlock:^(CategoryNewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if ([self->_categoryMap valueForKey:obj.parent_id]) {
                NSMutableArray *subLevelArray = self->_categoryMap[obj.parent_id];
                [subLevelArray addObject:obj];
                [self->_categoryMap setValue:subLevelArray forKey:obj.parent_id];
            }else{
                NSMutableArray *subLevelArray = [NSMutableArray array];
                [subLevelArray addObject:obj];
                [self->_categoryMap setValue:subLevelArray forKey:obj.parent_id];
            }
        }
    }];
    
    _categoryRootKey = @"0";
}


-(NSArray<CategoryNewModel *> *)queryRootCategoryData {
    if ([self hasCacheCategoryData]) {
        [self parseCategoryData:[self getLocalCategoryList]];
    }
   return  _categoryMap[_categoryRootKey];
}


-(NSArray<CategoryNewModel *> *)querySubCategoryDataWithParentID:(NSString *)catID {
    if ([self hasCacheCategoryData]) {
        [self parseCategoryData:[self getLocalCategoryList]];
    }
    return _categoryMap[catID];
}

- (NSArray<CategoryNewModel *> *)getLocalCategoryList {
    NSString *categoryPath;
    if (_isVirtualCategory) {
        categoryPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),kGBVirtualCategoryDataPath];
    }else{
        categoryPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),kGBCategoryDataPath];
    }
    NSArray *allCategory = [NSKeyedUnarchiver unarchiveObjectWithFile:categoryPath];
    return allCategory;
}

- (BOOL)hasCacheCategoryData {
    NSArray *dataArray = [self getLocalCategoryList];
    return dataArray.count > 0 ? YES : NO;
}

- (void)saveLocalCategoryListWithArray:(NSArray<CategoryNewModel *> *)categoryList {
    NSString *categoryPath;
    if (_isVirtualCategory) {
        categoryPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),kGBVirtualCategoryDataPath];
    }else{
        categoryPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),kGBCategoryDataPath];
    }
    BOOL isLocal = [NSKeyedArchiver archiveRootObject:categoryList toFile:categoryPath];
    if (!isLocal) { //第一次本地化数据失败，重新进行本地化，若再失败则不管。
        [NSKeyedArchiver archiveRootObject:categoryList toFile:categoryPath];
    }
}




@end
