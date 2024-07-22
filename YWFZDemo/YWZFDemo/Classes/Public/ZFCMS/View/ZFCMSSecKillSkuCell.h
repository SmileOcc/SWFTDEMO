//
//  ZFCMSSecKillSkuCell.h
//  ZZZZZ
//
//  Created by YW on 2019/3/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "ZFGoodsModel.h"

@class ZFCMSItemModel, ZFCMSAttributesModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSSecKillSkuCell : UICollectionViewCell

+ (ZFCMSSecKillSkuCell *)reusableSecKillSkuCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSItemModel        *itemModel;

@property (nonatomic, strong) UIColor               *cellBackgroundColor;

@property (nonatomic, strong) YYAnimatedImageView   *goodsImageView;

/**获取高度+间隙，不包含图片高度*/
+ (CGFloat)cmsVerticalHeightNoContainImage;

@end

NS_ASSUME_NONNULL_END
