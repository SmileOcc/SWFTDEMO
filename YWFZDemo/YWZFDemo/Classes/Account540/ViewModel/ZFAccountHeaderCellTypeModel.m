//
//  ZFAccountHeaderCellTypeModel.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountHeaderCellTypeModel.h"
#import "ZFAccountHeaderImportFiles.h"

@implementation ZFAccountHeaderCellTypeModel

/**
 * 获取个人中心页面所有的Cell类型
 */
+ (NSArray *)fetchAllCellTypeArray
{
    return @[@{ @(AccountHeaderCategoryItemCellType)    : [ZFAccountCategoryItemCell class]},
             @{ @(AccountHeaderUnpaidOrderCellType)     : [ZFAccountUnpaidOrderCell class]},
             @{ @(AccountHeaderCMSBannerCellType)       : [ZFAccountCMSBannerCell class]},
             @{ @(AccountHeaderHorizontalScrollCellType): [UITableViewCell class]},
             ];
}


@end
