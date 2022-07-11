//
//  STLProductCollectionCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  显示商品信息的一种collection cell
/**
 *  图片
 *   +
 *  价格
 *   +
 *  market价格
 */

#import <UIKit/UIKit.h>
#import "OSSVHomeGoodsListModel.h"
#import "OSSVCartGoodsModel.h"

#define LabelTopBottomPadding 15
#define LabelPadding 6
#define PriceLabelHeight 12
#define MarketPriceLabelHeight 9
#define ProductImageWidth (ceilf(SCREEN_WIDTH / 3.2) - 5 * 4)
#define ProductImageHeight ceilf(ProductImageWidth * (133.0 / 100.0))

@interface OSSVPductGoodsCCell : UICollectionViewCell

@property (nonatomic, strong) OSSVHomeGoodsListModel *model;

/** 购物车模型 */
@property (nonatomic, strong) OSSVCartGoodsModel *cartGoodsModel;


@end
