//
//  CategoryRefineCellModel.h
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CategoryRefineCellModel : NSObject

/**
 * 属性id
 */
@property (nonatomic, copy) NSString   *attrID;

/**
 * 属性名
 */
@property (nonatomic, copy) NSString   *name;

/**
 * 属性颜色 hex
 */
@property (nonatomic, copy) NSString   *color_code;

/**
 * 数量
 */
@property (nonatomic, copy) NSString   *count;


/// 价格类型才有
@property (nonatomic, assign) NSInteger min;

/// 价格类型才有
@property (nonatomic, assign) NSInteger max;

/**
 * 标记已选的属性
 */
@property (nonatomic, assign) BOOL   isSelect;

@property (nonatomic, assign) CGSize itemsSize; ///内容大小: 非服务端返回

///自定义价格类型
@property (nonatomic, assign) BOOL typePrice;
///自定义价格编辑 大小
@property (nonatomic, copy) NSString *editMin;
@property (nonatomic, copy) NSString *editMax;

@property (nonatomic, copy) NSString *localCurrencyMin;
@property (nonatomic, copy) NSString *localCurrencyMax;


@property (nonatomic, copy) NSString *editName;




@end
