//
//  OSSVHomeFashSaleGoodsCCell.h
// OSSVHomeFashSaleGoodsCCell
//
//  Created by Kevin--Xue on 2020/11/1.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsHeaderActivityStateView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVHomeFashSaleGoodsCCell : UICollectionViewCell
@property (nonatomic, strong) YYAnimatedImageView *productImgView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *oldPriceLabel;

////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@end

NS_ASSUME_NONNULL_END
