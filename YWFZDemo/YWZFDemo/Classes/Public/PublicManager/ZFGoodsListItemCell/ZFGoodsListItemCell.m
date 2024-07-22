//
//  ZFGoodsListItemCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsListItemCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsModel.h"
#import "ZFPriceView.h"
#import "ZFBaseGoodsModel.h"
#import "ZFEnumDefiner.h"
#import "ZFLabel.h"
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsListCountDownView.h"
#import "ZFGoodsListColorBlockView.h"
#import "ZFAppsflyerAnalytics.h"

CGFloat const kSimilarHeight = 36.0f;
@interface ZFGoodsListItemCell () <ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *activityImageView; // 活动图标
@property (nonatomic, strong) ZFPriceView           *priceView;
@property (nonatomic, strong) UIButton              *discountTabView;// 折扣icon和自营销标签
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *textBackgroundView;
@property (nonatomic, strong) UILabel *similarLabel; // 找相似

// v440 新增
@property (nonatomic, strong) UIImageView *colorTagImageView;   // 多色标
@property (nonatomic, strong) UILabel *saleTagLabel;   // 营销类型标

@property (nonatomic, strong) ZFGoodsListCountDownView *countDownView;  // 倒计时
@property (nonatomic, strong) UIImageView *boardImageView;  // 打板商品标签

@property (nonatomic, strong) MASConstraint *priceViewHeightCons;

@end

@implementation ZFGoodsListItemCell
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
    [self.goodsImageView.layer yy_cancelCurrentImageRequest];
    self.goodsImageView.image = nil;
    [self.activityImageView yy_cancelCurrentImageRequest];
    self.activityImageView.image = nil;
    self.selectedGoodsModel = nil;
    [self.activityImageView removeFromSuperview];
    [self.priceView clearAllData];
    [super prepareForReuse];
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
    [self.contentView addSubview:self.priceView];
    [self.contentView addSubview:self.maskView];
    [self.contentView addSubview:self.textBackgroundView];
    [self.contentView addSubview:self.countDownView];
    [self.contentView addSubview:self.boardImageView];
    [self.textBackgroundView addSubview:self.similarLabel];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = width / KImage_SCALE;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.goodsImageView);
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
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.goodsImageView.mas_bottom).offset(12);
        self.priceViewHeightCons = make.bottom.mas_equalTo(-24);
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
    
    [self.boardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView.mas_leading).offset(10);
        make.top.mas_equalTo(self.goodsImageView.mas_top).offset(10);
        make.height.width.mas_equalTo(24);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.similarLabel.layer.cornerRadius = self.similarLabel.height / 2;
}

#pragma mark - setter
- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    // 优先级: 倒计时 > 营销标签 > 打板商品标签
    if ([goodsModel.countDownTime integerValue] > 0) {
        self.countDownView.hidden = NO;
        [self.countDownView startTimerWithStamp:goodsModel.countDownTime timerKey:[NSString stringWithFormat:@"GoodsList_%@", goodsModel.goods_id]];
    } else {
        self.countDownView.hidden = YES;
    }
    
    // 打板标签
    self.boardImageView.hidden = !goodsModel.is_making;
    
    self.priceView.model = [self adapterModel:goodsModel];

    if (goodsModel.groupGoodsList.count > 1 && goodsModel.groupGoodsList.count > goodsModel.selectedColorIndex) {
        // 显示色块图片
        self.priceViewHeightCons.mas_equalTo(-10);
        self.selectedGoodsModel = goodsModel.groupGoodsList[goodsModel.selectedColorIndex];
        self.priceView.goodsModel = goodsModel;
    }  else {
        self.priceViewHeightCons.mas_equalTo(-24);
        self.priceView.goodsModel = nil;
        [self.goodsImageView.layer removeAnimationForKey:@"fadeAnimation"];
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.wp_image]
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
    }
    
    /** v3.6.0 右上角icon：收藏页面不能显示 活动氛围标>折扣icon>自营销标签 */
    if (!_goodsModel.hiddenTag) {
        /** v3.6.0 右上角icon标优先级: 活动氛围标>折扣icon>自营销标签 */
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
        }else if ([_goodsModel.promote_zhekou floatValue] >= 50.0){ /** 折扣大于50%显示 */
            self.discountTabView.hidden = NO;
            self.activityImageView.hidden = YES;
            [self.discountTabView setTitle:[NSString stringWithFormat:@"-%@%%",_goodsModel.promote_zhekou] forState:UIControlStateNormal];
        }else if ([_goodsModel.channel_type intValue] == ZFMarketingTagTypeHot ||[_goodsModel.channel_type intValue] == ZFMarketingTagTypePopular || [_goodsModel.channel_type intValue] == ZFMarketingTagTypeNew){
            
            self.discountTabView.hidden = NO;
            self.activityImageView.hidden = YES;
            NSString *marketingTagString = @"";//自营销标签名字
            if ([_goodsModel.channel_type intValue] == ZFMarketingTagTypeHot) {
                marketingTagString = ZFLocalizedString(@"HOT", nil);
            }else if ([_goodsModel.channel_type intValue] == ZFMarketingTagTypePopular){
                marketingTagString = ZFLocalizedString(@"POPULAR", nil);
            }else if ([_goodsModel.channel_type intValue] == ZFMarketingTagTypeNew){
                marketingTagString = ZFLocalizedString(@"NEW", nil);
            }
            [self.discountTabView setTitle:marketingTagString forState:UIControlStateNormal];
        }else{
            self.discountTabView.hidden = YES;
            self.activityImageView.hidden = YES;
        }
    }else{
        self.discountTabView.hidden = YES;
        self.activityImageView.hidden = YES;
    }
    
    self.textBackgroundView.hidden = !(goodsModel.is_similar && goodsModel.is_disabled);
    self.maskView.hidden = !(goodsModel.is_similar && goodsModel.is_disabled);
    
    // 是否为失效商品,要显示slod out 标签
    self.priceView.isInvalidGoods = (goodsModel.is_similar && goodsModel.is_disabled);
    
