//
//  ZFSearchMapPreView.m
//  ZZZZZ
//
//  Created by YW on 23/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMapPreView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFSearchMapPreView()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton      *cropButton;
@property (nonatomic, strong) UIImageView   *cropImageView;
@property (nonatomic, strong) UILabel       *resultLabel;
@property (nonatomic, strong) UILabel       *tipLabel;
@end

@implementation ZFSearchMapPreView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.cropButton];
    [self.cropButton addSubview:self.cropImageView];
    [self addSubview:self.resultLabel];
    [self addSubview:self.tipLabel];
}

- (void)zfAutoLayoutView {
    [self.cropButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(12);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.cropImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(29, 29));
    }];
    
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.cropButton.mas_trailing).offset(12);
        make.top.equalTo(self.cropButton.mas_top).offset(0);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.resultLabel.mas_leading);
        make.top.equalTo(self.resultLabel.mas_bottom).offset(6);
    }];
}

#pragma mark - Action
- (void)cropImageClick {
    if (self.cropImageHandler) {
        self.cropImageHandler(self.sourceImage);
    }
}

#pragma mark - Setter
- (void)setSourceImage:(UIImage *)sourceImage {
    _sourceImage = sourceImage;
    if (sourceImage) {
        UIImage *cropImage = [sourceImage yy_imageByResizeToSize:CGSizeMake(60, 60) contentMode:UIViewContentModeScaleAspectFill];
        [self.cropButton setImage:cropImage forState:UIControlStateNormal];
    }
}

- (void)setTotalNum:(NSString *)totalNum {
    _totalNum = totalNum;
    self.resultLabel.text = [NSString stringWithFormat:@"%@ %@",totalNum,ZFLocalizedString(@"result", nil)];
}

#pragma mark - Getter
- (UIButton *)cropButton {
    if (!_cropButton) {
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cropButton.backgroundColor = ZFCOLOR_WHITE;
        [_cropButton addTarget:self action:@selector(cropImageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cropButton;
}

- (UIImageView *)cropImageView {
    if (!_cropImageView) {
        _cropImageView = [[UIImageView alloc] init];
        _cropImageView.image = ZFImageWithName(@"camera_crop");
        [_cropImageView convertUIWithARLanguage];
    }
    return _cropImageView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.font = ZFFontSystemSize(16);
        _resultLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _resultLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _tipLabel.font = ZFFontSystemSize(14);
        _tipLabel.text = ZFLocalizedString(@"crop_tip", nil);
        _tipLabel.numberOfLines = 0;
        _tipLabel.preferredMaxLayoutWidth = KScreenWidth - 96;
    }
    return _tipLabel;
}


@end
