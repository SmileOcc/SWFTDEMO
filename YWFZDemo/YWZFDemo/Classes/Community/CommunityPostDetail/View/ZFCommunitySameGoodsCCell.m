//
//  ZFCommunitySameGoodsCCell.m
//  ZZZZZ
//
//  Created by YW on 2018/6/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySameGoodsCCell.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCommunitySameGoodsCCell ()

@property (nonatomic, strong) UILabel *goodsNameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *theSameLabel;

@end

@implementation ZFCommunitySameGoodsCCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self subViewLayout];
    }
    return self;
}

- (void)setupView {
    self.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.goodsNameLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.theSameLabel];
}

- (void)subViewLayout {
    CGFloat width = (KScreenWidth - 12 * 3) / 2;
    CGFloat imageHeight = width * 227.0 / 170.0;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(imageHeight);
    }];
    
    [self.goodsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.imageView.mas_bottom).mas_offset(12.0);
        make.height.mas_equalTo(0.0);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-24.0);
        make.height.mas_equalTo(14.0);
    }];
    
    [self.theSameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.priceLabel.mas_top).mas_offset(-8.0);
        make.height.mas_equalTo(16.0);
    }];
}

- (void)setGoodsTitle:(NSString *)title {
    CGSize titleSize = [title boundingRectWithSize:CGSizeMake((KScreenWidth - 12 * 3) / 2, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin |  NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size;
    self.goodsNameLabel.text = title;
    [self.goodsNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {

        // iOS 计算小数点精确到两位时，布局可能出现偏差，+1 防止这种情况下高度变高了却又不能显示下两行（多行）

        make.height.mas_equalTo(titleSize.height + 1);
    }];
}

- (void)setGoodsImageURL:(NSString *)imageURL {
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageURL]
                           placeholder:[UIImage imageNamed:@"community_loading_product"]];
}

- (void)setGoodsPirce:(NSString *)price {
    self.priceLabel.text = price;
}

- (void)setGoodsIsSame:(BOOL)isSame {
    self.theSameLabel.text   = ZFLocalizedString(@"community_post_simalar", nil);
    CGSize theSameSize       = [self.theSameLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.theSameLabel.font }];
    self.theSameLabel.hidden = !isSame;
    [self.theSameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(theSameSize.width + 6.0);
    }];
}

#pragma getter/setter
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (UILabel *)goodsNameLabel {
    if (!_goodsNameLabel) {
        _goodsNameLabel = [[UILabel alloc] init];
        _goodsNameLabel.font = [UIFont systemFontOfSize:12.0];
        _goodsNameLabel.textColor = [UIColor colorWithHex:0x666666];
        _goodsNameLabel.numberOfLines = 0;
    }
    return _goodsNameLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _priceLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1);
    }
    return _priceLabel;
}

- (UILabel *)theSameLabel {
    if (!_theSameLabel) {
        _theSameLabel                 = [[UILabel alloc] init];
        _theSameLabel.font            = [UIFont systemFontOfSize:10.0];
        _theSameLabel.textColor       = ZFC0xFE5269();
        _theSameLabel.backgroundColor = ZFC0xFFFFFF();
        _theSameLabel.layer.cornerRadius = 2;
        _theSameLabel.layer.borderColor = ZFC0xFE5269().CGColor;
        _theSameLabel.layer.borderWidth = 1;
        _theSameLabel.layer.masksToBounds = YES;
        _theSameLabel.textAlignment   = NSTextAlignmentCenter;
    }
    return _theSameLabel;
}

@end
