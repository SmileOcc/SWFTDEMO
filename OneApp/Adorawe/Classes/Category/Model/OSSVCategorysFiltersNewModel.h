//
//  OSSVCategorysFiltersNewModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLCategoryFilterValueModel;
@class STLCategoryFilterExpandValueModel;

@interface OSSVCategorysFiltersNewModel : NSObject

@property (nonatomic, copy) NSString       *name;
@property (nonatomic, copy) NSString       *key;

@property (nonatomic, strong) NSArray<STLCategoryFilterValueModel *> *values;


/// 自定义头部选中
@property (nonatomic, assign) BOOL isHeaderSelected;
@property (nonatomic, assign) BOOL isFirstShowLine;
@property (nonatomic, assign) BOOL isMultiLine;
@property (nonatomic, assign) NSInteger firstShowCounts;

/// 自定义 选中个数
@property (nonatomic, assign) NSInteger limitCount;

@end


@interface STLCategoryFilterValueModel : NSObject

@property (nonatomic, copy) NSString       *idx;
@property (nonatomic, copy) NSString       *value;
@property (nonatomic, strong) STLCategoryFilterExpandValueModel *expand_value;
@property (nonatomic, assign) BOOL         isChecked; //接口返回，1：全部选中 尺寸和 颜色
//@property (nonatomic, assign) BOOL           isSelected;    // 是否被选中
@property (nonatomic, assign) BOOL           tempSelected;
///计算内容大小
@property (nonatomic, assign) CGSize             itemsSize;
/// 拼接item_title + item_count
@property (nonatomic, copy) NSString             *editName;

///自定义
@property (nonatomic, copy) NSString             *supKey;
/// only价格
@property (nonatomic, copy) NSString *editMinPrice;
@property (nonatomic, copy) NSString *editMaxPrice;

@property (nonatomic, copy) NSString *tempEditMinPrice;
@property (nonatomic, copy) NSString *tempEditMaxPrice;

@end


@interface STLCategoryFilterExpandValueModel : NSObject

//"#000000,#cccccc"
@property (nonatomic, copy) NSString       *hex;

@end
