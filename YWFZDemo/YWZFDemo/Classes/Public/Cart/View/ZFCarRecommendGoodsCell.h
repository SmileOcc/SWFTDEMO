//
//  ZFCarRecommendGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 2018/12/4.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCarRecommendGoodsCell : UICollectionViewCell

@property (nonatomic, strong) ZFGoodsModel  *goodsModel;

@property (nonatomic, strong) UIImageView           *iconImageView;

@end

NS_ASSUME_NONNULL_END
