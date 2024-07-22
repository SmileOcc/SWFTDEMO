//
//  ZFCMSSkuBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "ZFGoodsModel.h"

@class ZFCMSItemModel, ZFCMSAttributesModel;

/**cms组件平铺商品*/
@interface ZFCMSSkuBannerCell : UICollectionViewCell

+ (ZFCMSSkuBannerCell *)reusableSkuBannerCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSAttributesModel  *attributes;

@property (nonatomic, strong) ZFCMSItemModel        *itemModel;

@property (nonatomic, strong) UIColor               *cellBackgroundColor;

@property (nonatomic, strong) YYAnimatedImageView   *goodsImageView;


@end
