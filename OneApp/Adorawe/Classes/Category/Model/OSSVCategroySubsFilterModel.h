//
//  OSSVCategroySubsFilterModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCategroySubsFilterModel : NSObject

//@property (nonatomic, assign) NSInteger order;         // 排序号
@property (nonatomic, assign) NSInteger searchValueID; // 搜索项目ID
@property (nonatomic, copy)   NSString  *searchValue;  // 搜索名
@property (nonatomic, assign) BOOL      isSelected;    // 是否被选中
@property (nonatomic, copy) NSString    *color_code;


@property (nonatomic, copy) NSString   *count;

///计算内容大小
@property (nonatomic, assign) CGSize             itemsSize;
/// 拼接item_title + item_count
@property (nonatomic, copy) NSString             *editName;
@end
