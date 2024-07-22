//
//  ZFNewUserGoodsCCell.m
//  ZZZZZ
//
//  Created by mac on 2019/1/9.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserGoodsCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFPriceView.h"
#import "ZFBaseGoodsModel.h"
#import "ZFEnumDefiner.h"
#import "ZFLabel.h"
#import "UIImage+ZFExtended.h"
#import "ZFNewUserExclusiveModel.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"

@interface ZFNewUserGoodsCCell () <ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *activityImageView; // 活动图标
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) ZFPriceView           *priceView;
@property (nonatomic, strong) UIButton              *discountTabView;// 折扣icon和自营销标签
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *textBackgroundView;
@property (nonatomic, strong) UILabel *similarLabel; // 找相似

// v440 新增
@property (nonatomic, strong) UIImageView *colorTagImageView;   // 多色标
@property (nonatomic, strong) UILabel *saleTagLabel;   // 营销类型标

@end

@implementation ZFNewUserGoodsCCell
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.goodsImageView.layer yy_cancelCurrentImageRequest];
    self.goodsImageView.image = nil;
    [self.activityImageView yy_cancelCurrentImageRequest];
    self.activityImageView.image = nil;
    [self.activityImageView removeFromSuperview];
    [self.priceView clearAllData];
}

- (void)similarLabelAction {
    if (self.tapSimilarGoodsHandle) {
        self.tapSimilarGoodsHandle();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.colorTagImageView];
    [self.contentView addSubview:self.saleTagLabel];
    [self.contentView addSubview:self.discountTabView];
    [self.contentView addSubview:self.activityImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.priceView];
    [self.contentView addSubview:self.maskView];
    [self.contentView addSubview:self.textBackgroundView];
    [self.textBackgroundView addSubview:self.similarLabel];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = width / KImage_SCALE;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.colorTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10.0f);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(7.0f);
        make.width.height.mas_equalTo(22.0f);
    }];
    
    [self.saleTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(13.0);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-13.0);
        make.height.mas_equalTo(24.0);
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom).offset(-7.0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.goodsImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(30);
    }];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(-24);
    }];
    
    [self.discountTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_top).offset(4);
        make.trailing.mas_equalTo(self.goodsImageView.mas_trailing);
        make.height.mas_equalTo(16);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(self.goodsImageView);
    }];
    
    //    NSString *localeLanguageCode = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    //    CGFloat margin = [localeLanguageCode hasPrefix:@"es"] ? 4.0f : 12.0f;
    
    [self.textBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(72.0);
        make.centerY.mas_equalTo(self.goodsImageView.mas_centerY);
        make.centerX.mas_equalTo(self.goodsImageView.mas_centerX);
    }];
    
    [self.similarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(self.textBackgroundView);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.similarLabel.layer.cornerRadius = self.similarLabel.height / 2;
}

#pragma mark - setter
- (void)setGoodsModel:(ZFNewUserExclusiveGoodsListModel *)goodsModel {
    _goodsModel = goodsModel;

    [self.goodsImageView.layer removeAnimationForKey:@"fadeAnimation"];
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.goodsImg]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionAvoidSetImage
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                     if (image && stage == YYWebImageStageFinished) {
                                         self.goodsImageView.image = image;
                                         if (from != YYWebImageFromMemoryCacheFast) {
                                             CATransition *transition = [CATransition animation];
                                             transition.duration = KImageFadeDuration;
                                             transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                             transition.type = kCATransitionFade;
                                             [self.goodsImageView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                         }
                                     }
                                 }];

    if (!ZFIsEmptyString(_goodsModel.activityIcon)) {
        self.discountTabView.hidden = YES;
        self.activityImageView.hidden = NO;
        [self.activityImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.activityIcon]
                                       placeholder:ZFImageWithName(@"index_loading")
                                           options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                            [self.contentView addSubview:self.activityImageView];
                                            [self.activityImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                                                make.top.mas_equalTo(self.goodsImageView.mas_top);
                                                make.trailing.mas_equalTo(self.goodsImageView.mas_trailing);
                                                make.size.mas_equalTo(CGSizeMake(60, 40));
                                            }];
                                        }];
    } else{
        self.discountTabView.hidden = YES;
        self.activityImageView.hidden = YES;
    }
    
    self.titleLabel.text = _goodsModel.goodsTitle;
    self.priceView.model = [self adapterModel:goodsModel];
    
}

