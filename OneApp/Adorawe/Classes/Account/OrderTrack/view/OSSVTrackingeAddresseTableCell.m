//
//  OSSVTrackingeAddresseTableCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//  收货地址的cell

#import "OSSVTrackingeAddresseTableCell.h"
#import "Adorawe-Swift.h"

@interface OSSVTrackingeAddresseTableCell ()
@property (nonatomic, strong) UIView *addressMapBgView;
@property (nonatomic, strong) YYAnimatedImageView *addressImgView;
@property (nonatomic, strong) UILabel             *titleLabel;
@property (nonatomic, strong) UILabel             *addressCotentLabel;
@property (nonatomic, strong) UIView              *lineView;
@end
@implementation OSSVTrackingeAddresseTableCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self.contentView addSubview:self.addressMapBgView];
        [self.addressMapBgView addSubview:self.addressImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.addressCotentLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)setModel:(OSSVTrackingcTotalInformcnModel *)model {
    _model = model;
    //无返回邮编（zip） 字段
    self.addressCotentLabel.text = [NSString addressStringWithAddres:model.shipAdress];
//根据不同物流状态改变文本和图标颜色
    if (model.alreadySign) {
        self.addressImgView.image = [UIImage imageNamed:@"address_white"];
        self.addressMapBgView.backgroundColor = OSSVThemesColors.col_0D0D0D;
        self.addressMapBgView.layer.borderColor = OSSVThemesColors.col_0D0D0D.CGColor;
        self.titleLabel.textColor = OSSVThemesColors.col_999999;
        self.addressCotentLabel.textColor = OSSVThemesColors.col_999999;
    } else {
        self.addressImgView.image = [UIImage imageNamed:@"address_gray"];
        self.addressMapBgView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        self.addressMapBgView.layer.borderColor = OSSVThemesColors.col_CCCCCC.CGColor;
        self.titleLabel.textColor = OSSVThemesColors.col_999999;
        self.addressCotentLabel.textColor = OSSVThemesColors.col_999999;
    }
}

- (UIView *)addressMapBgView {
    if (!_addressMapBgView) {
        _addressMapBgView = [UIView new];
        _addressMapBgView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        _addressMapBgView.layer.cornerRadius = 12;
        _addressMapBgView.layer.borderColor = OSSVThemesColors.col_CCCCCC.CGColor;
        _addressMapBgView.layer.borderWidth = 1.f;
        _addressMapBgView.layer.masksToBounds = YES;
    }
    return _addressMapBgView;
}

- (YYAnimatedImageView *)addressImgView {
    if (!_addressImgView) {
        _addressImgView = [YYAnimatedImageView new];
        _addressImgView.image = [UIImage imageNamed:@"address_gray"];
    }
    return _addressImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_999999;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.text = STLLocalizedString_(@"ShippingAddress", nil);
    }
    return _titleLabel;
}

- (UILabel *)addressCotentLabel {
    if (!_addressCotentLabel) {
        _addressCotentLabel = [UILabel  new];
        _addressCotentLabel.textColor = OSSVThemesColors.col_999999;
        _addressCotentLabel.font = [UIFont systemFontOfSize:13];
        _addressCotentLabel.numberOfLines = 0;
    }
    return _addressCotentLabel;
    
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_CCCCCC;
    }
    return _lineView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.addressMapBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(50);
        make.width.height.equalTo(24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(24);
    }];
    
    [self.addressImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressMapBgView.mas_leading).offset(4);
        make.height.width.equalTo(16);
        make.top.mas_equalTo(self.addressMapBgView.mas_top).offset(4);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressMapBgView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.addressMapBgView.mas_top).offset(5);
        make.height.equalTo(15);
    }];

    [self.addressCotentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addressMapBgView.mas_bottom);
        make.width.equalTo(1);
        make.centerX.mas_equalTo(self.addressMapBgView.mas_centerX);
        make.height.equalTo(39);
    }];
}

@end
