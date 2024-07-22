//
//  ZFFullLiveNavBarView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveNavBarView : UIView

/// 用户信息
@property (nonatomic, strong) UIControl             *userControlView;
@property (nonatomic, strong) UIImageView           *userImageView;
@property (nonatomic, strong) UILabel               *userNameLabel;
@property (nonatomic, strong) UIImageView           *eyeImageView;
@property (nonatomic, strong) UILabel               *eyeNumsLabel;
@property (nonatomic, strong) UIImageView           *userArrowImageView;
@property (nonatomic, strong) YYAnimatedImageView   *stateImageView;

/// 直播无hot
@property (nonatomic, strong) UIView                *liveStateContentView;
@property (nonatomic, strong) YYAnimatedImageView   *redDotView;
@property (nonatomic, strong) UILabel               *liveStateLabel;
@property (nonatomic, strong) UIImageView           *liveEyeImageView;
@property (nonatomic, strong) UILabel               *liveEyeNumsLabel;

/// 是否有博主信息
@property (nonatomic, assign) BOOL                  isHotBanner;
/// 是否直播中
@property (nonatomic, assign) BOOL                  isLiving;
/// 是否显示用户信息
@property (nonatomic, assign) BOOL                  isHideUserInfo;

@property (nonatomic, assign) BOOL                  isVideo;






@property (nonatomic, strong) NSNumberFormatter     *formatter;

@property (nonatomic, assign) NSInteger             eyeNums;
@property (nonatomic, copy) NSString                *userImageUrl;
@property (nonatomic, copy) NSString                *userName;




@property (nonatomic, copy) void (^actionBlock)(void);

@property (nonatomic, copy) void (^actionUserBlock)(void);

@property (nonatomic, copy) void (^actionGoodsBlock)(void);




- (void)showBackArrowAnimate:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
