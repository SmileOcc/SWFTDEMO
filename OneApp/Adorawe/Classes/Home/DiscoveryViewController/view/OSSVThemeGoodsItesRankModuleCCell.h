//
//  OSSVThemeGoodsItesRankModuleCCell.h
// OSSVThemeGoodsItesRankModuleCCell
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"

#import "OSSVThemeGoodsItesRankCCell.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVScrollGoodsItesCCellModel.h"
#import "OSSVDiscoverBlocksModel.h"
#import "OSSVThemeItemGoodsRanksModuleModel.h"
#import "OSSVHomeCThemeModel.h"

NS_ASSUME_NONNULL_BEGIN

@class OSSVThemeGoodsItesRankModuleCCell;
@protocol STLThemeGoodsRankModuleCCellDelegate <CollectionCellDelegate>

-(void)stl_themeGoodsRankModuleCCell:(OSSVThemeGoodsItesRankModuleCCell *)scrollerGoodsCCell selectItemCell:(OSSVThemeGoodsItesRankCCell *)goodsItemCell isMore:(BOOL)isMore;

-(void)stl_themeGoodsRankModuleCCell:(OSSVThemeGoodsItesRankModuleCCell *)scrollerGoodsCCell selectItemCell:(OSSVThemeGoodsItesRankCCell *)goodsItemCell addMCart:(STLHomeCGoodsModel *)model;

@end

///功能注释：排行组件商品集合：一组排行商品
@interface OSSVThemeGoodsItesRankModuleCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, weak) id<STLThemeGoodsRankModuleCCellDelegate> delegate;

@property (nonatomic, strong) OSSVHomeCThemeModel                      *dataSourceModels;

@property (nonatomic, strong) UICollectionView                        *collectionView;

+ (CGSize)itemSize:(NSInteger)goodsCount;

+ (CGSize)subItemSize;
@end

NS_ASSUME_NONNULL_END
