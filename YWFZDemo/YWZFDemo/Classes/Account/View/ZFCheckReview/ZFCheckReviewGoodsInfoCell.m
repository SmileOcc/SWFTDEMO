

//
//  ZFCheckReviewGoodsInfoCell.m
//  ZZZZZ
//
//  Created by YW on 2018/2/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCheckReviewGoodsInfoCell.h"
#import "ZFInitViewProtocol.h"
#import "OrderDetailGoodModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"

@interface ZFCheckReviewGoodsInfoCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *goodsTitleLabel;
@property (nonatomic, strong) UILabel               *goodsSkuLabel;
@property (nonatomic, strong) UILabel               *colorLabel;
@property (nonatomic, strong) UILabel               *sizeLabel;
@property (nonatomic, strong) UILabel               *totalLabel;
@property (nonatomic, strong) UILabel               *buyNumberLabel;
@end

@implementation ZFCheckReviewGoodsInfoCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.goodsTitleLabel];
    [self.contentView addSubview:self.goodsSkuLabel];
    [self.contentView addSubview:self.colorLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.totalLabel];
    [self.contentView addSubview:self.buyNumberLabel];
    
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 150));
    }];
    
    [self.goodsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.goodsSkuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsTitleLabel.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.goodsTitleLabel);
    }];
    
    [self.colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsSkuLabel.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.goodsTitleLabel);
    }];

    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.colorLabel.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.goodsTitleLabel);
    }];
    
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom);
        make.leading.mas_equalTo(self.goodsTitleLabel);
        make.trailing.mas_equalTo(self.buyNumberLabel.mas_leading).offset(-8);
    }];
    
    [self.buyNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.totalLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
}

#pragma mark - setter
- (void)setGoodsModel:(OrderDetailGoodModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:self.goodsModel.goods_grid]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]];
    self.goodsTitleLabel.text = self.goodsModel.goods_title;
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.goodsSkuLabel.text = [NSString stringWithFormat:@"%@:%@",self.goodsModel.goods_sn,ZFLocalizedString(@"CheckMyReview_Sku",nil)];
        
        self.colorLabel.text = [NSString stringWithFormat:@"%@:%@",self.goodsModel.attr_color == nil ? @"" :self.goodsModel.attr_color,ZFLocalizedString(@"CheckMyReview_Color",nil)];
        
        self.sizeLabel.text = [NSString stringWithFormat:@"%@:%@",self.goodsModel.attr_size == nil ? @"" :self.goodsModel.attr_size,ZFLocalizedString(@"CheckMyReview_Size",nil)];
        
        self.buyNumberLabel.text = [NSString stringWithFormat:@"%@X",self.goodsModel.goods_number];
        
        self.totalLabel.text = [NSString stringWithFormat:@"%@%@ :%@",self.goodsModel.order_currency,self.goodsModel.goods_price,ZFLocalizedString(@"CheckMyReview_Total",nil)];
    } else {
        self.goodsSkuLabel.text = [NSString stringWithFormat:@"%@:%@",ZFLocalizedString(@"CheckMyReview_Sku",nil),self.goodsModel.goods_sn];
        
        self.colorLabel.text = [NSString stringWithFormat:@"%@:%@",ZFLocalizedString(@"CheckMyReview_Color",nil),self.goodsModel.attr_color == nil ? @"" :self.goodsModel.attr_color];
        
        self.sizeLabel.text = [NSString stringWithFormat:@"%@:%@",ZFLocalizedString(@"CheckMyReview_Size",nil),self.goodsModel.attr_size == nil ? @"" :self.goodsModel.attr_size];
        
        self.buyNumberLabel.text = [NSString stringWithFormat:@"X%@",self.goodsModel.goods_number];
        
        self.totalLabel.text = [NSString stringWithFormat:@"%@: %@%@",ZFLocalizedString(@"CheckMyReview_Total",nil),self.goodsModel.order_currency,self.goodsModel.goods_price];
    }
    
}

#pragma mark - getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)goodsTitleLabel {
    if (!_goodsTitleLabel) {
        _goodsTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTitleLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        _goodsTitleLabel.numberOfLines = 2;
        _goodsTitleLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _goodsTitleLabel;
}

- (UILabel *)goodsSkuLabel {
    if (!_goodsSkuLabel) {
        _goodsSkuLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsSkuLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        _goodsSkuLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _goodsSkuLabel;
}

- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _colorLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _colorLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _colorLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _sizeLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _sizeLabel;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        _totalLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    return _totalLabel;
}

- (UILabel *)buyNumberLabel {
    if (!_buyNumberLabel) {
        _buyNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _buyNumberLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        _buyNumberLabel.font = [UIFont systemFontOfSize:14.0];
        _buyNumberLabel.textAlignment = NSTextAlignmentRight;
    }
    return _buyNumberLabel;
}

@end
