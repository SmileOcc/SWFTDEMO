//
//  ZFGeshopSectionModel.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSectionModel.h"
#import "ZFGeshopThematicImportFiles.h"

#import "ZFRequestModel.h"
#import "ZFNetwork.h"
#import "YWCFunctionTool.h"
#import "YWLocalHostManager.h"
#import "ZFApiDefiner.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "UIColor+ExTypeChange.h"
#import "NSString+Extended.h"
#import "ZFAnalytics.h"

@implementation ZFGeshopSectionListModel
@end


#pragma mark - =======ZFGeshopSiftItemModel=========

@implementation ZFGeshopSiftItemModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"child_item" : [ZFGeshopSiftItemModel class]
            };
}

- (NSMutableArray<ZFGeshopSiftItemModel *> *)selectionAllChildItemArr {
    if (!_selectionAllChildItemArr) {
        _selectionAllChildItemArr = [NSMutableArray array];
    }
    return _selectionAllChildItemArr;
}
@end



#pragma mark - =======ZFGeshopPaginationModel=========

@implementation ZFGeshopPaginationModel
@end




#pragma mark - =======ZFGeshopComponentDataModel=========

@implementation ZFGeshopComponentDataModel

/** 筛选组件字段模型 */
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"category_list"   : [ZFGeshopSiftItemModel class],
        @"sort_list"       : [ZFGeshopSiftItemModel class],
        @"refine_list"     : [ZFGeshopSiftItemModel class],
        @"list"            : [ZFGeshopSectionListModel class]
    };
}
@end



#pragma mark - =======ZFGeshopComponentStyleModel=========

@implementation ZFGeshopComponentStyleModel
@end




#pragma mark - =======ZFGeshopShopPriceStyleModel=========

@implementation ZFGeshopShopPriceStyleModel
@end




#pragma mark - =======ZFGeshopDiscountStyleModel=========

@implementation ZFGeshopDiscountStyleModel
@end




#pragma mark - =======ZFGeshopSectionModel=========


@implementation ZFGeshopSectionModel

+ (NSArray<NSDictionary *> *)fetchGeshopAllCellTypeArray {
    return @[
        @{ @(ZFGeshopBaseCellType)         : [UICollectionViewCell class]} ,// 注册默认Cell
        @{ @(ZFGeshopCycleBannerCellType)  : [ZFGeshopCycleBannerCell class]} ,
        @{ @(ZFGeshopTextImageCellType)    : [ZFGeshopTextImageCell class]} ,
        @{ @(ZFGeshopNavigationCellType)   : [ZFGeshopNavigationCell class]} ,
        @{ @(ZFGeshopSiftGoodsCellType)    : [ZFGeshopSiftGoodsCell class]} ,
        @{ @(ZFGeshopGridGoodsCellType)    : [ZFGeshopGridGoodsCell class]} ,
        @{ @(ZFGeshopSecKillSuperCellType) : [ZFGeshopSecKillSuperCell class]},
    ];
}


@end
