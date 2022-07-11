//
//  STLProductCollectionCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPductGoodsCCell.h"
#import "OSSVCartGoodsModel.h"
#import "UICollectionViewCell+STLExtension.h"
#import "OSSVDetailsHeaderActivityStateView.h"
@interface OSSVPductGoodsCCell ()
@property (nonatomic, strong) YYAnimatedImageView *productImageView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *marketPriceLabel;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@end

@implementation OSSVPductGoodsCCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self.contentView addSubview:self.productImageView];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.marketPriceLabel];
        [self.productImageView addSubview:self.activityStateView];
            
        [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(ProductImageHeight);
            make.top.mas_equalTo(self);
        }];
        
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.productImageView.mas_leading);
            make.top.equalTo(self.productImageView.mas_top);
        }];

        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.productImageView.mas_bottom).mas_offset(LabelTopBottomPadding);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(PriceLabelHeight);
        }];
        
        [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(LabelPadding);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(MarketPriceLabelHeight);
        }];
        
        [self setShadowAndCornerCell];
    }
    return self;
}

#pragma mark ---标签不需要圆角了
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
//
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
//}

#pragma mark - setter and getter

-(void)setModel:(OSSVHomeGoodsListModel *)model
{
    _model = model;
    self.activityStateView.hidden = YES;
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:model.goodsImageUrl]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                   completion:nil];
    
    //闪购商品展示闪购价
    if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
        self.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
    } else {
        self.priceLabel.text = STLToString(model.shop_price_converted);

    }

    //加一个删除线
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.market_price_converted)
                                                                                attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    self.marketPriceLabel.attributedText = attrStr;
    
    ////折扣标 闪购标
    if ([model.show_discount_icon integerValue] && STLToString(model.discount).intValue > 0) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.discount)];
        self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
    }
    if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
    }

    [self setNeedsDisplay];
}

- (void)setCartGoodsModel:(OSSVCartGoodsModel *)cartGoodsModel {
    
    _cartGoodsModel = cartGoodsModel;
    
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:cartGoodsModel.goodsThumb]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                   completion:nil];
    
    self.priceLabel.text = @"";
    self.marketPriceLabel.attributedText = [[NSMutableAttributedString alloc] init];
}


-(YYAnimatedImageView *)productImageView
{
    if (!_productImageView) {
        _productImageView = ({
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView;
        });
    }
    return _productImageView;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [OSSVThemesColors col_FFFF6F:0.1];
            label.font = [UIFont systemFontOfSize:13];
            label;
        });
    }
    return _priceLabel;
}

-(UILabel *)marketPriceLabel
{
    if (!_marketPriceLabel) {
        _marketPriceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = OSSVThemesColors.col_999999;
            label.font = [UIFont systemFontOfSize:10];
            label;
        });
    }
    return _marketPriceLabel;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleVertical];
        _activityStateView.hidden = YES;
        _activityStateView.backgroundColor = [UIColor clearColor];
    }
    return _activityStateView;
}


@end
