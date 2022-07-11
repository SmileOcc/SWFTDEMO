//
//  OSSVAccountHeadCellTypeModel.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountHeadCellTypeModel.h"

@implementation OSSVAccountHeadCellTypeModel

/**
 * 获取个人中心页面所有的Cell类型
 */
+ (NSArray *)fetchAllCellTypeArray
{
    return @[@{ @(AccountHeaderCategoryItemCellType)    : [OSSVAccountHeadBaseCell class]},
             @{ @(AccountHeaderBannerCellType)     : [OSSVAccountHeadBaseCell class]},
             @{ @(AccountHeaderHorizontalScrollCellType): [UITableViewCell class]},
             ];
}


@end
