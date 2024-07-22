//
//  ZFGeshopSecKilGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//
#import <UIKit/UIKit.h>
@class ZFGeshopSectionModel, ZFGeshopSectionListModel;

@interface ZFGeshopSecKilGoodsCell : UICollectionViewCell

+ (ZFGeshopSecKilGoodsCell *)reusableSecKillSkuCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) ZFGeshopSectionModel *sectionModel;

@end