- (ZFBaseGoodsModel *)adapterModel:(ZFNewUserExclusiveGoodsListModel *)goodsModel {
    ZFBaseGoodsModel *model     = [[ZFBaseGoodsModel alloc] init];
    model.shopPrice             = goodsModel.userPrice;
    model.marketPrice           = goodsModel.marketPrice;
    return model;
}

#pragma mark - getter

- (UIButton *)discountTabView{
    if (!_discountTabView) {
        _discountTabView = [UIButton buttonWithType:UIButtonTypeCustom];
        _discountTabView.backgroundColor = ZFC0xFE5269();
        _discountTabView.layer.cornerRadius = 2;
        _discountTabView.layer.masksToBounds = YES;
//        [_discountTabView setBackgroundImage:[[[UIImage imageNamed:@"topbg"] imageWithColor:ZFC0xFE5269()] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        _discountTabView.titleLabel.font = [UIFont systemFontOfSize:12];
        [_discountTabView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _discountTabView.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    }
    return _discountTabView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
    }
    return _goodsImageView;
}

- (YYAnimatedImageView *)activityImageView {
    if (!_activityImageView) {
        _activityImageView = [[YYAnimatedImageView alloc] init];
        _activityImageView.hidden = YES;
    }
    return _activityImageView;
}

- (ZFPriceView *)priceView {
    if (!_priceView) {
        _priceView = [[ZFPriceView alloc] init];
//        @weakify(self)
//        _priceView.CollectCompletionHandler = ^(BOOL collect) {
//            @strongify(self)
//            if (self.cancleCollectHandler) {
//                self.cancleCollectHandler(self.goodsModel);
//            }
//        };
    }
    return _priceView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.hidden = YES;
        _maskView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.5];
    }
    return _maskView;
}

- (UIView *)textBackgroundView {
    if (!_textBackgroundView) {
        _textBackgroundView = [[UIView alloc] init];
        _textBackgroundView.hidden          = YES;
        _textBackgroundView.backgroundColor = [UIColor clearColor];
        _textBackgroundView.layer.cornerRadius = 72.0 / 2;
        _textBackgroundView.layer.masksToBounds    = YES;
        _textBackgroundView.userInteractionEnabled = YES;
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(0.0, 0.0, 72.0, 72.0);
        [_textBackgroundView.layer insertSublayer:gradientLayer atIndex:1];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithHex:0xFFB11B].CGColor, (__bridge id)[UIColor colorWithHex:0xFF6935].CGColor];
        
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
    }
    return _textBackgroundView;
}

- (UILabel *)similarLabel {
    if (!_similarLabel) {
        _similarLabel = [[UILabel alloc] init];
        _similarLabel.textAlignment   = NSTextAlignmentCenter;
        _similarLabel.textColor       = [UIColor colorWithHex:0xffffff];
        _similarLabel.font            = [UIFont systemFontOfSize:14.0f];
        _similarLabel.text            = ZFLocalizedString(@"cart_unline_findsimilar_tag", nil);
        _similarLabel.numberOfLines   = 0;
        _similarLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture   = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(similarLabelAction)];
        [_similarLabel addGestureRecognizer:tapGesture];
    }
    return _similarLabel;
}

- (UIImageView *)colorTagImageView {
    if (!_colorTagImageView) {
        _colorTagImageView = [[UIImageView alloc] init];
        _colorTagImageView.image = [UIImage imageNamed:@"goods_list_morecolor"];
        _colorTagImageView.hidden = YES;
    }
    return _colorTagImageView;
}

- (UILabel *)saleTagLabel {
    if (!_saleTagLabel) {
        _saleTagLabel                 = [[UILabel alloc] init];
        _saleTagLabel.textColor       = [UIColor colorWithHex:0x2D2D2D];
        _saleTagLabel.font            = [UIFont systemFontOfSize:12.0];
        _saleTagLabel.textAlignment   = NSTextAlignmentCenter;
        _saleTagLabel.backgroundColor = [UIColor  colorWithHex:0xFFFFFF alpha:0.9];
        _saleTagLabel.hidden = YES;
    }
    return _saleTagLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        _titleLabel.textColor = ZFC0x666666();
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

@end
