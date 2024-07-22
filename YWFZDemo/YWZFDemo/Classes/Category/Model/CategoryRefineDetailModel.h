//
//  CategoryRefineDetailModel.h
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryRefineCellModel.h"


@interface CategoryRefineDetailModel : NSObject
/**
 * 属性类名
 */
@property (nonatomic, copy)   NSString                               *name;
/**
 * 所有属性集合
 */
@property (nonatomic, strong) NSArray<CategoryRefineCellModel *>     *childArray;


/// 类型 v540 (service,color,size,price,clothing length,collar,pattern type,material,style)
@property (nonatomic, copy) NSString *type;



/**
 * 记录是否展开,默认关闭
 */
@property (nonatomic, assign) BOOL                                   isExpend;

/**
 * 已选属性名称集合
 */
@property (nonatomic, strong) NSMutableArray                         *selectArray;


/**
 * 上传属性集合
 */
@property (nonatomic, strong) NSMutableArray                         *attrsArray;


/// 自定义头部选中
@property (nonatomic, assign) BOOL isHeaderSelected;
@property (nonatomic, assign) BOOL isFirstShowLine;
@property (nonatomic, assign) BOOL isMultiLine;
@property (nonatomic, assign) NSInteger firstShowCounts;




- (NSString *)af_refineKeyForkType;
@end
