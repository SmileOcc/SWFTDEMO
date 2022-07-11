//
//  OSSVTransporSplitCollectionCCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransporSplitCollectionCCell.h"

@implementation OSSVTransporSplitCollectionCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.productImgView];
        [self.productImgView addSubview:self.numberLabel];
    }
    
    return self;
}

- (YYAnimatedImageView *)productImgView {
    if (!_productImgView) {
        _productImgView = [YYAnimatedImageView new];
        _productImgView.backgroundColor = [UIColor clearColor];
        _productImgView.contentMode = UIViewContentModeScaleAspectFit;
        _productImgView.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _productImgView.layer.borderWidth = 0.5f;
        _productImgView.layer.masksToBounds = YES;
    }
    return _productImgView;
}
-(UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [UILabel new];
        _numberLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _numberLabel.font = [UIFont systemFontOfSize:11];
        _numberLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.text = @"X2";
    }
    return _numberLabel;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.productImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.productImgView);
        make.height.equalTo(16);
    }];
}
@end
