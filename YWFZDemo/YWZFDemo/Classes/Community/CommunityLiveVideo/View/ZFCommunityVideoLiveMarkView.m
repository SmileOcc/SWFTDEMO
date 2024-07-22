//
//  ZFCommunityVideoLiveMarkView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityVideoLiveMarkView.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"

@interface ZFCommunityVideoLiveMarkView()

@property (nonatomic, strong) UIColor               *dotColor;
@property (nonatomic, strong) UIColor               *textColor;
@property (nonatomic, strong) UIImage               *markImage;

@property (nonatomic, strong) UIView                *dotView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *timeLabel;

@property (nonatomic, strong) YYAnimatedImageView   *markImageView;

@property (nonatomic, assign) UIRectCorner          corners;



@end

@implementation ZFCommunityVideoLiveMarkView

- (instancetype)initWithFrame:(CGRect)frame markImage:(UIImage *)markImage dotColor:(UIColor *)dotColor textColor:(UIColor *)textColor addCorners:(UIRectCorner)corners {
    if (self = [super initWithFrame:frame]) {
        
        self.corners = corners;
        self.dotColor = dotColor ? dotColor : ZFC0xFE5269();
        self.textColor = textColor ? textColor : ZFC0x000000();
        self.markImage = markImage;
        self.dotView.hidden = markImage ? YES : NO;
        self.markImageView.hidden = markImage ? NO : YES;
        
        [self addSubview:self.dotView];
        [self addSubview:self.markImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.timeLabel];
        
        self.markImageView.image = self.markImage;
        self.dotView.backgroundColor = self.dotColor;
        self.titleLabel.textColor = self.textColor;
        
        [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(4);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(6, 6));
        }];
        
        [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(6);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(6);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(4);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-4);
            make.leading.mas_equalTo(self.markImageView.mas_trailing).offset(4);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-6);
        }];
        
        
    }
    return self;
}

- (void)updateMarkImage:(UIImage *)markImage text:(id)text {
    
    self.markImage = markImage;
    self.dotView.hidden = markImage ? YES : NO;
    self.markImageView.hidden = markImage ? NO : YES;
    self.markImageView.image = markImage;
    
    if ([text isKindOfClass:[NSAttributedString class]]) {
        self.titleLabel.attributedText = text;
    } else {
        self.titleLabel.text = ZFToString(text);
    }
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] initWithFrame:CGRectZero];
        _dotView.layer.cornerRadius = 3.0;
        _dotView.backgroundColor = ZFC0xFE5269();
        _dotView.layer.masksToBounds = YES;
    }
    return _dotView;
}

- (YYAnimatedImageView *)markImageView {
    if (!_markImageView) {
        _markImageView = [[YYAnimatedImageView alloc] init];
    }
    return _markImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0xFFFFFF();
        _titleLabel.font = ZFFontSystemSize(14);
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self zfAddCorners:self.corners cornerRadii:CGSizeMake(2, 2)];
}
@end
