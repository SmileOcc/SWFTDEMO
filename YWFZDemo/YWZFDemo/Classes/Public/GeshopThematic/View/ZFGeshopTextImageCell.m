//
//  ZFGeshopTextImageCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopTextImageCell.h"
#import "ZFInitViewProtocol.h"
#import <YYWebImage/YYWebImage.h>
#import "UIColor+ExTypeChange.h"
#import "ZFBannerTimeView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGeshopTextImageCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *bgImageView;
@property (nonatomic, strong) UILabel               *textLabel;
@end

@implementation ZFGeshopTextImageCell

@synthesize sectionModel = _sectionModel;

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
    [self.contentView addSubview:self.bgImageView];
    [self.contentView addSubview:self.textLabel];
}

- (void)zfAutoLayoutView {
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    
    ZFGeshopComponentStyleModel *styleModel = sectionModel.component_style;

    self.bgImageView.backgroundColor = [UIColor colorWithAlphaHexColor:styleModel.bg_color
    defaultColor:ZFCOLOR_WHITE];

    if (!ZFIsEmptyString(styleModel.bg_img)) {
        [self.bgImageView yy_setImageWithURL:[NSURL URLWithString:styleModel.bg_img]
                               placeholder:[UIImage imageNamed:@"loading_AdvertBg"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
    } else {
        self.bgImageView.image = nil;
    }

    if (styleModel.text_size > 0) {
        if (styleModel.text_style == 1) {
            self.textLabel.font = [UIFont boldSystemFontOfSize:styleModel.text_size];
        } else {
            self.textLabel.font = [UIFont systemFontOfSize:styleModel.text_size];
        }
    } else {
        self.textLabel.font = ZFFontSystemSize(14);
    }
    self.textLabel.text = ZFToString(sectionModel.component_data.title);

    self.textLabel.textColor = [UIColor colorWithAlphaHexColor:styleModel.text_color
                                              defaultColor:ZFCOLOR(51, 51, 51, 1)];

    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(styleModel.padding_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-styleModel.padding_bottom);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        if (styleModel.width > 0) {
            make.width.mas_equalTo(styleModel.width);
        }
        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width);
    }];
}

#pragma mark - Getter

- (YYAnimatedImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[YYAnimatedImageView alloc] init];
        _bgImageView.backgroundColor = ZFCOLOR_WHITE;
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds  = YES;
    }
    return _bgImageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = ZFFontSystemSize(14);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.preferredMaxLayoutWidth = KScreenWidth - 20;
        _textLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

@end
