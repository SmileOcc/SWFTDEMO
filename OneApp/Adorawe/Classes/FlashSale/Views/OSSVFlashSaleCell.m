//
//  OSSVFlashSaleCell.m
// XStarlinkProject
//
//  Created by odd on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleCell.h"

@interface OSSVFlashSaleCell ()
@property (nonatomic, strong) UIView *lineView;
@end



@implementation OSSVFlashSaleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cellBgView];
        [self.cellBgView addSubview:self.productImgView];
        [self.cellBgView addSubview:self.titleLabel];
        [self.cellBgView addSubview:self.priceLabel];
        [self.cellBgView addSubview:self.oldPirceLabel];
        [self.cellBgView addSubview:self.progressView];
        [self.cellBgView addSubview:self.progressLabel];
        [self.cellBgView addSubview:self.addButton];
        [self.addButton addSubview:self.addImageView];
        [self.cellBgView addSubview:self.productDetailLabel];
        [self.productImgView addSubview:self.activityStateView];
        [self.productImgView addSubview:self.soldOutBgView];
        [self.soldOutBgView addSubview:self.soldOutImageView];
        [self.soldOutBgView addSubview:self.soldOutLabel];
        [self.cellBgView addSubview:self.lineView];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
}

- (UIView *)cellBgView {
    if (!_cellBgView) {
        _cellBgView = [UIView new];
        _cellBgView.backgroundColor = [UIColor whiteColor];
    }
    return _cellBgView;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_EEEEEE;
    }
    return _lineView;
}
- (YYAnimatedImageView *)productImgView {
    if (!_productImgView) {
        _productImgView = [YYAnimatedImageView new];
        _productImgView.contentMode = UIViewContentModeScaleAspectFill;
        _productImgView.clipsToBounds = YES;
        if (APP_TYPE != 3) {
            _productImgView.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
            _productImgView.layer.borderWidth = 0.5f;
            _productImgView.layer.masksToBounds = YES;
        }
        _productImgView.backgroundColor = [UIColor clearColor];
    }
    return _productImgView;
}
- (UIView *)soldOutBgView {
    if (!_soldOutBgView) {
        _soldOutBgView = [UIView new];
        _soldOutBgView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.4];
    }
    return _soldOutBgView;
}

- (YYAnimatedImageView *)soldOutImageView {
    if (!_soldOutImageView) {
        _soldOutImageView = [YYAnimatedImageView new];
        _soldOutImageView.image = [UIImage imageNamed:@"soldOut_icon"];
    }
    return _soldOutImageView;
}

- (UILabel *)soldOutLabel {
    if (!_soldOutLabel) {
        _soldOutLabel = [UILabel new];
        _soldOutLabel.textColor = OSSVThemesColors.col_FFFFFF;
        _soldOutLabel.font = [UIFont boldSystemFontOfSize:11];
        _soldOutLabel.textAlignment = NSTextAlignmentCenter;
        _soldOutLabel.text = STLLocalizedString_(@"soldOut", nil);
    }
    return _soldOutLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [OSSVThemesColors col_6C6C6C];
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.textColor = OSSVThemesColors.col_B62B21;
        _priceLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _priceLabel;
}

- (UILabel *)oldPirceLabel {
    if (!_oldPirceLabel) {
        _oldPirceLabel = [UILabel new];
        _oldPirceLabel.font = [UIFont boldSystemFontOfSize:10];
        _oldPirceLabel.textColor = [OSSVThemesColors col_6C6C6C];
    }
    return _oldPirceLabel;
}

- (OSSVFlashSaleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[OSSVFlashSaleProgressView alloc] init];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _progressView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
     }
    return _progressView;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.samllImageShow = YES;
//        _activityStateView.flashImageSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _addButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
//        _addButton.layer.cornerRadius = 2.f;
//        _addButton.layer.masksToBounds = YES;
//        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_addButton setTitle:[STLLocalizedString_(@"addToCart",nil) uppercaseString] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(popSukView:) forControlEvents:UIControlEventTouchUpInside];
//        _addButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        
//        [_addButton setBackgroundImage:[UIImage imageNamed:@"cart_bag"] forState:UIControlStateNormal];
    }
    return _addButton;
}

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_bag"]];
    }
    return _addImageView;
}

- (UILabel *)productDetailLabel {
    if (!_productDetailLabel) {
        _productDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productDetailLabel.textColor = [OSSVThemesColors col_131313];
        _productDetailLabel.font = [UIFont systemFontOfSize:12];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _productDetailLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            _productDetailLabel.textAlignment = NSTextAlignmentRight;
        }
        _productDetailLabel.text = STLLocalizedString_(@"View_Product>", nil);
        _productDetailLabel.hidden = YES;
    }
    return _productDetailLabel;
}
- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
        _progressLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _progressLabel.font = [UIFont systemFontOfSize:9];
    }
    return _progressLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.cellBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.cellBgView.mas_leading).offset(12);
        make.top.mas_equalTo(self.cellBgView.mas_top).offset(12);
        make.bottom.mas_equalTo(self.cellBgView.mas_bottom).offset(-12);
        make.width.mas_equalTo(@(90*kScale_375));
//        make.height.mas_equalTo(@(120*kScale_375));
    }];
    
    [self.soldOutBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.productImgView);
    }];
    [self.soldOutImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.soldOutBgView.mas_centerX);
        make.centerY.mas_equalTo(self.soldOutBgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [self.soldOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.soldOutBgView);
        make.top.mas_equalTo(self.soldOutImageView.mas_bottom).offset(6);
    }];
    
    [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_leading);
        make.top.mas_equalTo(self.productImgView.mas_top);
    }];
    
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.productImgView.mas_top);
        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-12);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(7);
        make.height.mas_equalTo(@16);
        make.width.mas_equalTo(@(144*kScale_375));
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.progressView.mas_leading).offset(6);
        make.centerY.mas_equalTo(self.progressView.mas_centerY);
    }];


    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.bottom.mas_equalTo(self.productImgView.mas_bottom);
        make.height.mas_equalTo(@20);
    }];
    
    [self.oldPirceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.priceLabel.mas_leading);
        make.bottom.mas_equalTo(self.priceLabel.mas_top).offset(-2);
        make.height.mas_equalTo(@13);
    }];
    
    
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {

        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-5);
        make.bottom.mas_equalTo(self.productImgView.mas_bottom).offset(8);
        make.height.mas_equalTo(@36);
        make.width.mas_equalTo(@36);
    }];
    
    [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.centerY.mas_equalTo(self.addButton.mas_centerY);
        make.centerX.mas_equalTo(self.addButton.mas_centerX);
    }];
    [self.productDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.cellBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.cellBgView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.cellBgView.mas_bottom);
        make.height.mas_equalTo(@0.5);
    }];
}

- (void)popSukView:(UIButton *)sender {

    if (_delegate && [_delegate respondsToSelector:@selector(selectedIndexButton:)]) {
        [_delegate selectedIndexButton:sender];
    }
}


@end
