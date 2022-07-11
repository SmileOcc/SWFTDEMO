//
//  STLCategoryListCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@interface OSSVCategorysListVC : STLBaseCtrl

@property (nonatomic, strong) NSString *childId;
@property (nonatomic, strong) NSString *deepLinkId;
@property (nonatomic, strong) NSString *childDetailTitle;
@property (nonatomic, assign) BOOL     isSimilar;//是相似商品列表
@property (nonatomic, strong) NSString *is_new_in;


@property (nonatomic, copy)   NSString                    *selectedAttrsString;
@property (nonatomic, copy)   NSString                    *price_max;
@property (nonatomic, copy)   NSString                    *price_min;
@property (nonatomic, copy)   NSString                    *currentSort; // 显示界面上的文案
@property (nonatomic, copy)   NSString                    *sortIndex; // url 返回的排序参数

@end
