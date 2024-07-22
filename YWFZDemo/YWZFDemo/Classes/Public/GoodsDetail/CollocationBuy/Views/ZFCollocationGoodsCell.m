//
//  ZFCollocationGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollocationGoodsCell.h"
#import "UIImage+ZFExtended.h"
#import "ZFLocalizationString.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFCollocationBuyModel.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCollocationGoodsCell ()
@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@property (nonatomic, strong) UILabel               *markPriceLabel;
@property (nonatomic, strong) UIButton              *selectButton;
@end

@implementation ZFCollocationGoodsCell

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - setter
- (void)setGoodsModel:(ZFCollocationGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_grid_app]
                                 placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:^UIImage *(UIImage *image, NSURL *url) {
                                       if ([image isKindOfClass:[YYImage class]]) {
                                           YYImage *showImage = (YYImage *)image;
                                           if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                                               return image;
                                           }
                                       }
                                       return [image zf_drawImageToOpaque];
                                   } completion:nil];
    
    self.titleLabel.text = goodsModel.goods_title;
    self.shopPriceLabel.text = [ExchangeManager transforPrice:goodsModel.shop_price];
    
    NSString *marketPrice = [ExchangeManager transforPrice:goodsModel.market_price];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];
    self.markPriceLabel.attributedText = attribtStr;
    self.selectButton.selected = goodsModel.shouldSelected;
}

- (void)selectButtonAction:(UIButton *)button {
    button.selected = !button.selected;
    self.goodsModel.shouldSelected = button.selected;
    ZFPostNotification(kSetCollocationStatusNotification, nil);
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.markPriceLabel];
    [self.contentView addSubview:self.selectButton];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(11);
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.size.mas_equalTo(CGSizeMake(80, 107));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_top);
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(11);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-38);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
    }];
    
    [self.markPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.shopPriceLabel.mas_centerY);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

#pragma mark - getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds = YES;
    }
    return _goodsImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _titleLabel;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:14];
        _shopPriceLabel.textColor = ZFC0xFE5269();
    }
    return _shopPriceLabel;
}

- (UILabel *)markPriceLabel {
    if (!_markPriceLabel) {
        _markPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _markPriceLabel.font = [UIFont systemFontOfSize:12];
        _markPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _markPriceLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_selectButton setImage:[UIImage imageNamed:@"review_order_no"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"review_order_done"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _selectButton;
}
@end
