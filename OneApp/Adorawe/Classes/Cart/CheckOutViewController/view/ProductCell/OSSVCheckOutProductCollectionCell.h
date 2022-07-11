//
//  OSSVCheckOutProductCollectionCell.h
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCartGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCheckOutProductCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView           *prodcutImage;
///<商品数量，大于2的时候显示
@property (nonatomic, strong) UILabel               *countLabel;
@property (nonatomic, strong) OSSVCartGoodsModel        *goodsModel;

@property (nonatomic, strong) UIView                         *markView;
@property (nonatomic, strong) UILabel                        *stateLabel;
@property (weak,nonatomic) UIImageView * stateImageView;
@end

NS_ASSUME_NONNULL_END
