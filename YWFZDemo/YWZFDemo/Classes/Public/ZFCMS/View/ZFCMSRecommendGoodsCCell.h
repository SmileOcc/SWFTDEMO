//
//  ZFCMSRecommendGoodsCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "ZFGoodsModel.h"

@class ZFCMSItemModel, ZFCMSAttributesModel;

/**cms组件推荐商品*/
@interface ZFCMSRecommendGoodsCCell : UICollectionViewCell

+ (ZFCMSRecommendGoodsCCell *)reusableRecommendGoodsCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void (^dislikeBlock)(ZFGoodsModel *goodsModel);
@property (nonatomic, copy) void (^coverShowBlock)(BOOL isShow);



@property (nonatomic, strong) UIColor               *cellBackgroundColor;
@property (nonatomic, strong) YYAnimatedImageView   *goodsImageView;

/** 默认是有：更多操作按钮(主要用于首页)*/
@property (nonatomic, assign) BOOL                  isNotNeedMoreOperate;

@property (nonatomic, strong) ZFGoodsModel          *goodsModel;

@property (nonatomic, strong) ZFCMSAttributesModel  *attributes;

- (void)showCoverMaskView:(BOOL)show;

@end

