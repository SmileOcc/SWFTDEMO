//
//  ZFNativeBannerSKUBannerCell.h
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

typedef void(^SKUBannerGoodsBlock)(ZFGoodsModel *model, NSInteger selectIndex);

@interface ZFNativeBannerSKUBannerCell : UICollectionViewCell

@property (nonatomic, strong) NSArray<ZFGoodsModel *>   *goodsList;

@property (nonatomic, copy) SKUBannerGoodsBlock   skuBannerGoodsBlock;

+ (ZFNativeBannerSKUBannerCell *)SKUBannerCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end
