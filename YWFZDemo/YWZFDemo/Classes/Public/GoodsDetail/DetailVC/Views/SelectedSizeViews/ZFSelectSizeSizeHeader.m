
//
//  ZFSelectSizeSizeHeader.m
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSelectSizeSizeHeader.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSelectSizeSizeHeader() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UIButton          *sizeGuideButton;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@end

@implementation ZFSelectSizeSizeHeader
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)sizeGuideButtonAction:(UIButton *)sender {
    if (self.sizeSelectGuideJumpCompletionHandler) {
        self.sizeSelectGuideJumpCompletionHandler(self.size_url);
    }
}

- (void)updateTopSpace:(CGFloat)space {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(space > 0 ? space : 16);
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
//    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.titleLabel];
    [self addSubview:self.arrowImageView];
    [self addSubview:self.sizeGuideButton];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(16);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
    
    [self.sizeGuideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-8);
    }];
}

#pragma mark - setter
#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setSize_url:(NSString *)size_url {
    _size_url = size_url;
    if ([NSStringUtils isEmptyString:size_url]) {
        self.arrowImageView.hidden = YES;
        self.sizeGuideButton.hidden = YES;
    } else {
        self.arrowImageView.hidden = NO;
        self.sizeGuideButton.hidden = NO;
    }
}

- (void)showSizeGuide:(BOOL)show {
    self.arrowImageView.hidden = !show;
    self.sizeGuideButton.hidden = !show;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _titleLabel.font = ZFFontSystemSize(14);
        _titleLabel.text = ZFLocalizedString(@"Size", nil);
    }
    return _titleLabel;
}

- (UIButton *)sizeGuideButton {
    if (!_sizeGuideButton) {
        _sizeGuideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sizeGuideButton setTitle:ZFLocalizedString(@"Detail_Product_SizeGuides", nil) forState:UIControlStateNormal];
        _sizeGuideButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _sizeGuideButton.titleLabel.font = ZFFontSystemSize(14);
        [_sizeGuideButton setTitleColor:ColorHex_Alpha(0x999999, 1.0) forState:UIControlStateNormal];
        [_sizeGuideButton addTarget:self action:@selector(sizeGuideButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sizeGuideButton;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"size_arrow_right"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

@end
