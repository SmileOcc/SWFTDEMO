//
//  OSSVScrolllGoodsCCell.h
// OSSVScrolllGoodsCCell
//
//  Created by odd on 2021/3/23.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVScrollGoodsItesCCellModel.h"
#import "OSSVDiscoverBlocksModel.h"
#import "OSSVHomeCThemeModel.h"

NS_ASSUME_NONNULL_BEGIN

@class STLScrollerGoodsItemCell;
@class OSSVScrolllGoodsCCell;
@protocol STLScrollerGoodsCCellDelegate <CollectionCellDelegate>

-(void)stl_scrollerGoodsCCell:(OSSVScrolllGoodsCCell *)scrollerGoodsCCell selectItemCell:(STLScrollerGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore;

@end

///功能注释：滑动商品组件：点击任何商品，进入原生专题
@interface OSSVScrolllGoodsCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

@property (nonatomic, weak) id<STLScrollerGoodsCCellDelegate> delegate;

///首页滑动商品
@property (nonatomic, strong) OSSVDiscoverBlocksModel                  *dataSourceModels;
///原生专题滑动商品
@property (nonatomic, strong) OSSVHomeCThemeModel                      *dataSourceThemeModels;


+ (CGSize)itemSize:(CGFloat)imageScale;

+ (CGSize)subItemSize:(CGFloat)imageScale;

- (NSIndexPath *)indexPathForCell:(STLScrollerGoodsItemCell *)cell;
@end


@interface STLScrollerGoodsItemCell : UICollectionViewCell

// STLDiscoveryBlockSlideGoodsModel  HomeGoodListModel
@property (nonatomic, strong) id model;

@property (nonatomic, assign) BOOL isMore;

@property (nonatomic, copy) void (^cartBlock)();

- (void)updateModel:(id)model isMore:(BOOL)isMore;

@end
NS_ASSUME_NONNULL_END
