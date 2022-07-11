//
//  OSSVHomeFashSaleGoodsCCell.m
// OSSVHomeFashSaleGoodsCCell
//
//  Created by Kevin--Xue on 2020/11/1.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVHomeFashSaleGoodsCCell.h"
@interface OSSVHomeFashSaleGoodsCCell ()

@property (nonatomic, strong)UIView *itemBgView;


@end

@implementation OSSVHomeFashSaleGoodsCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.itemBgView];
        [self.itemBgView addSubview:self.productImgView];
        [self.productImgView addSubview:self.activityStateView];
        [self.itemBgView addSubview:self.priceLabel];
        [self.itemBgView addSubview:self.oldPriceLabel];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
//        
////        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
////            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
////        } else {
////            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
////        }
//    }
//}

- (UIView *)itemBgView {
    if (!_itemBgView) {
        _itemBgView = [UIView new];
        _itemBgView.backgroundColor = [UIColor clearColor];
        _itemBgView.layer.borderColor = OSSVThemesColors.col_F5F5F5.CGColor;
        _itemBgView.layer.borderWidth = 1.f;
        
    }
    return _itemBgView;
}

- (UIImageView *)productImgView {
    if (!_productImgView) {
        _productImgView = [YYAnimatedImageView new];
        _productImgView.contentMode = UIViewContentModeScaleAspectFill;
        _productImgView.clipsToBounds = YES;
        _productImgView.backgroundColor = [UIColor clearColor];
    }
    return _productImgView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.textColor = OSSVThemesColors.col_B62B21;
        _priceLabel.font = [UIFont boldSystemFontOfSize:11];
    }
    return _priceLabel;
}

- (UILabel *)oldPriceLabel {
    if (!_oldPriceLabel) {
        _oldPriceLabel = [UILabel new];
        _oldPriceLabel.textColor = OSSVThemesColors.col_999999;
        _oldPriceLabel.font = [UIFont systemFontOfSize:9];
    }
    return _oldPriceLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.itemBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.top.mas_equalTo(self.contentView.mas_top);
        if (APP_TYPE == 3) {
            make.width.mas_equalTo(@(90*kScale_375));
            make.height.mas_equalTo(@(123*kScale_375));
        } else {
            make.width.mas_equalTo(@(90*kScale_375));
            make.height.mas_equalTo(@(153*kScale_375));
        }
    }];
    
    [self.productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.itemBgView.mas_leading);
        make.top.mas_equalTo(self.itemBgView.mas_top);
        if (APP_TYPE == 3) {
            make.width.mas_equalTo(@(90*kScale_375));
            make.height.mas_equalTo(@(90*kScale_375));
        } else {
            make.width.mas_equalTo(@(90*kScale_375));
            make.height.mas_equalTo(@(120*kScale_375));
        }
    }];
    
    //闪购标签
    [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_leading);
        make.top.mas_equalTo(self.productImgView.mas_top);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.productImgView.mas_leading).offset(4);
        make.top.mas_equalTo(self.productImgView.mas_bottom).offset(4);
        make.height.mas_equalTo(@(13*kScale_375));
    }];
    
    [self.oldPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.priceLabel.mas_leading);
        make.top.mas_equalTo(self.priceLabel.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-4);
        make.height.mas_equalTo(@(11*kScale_375));
    }];
}


- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
        _activityStateView.hidden = YES;
//        _activityStateView.samllImageShow = YES;
//        _activityStateView.flashImageSize = 12;
    }
    return _activityStateView;
}
@end
