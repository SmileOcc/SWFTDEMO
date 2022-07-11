//
//  OSSVProductListCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVProductListCell.h"
#import "OSSVCartNewUserTipView.h"

@interface OSSVProductListCell()
/** 商品图片*/
@property (nonatomic, strong) YYAnimatedImageView            *iconView;
/** 商品名称*/
@property (nonatomic, strong) UILabel                        *titleLabel;
/** 商品属性*/
@property (nonatomic, strong) UILabel                        *propertyLabel;
/** 区级*/
@property (nonatomic, strong) UIButton                       *rateBtn;
/** 商品价格*/
@property (nonatomic, strong) UILabel                        *priceLabel;


@property (nonatomic, strong) UILabel                        *countLabel;


@property (nonatomic, strong) UILabel                        *countLeftLabel;
@property (nonatomic, strong) UIView                         *markView;
@property (nonatomic, strong) UILabel                        *stateLabel;

@property (weak,nonatomic) UIImageView *stateImageView;

/** 0元标识*/
@property (nonatomic, strong) OSSVCartNewUserTipView          *zeroNewTipView;

@end

@implementation OSSVProductListCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView yy_cancelCurrentImageRequest];
    self.iconView.image = nil;
    self.titleLabel.text = nil;
    self.priceLabel.text = nil;
    self.propertyLabel.text = nil;
    self.countLeftLabel.text = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIView *ws = self.contentView;
        //商品图片
        [ws addSubview:self.iconView];
        //商品名称
        [ws addSubview:self.titleLabel];
        //商品属性
        [ws addSubview:self.propertyLabel];
        [ws addSubview:self.rateBtn];
        
        //商品价格
        [ws addSubview:self.priceLabel];
        [ws addSubview:self.countLabel];
        [ws addSubview:self.countLeftLabel];
        [ws addSubview:self.lineView];
        
        [ws bringSubviewToFront:self.iconView];
        
        [ws addSubview:self.markView];
        [self.markView addSubview:self.stateLabel];
        
        [ws addSubview:self.zeroNewTipView];
        
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.mas_centerY);
            make.leading.mas_equalTo(ws.mas_leading).mas_offset(12);
            if (APP_TYPE == 3) {
                make.size.mas_equalTo(CGSizeMake(72, 72));
            } else {
                make.size.mas_equalTo(CGSizeMake(72, 96));
            }
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_top).offset(2);
            make.leading.mas_equalTo(self.iconView.mas_trailing).offset(8);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
        }];
        
        [self.propertyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
        }];
        
        [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.propertyLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.iconView.mas_bottom);
            make.leading.mas_equalTo(self.propertyLabel.mas_leading);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading).offset(12);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(ws.mas_bottom);
            make.height.mas_equalTo(@(0.5));
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.priceLabel);
            make.width.mas_equalTo(@(35));
        }];
        
        [self.countLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.bottom.mas_equalTo(self.iconView.mas_bottom);
        }];
        
        [self.markView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.iconView);
        }];
        
        [self.zeroNewTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.top.mas_equalTo(self.propertyLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(18);
        }];
        
        
        UIImageView *stateImage = [[UIImageView alloc] init];
        stateImage.image = [UIImage imageNamed:@"goods_hanger"];
        [self.markView addSubview:stateImage];
        self.stateImageView = stateImage;
        [stateImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(27);
            make.centerX.mas_equalTo(self.markView.mas_centerX);
            make.width.height.equalTo(24);
        }];
        
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(stateImage.mas_bottom).offset(8);
            make.leading.mas_equalTo(self.markView.mas_leading).offset(4);
            make.trailing.mas_equalTo(self.markView.mas_trailing).offset(-4);
        }];

        
    }
    return self;
    
}

- (void)setShowLeftCount:(BOOL)showLeftCount {
    _showLeftCount = showLeftCount;
    
    self.countLabel.hidden = NO;
    self.countLeftLabel.hidden = YES;
    self.priceLabel.hidden = NO;

    if (showLeftCount) {
        self.countLabel.hidden = YES;
        self.countLeftLabel.hidden = NO;
        self.priceLabel.hidden = YES;
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.propertyLabel.font = [UIFont systemFontOfSize:11];

    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.propertyLabel.font = [UIFont systemFontOfSize:13];
    }
}
-(void)setCartGoodsModel:(OSSVCartGoodsModel *)cartGoodsModel{
    _cartGoodsModel = cartGoodsModel;
    
    [self.iconView yy_setImageWithURL:[NSURL URLWithString:cartGoodsModel.goodsThumb]
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                //image = [image yy_imageByResizeToSize:CGSizeMake(80, 80) contentMode:UIViewContentModeScaleAspectFit];
                                return image;
                            }
                           completion:nil];
    
    self.titleLabel.text = STLToString(cartGoodsModel.goodsName);
    self.propertyLabel.text = STLToString(cartGoodsModel.goodsAttr);
    
