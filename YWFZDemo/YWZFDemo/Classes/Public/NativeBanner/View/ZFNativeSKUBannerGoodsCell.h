//
//  ZFNativeSKUBannerGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ZFViewControllerCategorySet.h"

@interface ZFNativeSKUBannerGoodsCell : UICollectionViewCell

+ (ZFNativeSKUBannerGoodsCell *)SKUGoodsListCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFGoodsModel    *goodsModel;
@property (nonatomic, strong) UIImageView     *goodsImageView;

@property (nonatomic, assign) BOOL            isShowViewMore;

@end
