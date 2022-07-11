//
//  OSSVCategoryFiltersModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCategroySubsFilterModel.h"

@interface OSSVCategoryFiltersModel : NSObject

//@property (nonatomic, assign) NSInteger order;          // 排序号
@property (nonatomic, assign) NSInteger searchAttrID;   // 搜索项目ID
@property (nonatomic, copy) NSString *searchAttrName;   // 搜索项目名
@property (nonatomic, strong) NSArray<OSSVCategroySubsFilterModel*> *subItemValues;   // 子类集合


/// 自定义头部选中
@property (nonatomic, assign) BOOL isHeaderSelected;
@property (nonatomic, assign) BOOL isFirstShowLine;
@property (nonatomic, assign) BOOL isMultiLine;
@property (nonatomic, assign) NSInteger firstShowCounts;

@end
