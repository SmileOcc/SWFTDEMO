//
//  ZFGoodsDetailOutfitsItemCell.h
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFGoodsDetailOutfitsModel;

@interface ZFGoodsDetailOutfitsItemCell : UICollectionViewCell

+ (ZFGoodsDetailOutfitsItemCell *)outfitsCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFGoodsDetailOutfitsModel *outfitsModel;

@property (nonatomic, copy) void (^itemButtonBlock)(ZFGoodsDetailOutfitsModel *outfitsModel);

@end
