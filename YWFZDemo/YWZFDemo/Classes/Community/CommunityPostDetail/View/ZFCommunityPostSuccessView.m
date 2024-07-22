
//
//  ZFCommunityPostSuccessView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostSuccessView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCommunityPostSuccessView () <ZFInitViewProtocol>

@property (nonatomic, strong) UIView            *containView;
@property (nonatomic, strong) UIImageView       *successView;
@property (nonatomic, strong) UILabel           *titleLabel;
@end

@implementation ZFCommunityPostSuccessView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self addSubview:self.containView];
    [self.containView addSubview:self.successView];
    [self.containView addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(240 * ScreenWidth_SCALE, 160 * ScreenWidth_SCALE));
    }];
    
    [self.successView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.containView.mas_centerX);
        make.top.mas_equalTo(self.containView.mas_top).offset(30 * ScreenWidth_SCALE);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.containView.mas_centerX);
        make.leading.trailing.mas_equalTo(self.containView);
        make.top.mas_equalTo(self.successView.mas_bottom).offset(24 * ScreenWidth_SCALE);
    }];

}

#pragma mark - setter 
- (void)setPostSuccessMessage:(NSString *)postSuccessMessage {
    _postSuccessMessage = postSuccessMessage;
    self.titleLabel.text = _postSuccessMessage;
}

#pragma mark - getter
- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _containView;
}

- (UIImageView *)successView {
    if (!_successView) {
        _successView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _successView.image = [UIImage imageNamed:@"Point_Success"];
    }
    return _successView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.numberOfLines = 2;
        _titleLabel.text = ZFLocalizedString(@"Post_VC_Post_Success_Tips", nil);
    }
    return _titleLabel;
}

@end
