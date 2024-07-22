//
//  ZFCommunityLiveVideoGoodsCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoGoodsCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFullLiveTryOnView.h"

@interface ZFCommunityLiveVideoGoodsCCell()<ZFInitViewProtocol>

@property (nonatomic, strong) YYAnimatedImageView   *goodImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) UILabel               *grayPriceLabel;
@property (nonatomic, strong) UIButton              *similarButton;

@property (nonatomic, strong) UIButton              *cartButton;
@property (nonatomic, strong) UIView                *stateView;
@property (nonatomic, strong) UILabel               *stateLabel;
@property (nonatomic, strong) UIView                *bottomLineView;

@property (nonatomic, strong) ZFFullLiveTryOnView   *tryOnView;



@end

@implementation ZFCommunityLiveVideoGoodsCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


- (void)zfInitView {
    [self.contentView addSubview:self.goodImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.grayPriceLabel];
    
    [self.contentView addSubview:self.tryOnView];

    [self.contentView addSubview:self.similarButton];
    [self.contentView addSubview:self.cartButton];
    
    [self.contentView addSubview:self.stateView];
    [self.stateView addSubview:self.stateLabel];
    
    [self.contentView addSubview:self.bottomLineView];
}

- (void)zfAutoLayoutView {
    
    [self.goodImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.width.mas_equalTo(self.goodImageView.mas_height).multipliedBy(90 / 120.0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodImageView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.goodImageView.mas_top);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-8);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.grayPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(3);
        make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
    }];
    
    [self.similarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.bottom.mas_equalTo(self.goodImageView.mas_bottom);
        make.height.mas_equalTo(28);
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.goodImageView.mas_centerY);
        make.leading.mas_equalTo(self.goodImageView.mas_leading).offset(5);
        make.trailing.mas_equalTo(self.goodImageView.mas_trailing).offset(-5);
        make.height.mas_equalTo(20);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.stateView.mas_leading);
        make.trailing.mas_equalTo(self.stateView.mas_trailing);
        make.centerY.mas_equalTo(self.stateView.mas_centerY);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.tryOnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(16);
    }];
}

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    [self.goodImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_thumb]
                                placeholder:[UIImage imageNamed:@"community_loading_product"]];
    
    self.titleLabel.text = ZFToString(goodsModel.goods_title);
    self.priceLabel.text = [ExchangeManager transforPrice:goodsModel.shop_price];
    
    self.similarButton.hidden = YES;
    if ([goodsModel.is_on_sale isEqualToString:@"1"]) {
        self.titleLabel.textColor = ZFC0x666666();
        self.priceLabel.textColor = ZFC0xFE5269();
        self.cartButton.hidden = NO;
        self.stateView.hidden = YES;
        self.grayPriceLabel.hidden = NO;
        
        NSString *marketPrice = [ExchangeManager transforPrice:goodsModel.market_price];
        NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];
        self.grayPriceLabel.attributedText = attribtStr;
        
    } else {
        self.similarButton.hidden = NO;
        self.titleLabel.textColor = ZFC0xCCCCCC();
        self.priceLabel.textColor = ZFC0xCCCCCC();
        self.cartButton.hidden = YES;
        self.stateView.hidden = NO;
        self.grayPriceLabel.hidden = YES;
    }
    
}

- (void)showLiveRecommendActivity:(BOOL)showMark {
    if (showMark) {
        self.tryOnView.hidden = NO;
        [self.tryOnView startLoading];
    } else {
        self.tryOnView.hidden = YES;
        [self.tryOnView endLoading];
    }
}
#pragma mark - XXX Action

- (void)actionCart:(UIButton *)sender {
    if (self.cartBlock) {
        self.cartBlock(self.goodsModel);
    }
}

- (void)findRelatedButtonAction {
    if (self.findSimilarBlock) {
        self.findSimilarBlock(self.goodsModel);
    }
}

- (void)hideBottomLine:(BOOL)hide {
    self.bottomLineView.hidden = hide;
}

#pragma mark - Property Method

- (ZFFullLiveTryOnView *)tryOnView {
    if (!_tryOnView) {
        _tryOnView = [[ZFFullLiveTryOnView alloc] initWithFrame:CGRectZero];
        _tryOnView.backgroundColor = ZFC0xFE5269();
        _tryOnView.layer.cornerRadius = 8;
        _tryOnView.layer.masksToBounds = YES;
        _tryOnView.hidden = YES;
    }
    return _tryOnView;
}

- (YYAnimatedImageView *)goodImageView {
    if (!_goodImageView) {
        _goodImageView = [[YYAnimatedImageView alloc] init];
    }
    return _goodImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = ZFFontSystemSize(12);
        _titleLabel.textColor = ZFC0x666666();
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.textColor = ZFC0x2D2D2D();
        _priceLabel.font = ZFFontBoldSize(16);
    }
    return _priceLabel;
}

- (UILabel *)grayPriceLabel {
    if (!_grayPriceLabel) {
        _grayPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _grayPriceLabel.textColor = ZFC0x999999();
        _grayPriceLabel.font = ZFFontSystemSize(12);
    }
    return _grayPriceLabel;
}

- (UIButton *)similarButton {
    if (!_similarButton) {
        _similarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _similarButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _similarButton.layer.cornerRadius = 2;
        _similarButton.layer.masksToBounds = YES;
        _similarButton.layer.borderColor = ZFC0xFE5269().CGColor;
        _similarButton.layer.borderWidth = 1;
        _similarButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        [_similarButton setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        [_similarButton setTitle:ZFLocalizedString(@"cart_unline_findsimilar_tag", nil) forState:UIControlStateNormal];
        
        [_similarButton addTarget:self action:@selector(findRelatedButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _similarButton;
}


- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:ZFImageWithName(@"community_cart_add") forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(actionCart:) forControlEvents:UIControlEventTouchUpInside];
        [_cartButton setContentEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    }
    return _cartButton;
}

- (UIView *)stateView {
    if (!_stateView) {
        _stateView = [[UIView alloc] initWithFrame:CGRectZero];
        _stateView.backgroundColor = ZFC0x000000_04();
        _stateView.layer.cornerRadius = 10.0;
        _stateView.layer.masksToBounds = YES;
        _stateView.hidden = YES;
    }
    return _stateView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.textColor = ZFC0xFFFFFF();
        _stateLabel.font = ZFFontSystemSize(11);
        _stateLabel.text = ZFLocalizedString(@"cart_soldOut", nil);
    }
    return _stateLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _bottomLineView;
}
@end
