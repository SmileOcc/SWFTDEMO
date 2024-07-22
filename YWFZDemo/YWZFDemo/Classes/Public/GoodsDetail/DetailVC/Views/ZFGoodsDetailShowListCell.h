//
//  ZFGoodsDetailShowListCell.h
//  ZZZZZ
//
//  Created by YW on 20/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GoodsShowExploreModel;

@interface ZFGoodsDetailShowListCell : UICollectionViewCell

+ (ZFGoodsDetailShowListCell *)ShowListCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) GoodsShowExploreModel   *model;

@end
