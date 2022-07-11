//
//  OSSVCommendCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCommendCell.h"
#import "CommendModel.h"

@interface OSSVCommendCell ()
/** 商品图片*/
@property (nonatomic, strong) YYAnimatedImageView    *iconView;
/** 商品价格*/
@property (nonatomic, strong) UILabel                *priceLabel;

@end

@implementation OSSVCommendCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.priceLabel];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.width.mas_equalTo(@75);
            make.height.mas_equalTo(@75);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_bottom).offset(8);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
        }];
    }
    return self;
}

#pragma mark -
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView yy_cancelCurrentImageRequest];
    self.iconView.image = nil;
    self.priceLabel.text = nil;
}

- (void)setItemModel:(CommendModel *)itemModel {
    _itemModel = itemModel;
    [self.iconView yy_setImageWithURL:[NSURL URLWithString:itemModel.goodsThumb]
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                        image = [image yy_imageByResizeToSize:CGSizeMake(75, 75) contentMode:UIViewContentModeScaleToFill];
                                        return image;
                                      }
                           completion:nil];
    self.priceLabel.text = STLToString(itemModel.shop_price_converted);
}

#pragma mark - LazyLoad

- (YYAnimatedImageView *)iconView {
    if (!_iconView) {
        _iconView = [YYAnimatedImageView new];
        _iconView.layer.borderWidth = 0.5;
        _iconView.layer.borderColor = OSSVThemesColors.col_F1F1F1.CGColor;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.font = [UIFont systemFontOfSize:12];
        _priceLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _priceLabel;
}
@end
