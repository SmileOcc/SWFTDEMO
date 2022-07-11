//
//  OSSVThemeGoodsItesRankCCell.h
// OSSVThemeGoodsItesRankCCell
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVThemeItemsGoodsRanksCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

//首页banner
@class OSSVThemeGoodsItesRankCCell;

@protocol STLThemeGoodsRankCCellDelegate<CollectionCellDelegate>

- (void)stl_themeGoodsRankCCell:(OSSVThemeGoodsItesRankCCell *)cell addCart:(STLHomeCGoodsModel *)model ;// 增加到购物车
- (void)stl_themeGoodsRankCCell:(OSSVThemeGoodsItesRankCCell *)cell addWishList:(STLHomeCGoodsModel *)model ;// 增加到/取消收藏

@end

///功能注释：排行商品
@interface OSSVThemeGoodsItesRankCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, weak) id<STLThemeGoodsRankCCellDelegate> delegate;

-(void)setHomeGoodsModel:(STLHomeCGoodsModel *)model;

@property (nonatomic, strong) UIButton                *addCartButton;
@property (nonatomic, strong) UILabel                 *hotNumLabel;
@property (nonatomic, strong) UILabel                 *favourNumLabel;
@property (nonatomic, strong) YYAnimatedImageView     *goodsImageView;

@property (nonatomic, strong) UIView                  *bgView;
@end

NS_ASSUME_NONNULL_END
