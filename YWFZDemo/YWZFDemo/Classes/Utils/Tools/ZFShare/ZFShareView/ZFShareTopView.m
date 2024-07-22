//
//  ZFShareTopView.m
//  HyPopMenuView
//
//  Created by YW on 7/8/17.
//  Copyright © 2017年 ZZZZZ. All rights reserved.
//

#import "ZFShareTopView.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"

#define kW [UIScreen mainScreen].bounds.size.width
#define kScale      kW / 375.0
static CGFloat kCornerRadius = 8.0f;

@interface ZFShareTopView ()
@property (nonatomic, strong) UIView                 *contentView;
@property (nonatomic, strong) UIImageView            *topImageView;
@property (nonatomic, strong) YYLabel                *titleLabel;
@property (nonatomic, strong) UIImage                *defaultImage;

@property (nonatomic, assign) ZFShareDefaultTipType  defaultType;
@property (nonatomic, copy) NSString                 *imageName;
@property (nonatomic, copy) NSString                 *title;

@end

@implementation ZFShareTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    [self cutCornerRadiuWithRect:self.bounds view:self.contentView rectCorners:UIRectCornerAllCorners];
    
    CGRect topImageViewRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds));
    self.topImageView.frame = topImageViewRect;
    [self cutCornerRadiuWithRect:topImageViewRect view:self.topImageView rectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    
    CGFloat kTitleLabelX = 16 * kScale;
    CGFloat kTitleLabelY = CGRectGetMaxY(self.topImageView.frame) + 20;
    CGFloat kTitleLabelW = CGRectGetWidth(self.bounds) - 32;
    CGFloat kTitleLabelH = 45 * kScale;
    self.titleLabel.frame = CGRectMake(kTitleLabelX, kTitleLabelY, kTitleLabelW, kTitleLabelH);
}

- (void)initSubViews {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.topImageView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)cutCornerRadiuWithRect:(CGRect)rect
                          view:(UIView *)targetView
                   rectCorners:(UIRectCorner)rectCorners {

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:rectCorners cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)];
    CAShapeLayer *shapelayer = [CAShapeLayer layer];
    shapelayer.frame = rect;
    shapelayer.path = bezierPath.CGPath;
    targetView.layer.mask = shapelayer;
    
    // 加一个投影
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowColor = ZFCOLOR(153, 153, 153, 1).CGColor;
    self.layer.shadowRadius = 20.0f;
    self.layer.shadowOffset = CGSizeMake(0,5);
    self.layer.shadowOpacity = 0.5;
}

#pragma amrk -

- (void)updateImage:(NSString *)imageName
              title:(NSString *)title
            tipType:(ZFShareDefaultTipType)tipType {
    
    self.defaultType = tipType;
    self.title = [self currentDefaultTitle:title];
    self.defaultImage = [self currentDefaultPlaceImage];
    self.imageName = [self currentDefaultImageUrl:imageName];
    self.titleLabel.text = self.title;
    
    [self.topImageView yy_setImageWithURL:[NSURL URLWithString:self.imageName]
                              placeholder:_defaultImage
                                  options:YYWebImageOptionAvoidSetImage
                               completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                   if (image && stage == YYWebImageStageFinished) {
                                       int width = image.size.width;
                                       int height = image.size.height;
                                       CGFloat scale = (height / width) / (self.topImageView.size.height / self.topImageView.size.width);
                                       if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                                           self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
                                           self.topImageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                                       } else { // 高图只保留顶部
                                           self.topImageView.contentMode = UIViewContentModeScaleToFill;
                                           self.topImageView.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                                       }
                                       self.topImageView.image = image;
                                   }
                               }];
}
- (NSString *)currentDefaultImageUrl:(NSString *)imageName {
    if (ZFIsEmptyString(imageName)) {
        if (self.defaultType == ZFShareDefaultTipTypeCommunityAccount) {
            // 社区个人中心分享默认图地址
            imageName = ZFCommutryAccountShareImageUrl;
        } else if(self.defaultType == ZFShareDefaultTipTypeCommunity) {
            // 社区分享默认图地址
            imageName = ZFCommutryShareImageUrl;
        } else {
            // 分享默认图片地址
            imageName = ZFShareImageDefaultUrl;
        }
    }
    return imageName;
}

- (UIImage *)currentDefaultPlaceImage {
    //暂时未改
    UIImage *defaultImg;
    if (self.defaultType == ZFShareDefaultTipTypeCommunityAccount) {
        defaultImg = ZFImageWithName(@"index_loading");
    } else {
        defaultImg = ZFImageWithName(@"index_loading");
    }
    return defaultImg;
}

- (NSString *)currentDefaultTitle:(NSString *)title{
    if (ZFIsEmptyString(title)) {
        title = ZFLocalizedString(@"native_banner_share", nil);
    }
    return title;
}

#pragma mark - Getter

- (UIView *)contentView {
    if(!_contentView){
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topImageView.clipsToBounds = YES;
    }
    return _topImageView;
}

- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds) - 32;
        _titleLabel.text = ZFLocalizedString(@"native_banner_share", nil);
    }
    return _titleLabel;
}

@end
