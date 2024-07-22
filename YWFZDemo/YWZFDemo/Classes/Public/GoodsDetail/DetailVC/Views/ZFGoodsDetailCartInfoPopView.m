//
//  ZFGoodsDetailCartInfoPopView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/9.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCartInfoPopView.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import "BigClickAreaButton.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "GoodsDetailModel.h"
#import "ZFRRPLabel.h"
#import "ExchangeManager.h"
#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>
#import "YYLabel.h"

@interface ZFGoodsDetailCartInfoPopView ()
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) YYLabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIButton *addCartBagButton;
@end

@implementation ZFGoodsDetailCartInfoPopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 10;
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    [self addSubview:self.arrowImageView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.productImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.addCartBagButton];
}

- (void)zfAutoLayoutView {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 0, 0, 0));
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_top);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
    }];
    
    [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(8);
        make.leading.mas_equalTo(self.contentView).mas_offset(8);
        make.size.mas_offset(CGSizeMake(45, 60));
    }];
    
    self.titleLabel.preferredMaxLayoutWidth = 180;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.productImageView.mas_top);
        make.leading.mas_equalTo(self.productImageView.mas_trailing).mas_offset(5);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-2);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(4);
        make.leading.mas_equalTo(self.titleLabel);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(2);
        make.leading.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.titleLabel.mas_trailing);
    }];
    
    [self.addCartBagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-8);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
        make.height.mas_offset(28);
    }];
}

#pragma mark - Setter

- (void)setDetailModel:(GoodsDetailModel *)detailModel {
    _detailModel = detailModel;
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:detailModel.wp_image]
                                  placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                      options:YYWebImageOptionSetImageWithFadeAnimation
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];
    self.titleLabel.text = detailModel.goods_name;
    self.priceLabel.text = [ExchangeManager transforPrice:detailModel.shop_price];
    
    //color
    __block NSString *color = @"";
    [detailModel.same_goods_spec.color enumerateObjectsUsingBlock:^(GoodsDetialColorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([detailModel.goods_id isEqualToString:obj.goods_id]) {
            color = ZFToString(obj.attr_value);
            *stop = YES;
        }
    }];
    
    //size
    __block NSString *size = @"";
    [detailModel.same_goods_spec.size enumerateObjectsUsingBlock:^(GoodsDetialSizeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([detailModel.goods_id isEqualToString:obj.goods_id]) {
            size = ZFToString(obj.attr_value);
            *stop = YES;
        }
    }];
    self.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",color ,size];
}

- (void)addCartBagButtonAction {
    if (self.addToCartBlcok) {
        self.addToCartBlcok(self.detailModel);
    }
}

#pragma mark - Getter

- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _arrowImageView.image = [UIImage imageNamed:@"unpaid_arrow_up"];
    }
    return _arrowImageView;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = ZFCOLOR_WHITE;
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIImageView *)productImageView{
    if (!_productImageView) {
        _productImageView = [[UIImageView alloc] init];
        _productImageView.contentMode = UIViewContentModeScaleAspectFill;
        _productImageView.clipsToBounds = YES;
    }
    return _productImageView;
}

-(YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[YYLabel alloc] init];
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

-(UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _priceLabel;
}

-(UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _sizeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _sizeLabel;
}

- (UIButton *)addCartBagButton {
    if (!_addCartBagButton) {
        _addCartBagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addCartBagButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_addCartBagButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_addCartBagButton addTarget:self action:@selector(addCartBagButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_addCartBagButton setTitle:@"VIEW BAG" forState:0];
        _addCartBagButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _addCartBagButton.layer.cornerRadius = 2;
        _addCartBagButton.layer.masksToBounds = YES;
    }
    return _addCartBagButton;
}

@end