//    if (self.isNewABText) {
//        self.colorTagImageView.hidden = !goodsModel.same_color;
//        self.saleTagLabel.hidden = !([goodsModel.sale_type length] > 0);
//        self.saleTagLabel.text = goodsModel.sale_type;
//        self.priceView.isPriceHighlight = ([goodsModel.sale_type length] > 0);
//    }
}

- (ZFBaseGoodsModel *)adapterModel:(ZFGoodsModel *)goodsModel {
    ZFBaseGoodsModel *model     = [[ZFBaseGoodsModel alloc] init];
    model.shopPrice             = goodsModel.shop_price;
    model.marketPrice           = goodsModel.market_price;
    model.isHideMarketPrice     = goodsModel.isHideMarketPrice;
    model.isShowCollectButton   = goodsModel.isShowCollectButton;
    model.isCollect             = goodsModel.is_collect;
    model.isInstallment         = goodsModel.isInstallment;
    model.instalmentModel       = goodsModel.instalMentModel;
    model.tagsArray             = goodsModel.tagsArray;
    model.showColorBlock        = goodsModel.groupGoodsList.count > 1;
    model.groupGoodsList        = goodsModel.groupGoodsList;
    model.price_type            = goodsModel.price_type;
    model.RRPAttributedPriceString = goodsModel.RRPAttributedPriceString;
//    if (self.isNewABText) {
//        model.tagsArray = nil;
//        model.isHideMarketPrice = !([goodsModel.sale_type length] > 0);
//    }
    return model;
}

- (void)setSelectedGoodsModel:(ZFGoodsModel *)selectedGoodsModel {
    _selectedGoodsModel = selectedGoodsModel;
    
    [self.goodsImageView.layer removeAnimationForKey:@"fadeAnimation"];
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:selectedGoodsModel.wp_image]
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
        @weakify(self)
        _priceView.CollectCompletionHandler = ^(BOOL collect) {
            @strongify(self)
            if (self.cancleCollectHandler) {
                self.cancleCollectHandler(self.goodsModel);
            }
        };
        // 色块选择
        _priceView.colorBlockClick = ^(NSInteger index) {
            @strongify(self)
            if (self.goodsModel.groupGoodsList.count > index) {
                self.goodsModel.selectedColorIndex = index;
                self.selectedGoodsModel = self.goodsModel.groupGoodsList[index];
                // AF
                NSDictionary *values = @{
                                         @"af_content_id"       : ZFToString(self.selectedGoodsModel.goods_sn),
                                         @"af_inner_mediasource": ZFToString(self.af_inner_mediasource),
                                         @"af_sort"             : ZFToString(self.sort),
                                         @"af_changed_size_or_color" : @"1",
                                         @"af_rank" : @(self.goodsModel.af_rank)
                                         };
                [ZFAppsflyerAnalytics zfTrackEvent:@"af_impression" withValues:values];
            }
        };
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
        gradientLayer.colors = @[(__bridge id) ColorHex_Alpha(0xF69E5C, 1).CGColor, (__bridge id)ColorHex_Alpha(0xF5435B, 1).CGColor];
        
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

- (ZFGoodsListCountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFGoodsListCountDownView alloc] init];
        _countDownView.hidden = YES;
    }
    return _countDownView;
}

- (UIImageView *)boardImageView {
    if (!_boardImageView) {
        _boardImageView = [[UIImageView alloc] init];
        _boardImageView.image = [UIImage imageNamed:@"AppIcon"];
        _boardImageView.contentMode = UIViewContentModeScaleAspectFill;
        _boardImageView.layer.cornerRadius = 2;
        _boardImageView.clipsToBounds = YES;
        _boardImageView.hidden = YES;
    }
    return _boardImageView;
}

@end
