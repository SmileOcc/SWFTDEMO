//
//  OSSVDetailLoadView.h
// XStarlinkProject
//
//  Created by odd on 2021/7/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailBottomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailLoadView : UIView

@property (nonatomic, strong) YYAnimatedImageView   *imageView;
@property (nonatomic, strong) YYAnimatedImageView   *secondImageView;

@property (nonatomic, strong) UIView                *priceView;
@property (nonatomic, strong) UIView                *nameView;
@property (nonatomic, strong) UIView                *activityView;
@property (nonatomic, strong) UIView                *actiVityNameView;

@property (nonatomic, strong) UIView                *attributeColorHeaderView;
@property (nonatomic, strong) UIView                *activityColorView;
@property (nonatomic, strong) UIView                *attributeSizeHeaderView;
@property (nonatomic, strong) UIView                *activitySizeView;

@property (nonatomic, strong) UIView                *transportHeaderView;
@property (nonatomic, strong) UIView                *transportDescView;

@property (nonatomic, strong) UIView                *oneView;
@property (nonatomic, strong) UIView                *twoView;
@property (nonatomic, strong) UIView                *threeView;
@property (nonatomic, strong) UIView                *fourView;

@property (nonatomic, strong) UIView                *reivewHeaderView;
@property (nonatomic, strong) UIView                *advHeaderView;
@property (nonatomic, strong) UIView                *headerView;

@property (nonatomic, strong) UIButton              *collectBtn;
@property (nonatomic, strong) UIButton              *shareBtn;

@property (nonatomic, strong) OSSVDetailBottomView     *bottomView;

@property (nonatomic, copy) NSString                *imagUrl;

@end

NS_ASSUME_NONNULL_END
