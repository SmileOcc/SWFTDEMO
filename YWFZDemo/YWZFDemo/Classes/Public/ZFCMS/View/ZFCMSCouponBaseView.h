//
//  ZFCMSCouponBaseView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "QLCycleProgressView.h"
#import "ZFCMSProgressView.h"
#import "ZFLocalizationString.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFCMSSectionModel.h"

static CGFloat kCouponItemWhiteH = 16;


typedef NS_ENUM(NSInteger, ZFCMSCouponBaseState) {
    ZFCMSCouponBaseStateUnknow = -1,
    ZFCMSCouponBaseStateNormal = 0,
    ZFCMSCouponBaseStateHighlighted,
};

@interface ZFCMSCouponBaseView : UIView

@property (nonatomic, strong) ZFCMSItemModel         *itemModel;
@property (nonatomic, strong) ZFCMSSectionModel      *sectionModel;

@property (nonatomic, strong) YYAnimatedImageView    *bgImageView;
@property (nonatomic, strong) UIView                 *descContentView;
@property (nonatomic, strong) UILabel                *couponTitleLabel;
@property (nonatomic, strong) UILabel                *couponDescLabel;
@property (nonatomic, strong) UILabel                *numsPercentageLabel;


@property (nonatomic, strong) UIView                 *couponStateContentView;
@property (nonatomic, strong) UIButton               *couponStateButton;
@property (nonatomic, strong) UIImageView            *couponStateImageView;

@property (nonatomic, strong) QLCycleProgressView    *circleProgressView;
@property (nonatomic, strong) UILabel                *progressLabel;

@property (nonatomic, strong) ZFCMSLineProgressView  *horizontalProgressView;

@property (nonatomic, strong) UIView                 *lineView;
@property (nonatomic, strong) UIView                 *whiteCircleViewOne;
@property (nonatomic, strong) UIView                 *whiteCircleViewTwo;

@property (nonatomic, assign) CGSize                 contentSize;

@property (nonatomic, assign) ZFCMSCouponBaseState   couponState;

@property (nonatomic, assign) NSInteger              currencySmallFontSize;
@property (nonatomic, assign) NSInteger              titleMaxFontSize;
@property (nonatomic, assign) CGFloat                maxTitleWidth;






/** 渐变背景视图 */
@property (nonatomic, strong) UIView                *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer       *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray        *gradientLayerColors;

/** 折线图层 */
@property (nonatomic, strong) CAShapeLayer *lineChartLayer;

- (void)updateItem:(ZFCMSItemModel *)itemModel sectionModel:(ZFCMSSectionModel *)sectionModel contentSize:(CGSize )contentSize;

- (void)configurateColor:(ZFCMSItemModel *)itemModel;
@end

