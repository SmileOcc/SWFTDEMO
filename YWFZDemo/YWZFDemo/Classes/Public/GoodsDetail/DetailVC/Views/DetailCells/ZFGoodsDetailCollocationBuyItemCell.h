//
//  ZFGoodsDetailCollocationBuyItemCell.h
//  ZZZZZ
//
//  Created by YW on 2019/8/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCollocationGoodsModel;

@interface ZFGoodsDetailCollocationBuyItemCell : UICollectionViewCell

+ (ZFGoodsDetailCollocationBuyItemCell *)ShowListCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCollocationGoodsModel *model;

@end
