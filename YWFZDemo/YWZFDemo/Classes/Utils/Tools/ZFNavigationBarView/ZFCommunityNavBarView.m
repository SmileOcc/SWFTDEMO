//
//  ZFCommunityNavBarView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityNavBarView.h"
#import "Masonry.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"

@implementation ZFCommunityNavBarView

- (instancetype)initWithFrame:(CGRect)frame withMaxWidth:(CGFloat)maxWidth{
    self = [super initWithFrame:frame];
    if (self) {
        self.confirmMaxWidth = maxWidth;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
  
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeButton];
    [self addSubview:self.confirmButton];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.mas_centerY);
        if (self.confirmMaxWidth > 0) {
            make.width.mas_lessThanOrEqualTo(self.confirmMaxWidth);
        }
    }];
}

#pragma mark - action

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock(YES);
    }
}

- (void)actionConfirm:(UIButton *)sender {
    if (self.confirmBlock) {
        self.confirmBlock(YES);
    }
}


#pragma mark - Property Method

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    }
    return _closeButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(actionConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitle:ZFLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        _confirmButton.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);

    }
    return _confirmButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x2D2D2D();
        _titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _titleLabel;
}
@end
