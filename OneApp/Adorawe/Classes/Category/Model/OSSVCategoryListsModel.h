//
//  OSSVCategoryListsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCategoryListsModel : NSObject<YYModel>

@property (nonatomic, strong) NSArray   *goodList;      // 商品列表
@property (nonatomic, assign) NSInteger pageCount;      // 总共页面
@property (nonatomic, assign) NSInteger pageSize;       // 一个页面多少条
@property (nonatomic, assign) NSInteger page;           // 当前页面
@property (nonatomic, strong) NSArray *filteItemArray;  // 筛选选项

@end
