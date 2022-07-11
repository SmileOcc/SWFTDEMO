//
//  OSSVThemeZeorsActivyCCell.h
// OSSVThemeZeorsActivyCCell
//
//  Created by odd on 2020/9/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVThemesZeroActivyCellModel.h"

@class STLThemeZeorGoodsItemCell;
@class OSSVThemeZeorsActivyCCell;

#define kThemeZeorGoodsItemWidth (SCREEN_WIDTH - 12 - 3*8) * 4 / 15.0
#define kThemeZeorGoodsItemHeight kThemeZeorGoodsItemWidth * 90.0 / 90.0 + 34
#define kThemeZeorGoodsImageHeightScale   90.0 / 90.0

@protocol STLThemeZeorActivityCCellDelegate <CollectionCellDelegate>

-(void)stl_themeZeorActivityCCell:(OSSVThemeZeorsActivyCCell *)zeorActivityCCell selectItemCell:(STLThemeZeorGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore;

@end

@interface OSSVThemeZeorsActivyCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>
@property (nonatomic, weak) id<STLThemeZeorActivityCCellDelegate> delegate;

+ (CGSize)itemSize:(NSInteger)count;
@end


@interface STLThemeZeorGoodsItemCell : UICollectionViewCell

@property (nonatomic, strong) OSSVThemeZeroPrGoodsModel *model;

@property (nonatomic, assign) BOOL isMore;

@property (nonatomic, copy) void (^cartBlock)();

- (void)updateModel:(OSSVThemeZeroPrGoodsModel *)model isMore:(BOOL)isMore;

+ (CGSize)itemSize;

@end


