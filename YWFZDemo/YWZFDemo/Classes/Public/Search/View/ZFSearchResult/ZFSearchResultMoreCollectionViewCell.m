//
//  ZFSearchResultMoreCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/6/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultMoreCollectionViewCell.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

@interface ZFSearchResultMoreCollectionViewCell ()

@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZFSearchResultMoreCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = ZFC0xF2F2F2();
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.moreLabel];
    [self.contentView addSubview:self.imageView];
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.centerX.mas_equalTo(self.contentView.mas_centerX).offset(-8.0);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(12.0);
        make.centerY.mas_equalTo(self.moreLabel.centerY);
        make.leading.mas_equalTo(self.moreLabel.mas_trailing).offset(5.0);
    }];
}

#pragma mark - getter/setter
- (UILabel *)moreLabel {
    if (!_moreLabel) {
        _moreLabel = [[UILabel alloc] init];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.font = [UIFont systemFontOfSize:14];
        _moreLabel.text = ZFLocalizedString(@"search_result_matches_viewall", nil);
        _moreLabel.textColor = [UIColor colorWithHex:0x2d2d2d];
    }
    return _moreLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"search_result_matcharrow"];
    }
    return _imageView;
}

@end
