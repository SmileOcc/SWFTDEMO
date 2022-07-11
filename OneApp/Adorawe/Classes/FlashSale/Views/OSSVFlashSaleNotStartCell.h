//
//  OSSVFlashSaleNotStartCell.h
// XStarlinkProject
//
//  Created by odd on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsHeaderActivityStateView.h"
#import "OSSVFlashSaleGoodsModel.h"

@class OSSVFlashSaleNotStartCell;
NS_ASSUME_NONNULL_BEGIN



@protocol OSSVFlashSaleNotStartCellDelegate <NSObject>

@optional
-(void)userAddReminder:(OSSVFlashSaleGoodsModel *)item sender:(UIButton *)sender cell:(OSSVFlashSaleNotStartCell *)cell;
@end

@interface OSSVFlashSaleNotStartCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *productImgView;
@property (nonatomic, strong) UIImageView *flashImgView;
@property (nonatomic, strong) UILabel     *discountLabel;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *priceLabel;
@property (nonatomic, strong) UILabel     *oldPirceLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel     *progressLabel;
@property (nonatomic, strong) UIButton    *collectButton;
@property (nonatomic, strong) UILabel     *userCountLabel;
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView *activityStateView;
@property (nonatomic, weak) id<OSSVFlashSaleNotStartCellDelegate>delegate;

@property (nonatomic, strong) OSSVFlashSaleGoodsModel  *model;

-(void)playAddAnimation;
-(void)updateFollowCount;

@property (nonatomic,copy) NSString *animateStrValue;
@end

NS_ASSUME_NONNULL_END
