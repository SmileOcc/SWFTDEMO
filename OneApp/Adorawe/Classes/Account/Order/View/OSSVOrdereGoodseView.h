//
//  OSSVOrdereGoodseView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAccounteMyOrderseGoodseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVOrdereGoodseView : UIView

@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) UIView                *goodsInfoView;
@property (nonatomic, strong) YYAnimatedImageView   *iconView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *attrLabel;
//@property (nonatomic, strong) UILabel               *priceLabel;
//@property (nonatomic, strong) UILabel               *countLabel;
@property (nonatomic,strong) NSArray<OSSVAccounteMyOrderseGoodseModel*>                *ordersGoodsList;//订单商品列表

@property (nonatomic, copy) NSString                *formated_goods_amount;

@end

NS_ASSUME_NONNULL_END