//    NSString *price = [ExchangeManager changeRateModel:self.rateModel transforPrice:cartGoodsModel.goodsPrice priceType:PriceType_ProductPrice];
//    self.priceLabel.text = [ExchangeManager appenSymbol:self.rateModel price:price];
    self.priceLabel.text = STLToString(cartGoodsModel.goods_price_converted);
    self.countLabel.text = [NSString stringWithFormat:@"x %ld", (long)cartGoodsModel.goodsNumber];
    self.countLeftLabel.text = [NSString stringWithFormat:@"x %ld", (long)cartGoodsModel.goodsNumber];
    STLLog(@"%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
 
    //区级
//    _rateBtn.hidden = NO;
//    [_rateBtn setTitle:STLToString(cartGoodsModel.warehouseName) forState:UIControlStateNormal];
//    if ([cartGoodsModel.wid isEqualToString:@"2"]) {//全球
//        [_rateBtn setTitleColor:OSSVThemesColors.col_24A600 forState:UIControlStateNormal];
//        _rateBtn.backgroundColor = OSSVThemesColors.col_E1F2DA;
//        
//    } else {
//        [_rateBtn setTitleColor:OSSVThemesColors.col_2C98E9 forState:UIControlStateNormal];
//        _rateBtn.backgroundColor = OSSVThemesColors.col_E6F2FF;
//    }
    //零元购展示
    self.zeroNewTipView.hidden = YES;
    if ([cartGoodsModel.is_exchange boolValue]) {
        self.zeroNewTipView.hidden = NO;
        self.zeroNewTipView.tipLabel.text = [STLToString(cartGoodsModel.exchange_label) uppercaseString];
        self.zeroNewTipView.tipLabel.textColor = OSSVThemesColors.col_B62B21;
    }
    
    
    self.markView.hidden = YES;
    self.priceLabel.alpha = 1.0;
    self.titleLabel.alpha = 1.0;
    self.countLeftLabel.alpha = 1.0;
    self.countLabel.alpha = 1.0;
    self.rateBtn.alpha = 1.0;
    if ([cartGoodsModel.shield_status integerValue] == 1) {
        self.markView.hidden = NO;
//        self.priceLabel.alpha = 0.5;
//        self.titleLabel.alpha = 0.5;
//        self.countLeftLabel.alpha = 0.5;
//        self.countLabel.alpha = 0.5;
//        self.rateBtn.alpha = 0.5;
//        self.rateBtn.hidden = YES;
    }
}

#pragma mark - LazyLoad

- (YYAnimatedImageView *)iconView {
    if (!_iconView) {
        _iconView = [[YYAnimatedImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.layer.masksToBounds = true;
        if (APP_TYPE != 3) {
            _iconView.layer.borderWidth = 0.5*kScale_375;
            _iconView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        }
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [OSSVThemesColors col_6C6C6C];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    return _titleLabel;
}

- (UIButton *)rateBtn {
    if (!_rateBtn) {
        _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rateBtn.userInteractionEnabled = NO;
        _rateBtn.hidden = YES;
        _rateBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_rateBtn setTitleColor:OSSVThemesColors.col_24A600 forState:UIControlStateNormal];
        _rateBtn.backgroundColor = OSSVThemesColors.col_E1F2DA;
        [_rateBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 4, 2, 4)];
    }
    return _rateBtn;
}

- (UILabel *)propertyLabel {
    if (!_propertyLabel) {
        _propertyLabel = [[UILabel alloc] init];
        _propertyLabel.font = [UIFont boldSystemFontOfSize:12];
        _propertyLabel.textColor = [OSSVThemesColors col_6C6C6C];
    }
    return _propertyLabel;
}


- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _priceLabel;
}


- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor =  OSSVThemesColors.col_0D0D0D;
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (UILabel *)countLeftLabel {
    if (!_countLeftLabel) {
        _countLeftLabel = [[UILabel alloc] init];
        _countLeftLabel.font = [UIFont systemFontOfSize:13];
        _countLeftLabel.textColor = [OSSVThemesColors col_666666];
        _countLeftLabel.textAlignment = NSTextAlignmentCenter;
        _countLeftLabel.hidden = YES;
    }
    return _countLeftLabel;
}

- (UIView *)markView {
    if (!_markView) {
        _markView = [[UIView alloc] initWithFrame:CGRectZero];
        _markView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.3];
        _markView.hidden = YES;
    }
    return _markView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:12];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.text = STLLocalizedString_(@"Goods_Unavailable", nil);
        _stateLabel.numberOfLines = 0;

    }
    return _stateLabel;
}

- (OSSVCartNewUserTipView *)zeroNewTipView {
    if (!_zeroNewTipView) {
        _zeroNewTipView = [[OSSVCartNewUserTipView alloc] initWithFrame:CGRectZero];
        _zeroNewTipView.hidden = YES;
    }
    return _zeroNewTipView;
}

@end
