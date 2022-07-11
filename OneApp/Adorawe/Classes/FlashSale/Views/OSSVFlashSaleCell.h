//
//  OSSVFlashSaleCell.h
// XStarlinkProject
//
//  Created by odd on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVFlashSaleProgressView.h"
#import "OSSVDetailsHeaderActivityStateView.h"
#import "OSSVFlashSaleGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol OSSVFlashSaleCellDelegate;

@interface OSSVFlashSaleCell : UICollectionViewCell

@property (nonatomic, strong) UIView *cellBgView;
@property (nonatomic, strong) YYAnimatedImageView *productImgView;
@property (nonatomic, strong) UILabel     *soldOutLabel;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *priceLabel;
@property (nonatomic, strong) UILabel     *oldPirceLabel;
@property (nonatomic, strong) UILabel     *progressLabel;
@property (nonatomic, strong) UIButton    *addButton;
@property (nonatomic, strong) UIImageView *addImageView;
@property (nonatomic, strong) UILabel     *productDetailLabel;
@property (nonatomic, strong) UILabel     *userCountLabel;
@property (nonatomic, strong) YYAnimatedImageView *soldOutImageView;
@property (nonatomic, strong) UIView      *soldOutBgView; //售空背景
@property (nonatomic, weak)   id<OSSVFlashSaleCellDelegate>delegate;
@property (nonatomic, strong) OSSVFlashSaleProgressView *progressView;
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView *activityStateView;

@property (nonatomic, strong) OSSVFlashSaleGoodsModel  *model;

@end

@protocol OSSVFlashSaleCellDelegate <NSObject>

@optional
- (void)selectedIndexButton:(UIButton *)sender;
@end

NS_ASSUME_NONNULL_END
