//
//  STLAttributeSheetGoodsInfoReusableView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/7.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STLCLineLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLAttributeSheetGoodsInfoReusableView : UICollectionReusableView


@property (nonatomic, strong) OSSVDetailsBaseInfoModel  *baseInfoModel;
@property (nonatomic, strong) UILabel                   *goodsTitleLabel;
@property (nonatomic, strong) UILabel                   *goodsPriceLabel;
@property (nonatomic, strong) STLCLineLabel             *grayPrice;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;
@property (nonatomic, strong) UILabel                   *detablLabel;
@property (nonatomic, strong) UIImageView               *detailArrowImageView;
@property (nonatomic, strong) UIButton                  *eventBtn;
@property (nonatomic, assign) BOOL                      isShowArrow;

@property (nonatomic, copy) void(^goodsDetailBlock)(void);

+ (STLAttributeSheetGoodsInfoReusableView *)attributeGoodsInfoViewWithCollectionView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
