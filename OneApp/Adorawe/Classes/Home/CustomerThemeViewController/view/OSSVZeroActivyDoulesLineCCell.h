//
//  OSSVZeroActivyDoulesLineCCell.h
// OSSVZeroActivyDoulesLineCCell
//
//  Created by Starlinke on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVThemeZeroPrGoodsModel.h"

@class OSSVZeroActivyDoulesLineCCell;
@class STLThemeZeorDoubleGoodsItemCell;

NS_ASSUME_NONNULL_BEGIN

#define kThemeZeorGoodsDoubleLinesItemWidth (SCREEN_WIDTH - 12 - 3*8) / 3.5
#define kThemeZeorGoodsDoubleLinesItemHeight kThemeZeorGoodsDoubleLinesItemWidth * 156 / 96
#define kThemeZeorGoodsDoubleLinesImageHeightScale   90.0 / 90.0

@protocol STLThemeZeorActivityDoubleLinesCCellDelegate <CollectionCellDelegate>

-(void)stl_themeZeorActivityDoubleCCell:(OSSVZeroActivyDoulesLineCCell *)zeorActivityCCell selectItemCell:(STLThemeZeorDoubleGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore;
-(void)stl_themeZeorActivityDoubleCCell:(OSSVZeroActivyDoulesLineCCell *)zeorActivityCCell selectItemCell:(STLThemeZeorDoubleGoodsItemCell *)goodsItemCell addCart:(OSSVThemeZeroPrGoodsModel *)model;

@end

@interface OSSVZeroActivyDoulesLineCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>
@property (nonatomic, weak) id<STLThemeZeorActivityDoubleLinesCCellDelegate> delegate;
@property (nonatomic, strong) UICollectionView                        *collectionView;

+ (CGSize)itemSize:(NSInteger)count;
@end


@interface STLThemeZeorDoubleGoodsItemCell : UICollectionViewCell

@property (nonatomic, strong) OSSVThemeZeroPrGoodsModel *model;

@property (nonatomic, assign) BOOL isMore;

@property (nonatomic, copy) void (^cartBlock)();

- (void)updateModel:(OSSVThemeZeroPrGoodsModel *)model isMore:(BOOL)isMore;

+ (CGSize)itemSize;

- (void)updateLastCellWithHidden:(BOOL)ishidden;

@end

NS_ASSUME_NONNULL_END
