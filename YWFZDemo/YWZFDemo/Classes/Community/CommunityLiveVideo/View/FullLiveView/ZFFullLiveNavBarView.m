//
//  ZFFullLiveNavBarView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveNavBarView.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"
#import "UIButton+ZFButtonCategorySet.h"

@implementation ZFFullLiveNavBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isHotBanner = NO;
        self.userControlView.hidden = YES;
        self.liveStateContentView.hidden = NO;
        
        self.userControlView.hidden = YES;
        self.stateImageView.hidden = YES;
        self.liveStateContentView.hidden = YES;
        
        
        [self addSubview:self.userControlView];
        [self.userControlView addSubview:self.userImageView];
        [self.userControlView addSubview:self.userNameLabel];
        [self.userControlView addSubview:self.eyeImageView];
        [self.userControlView addSubview:self.eyeNumsLabel];
        [self.userControlView addSubview:self.userArrowImageView];
        [self addSubview:self.stateImageView];
        
        [self addSubview:self.liveStateContentView];
        [self.liveStateContentView addSubview:self.redDotView];
        [self.liveStateContentView addSubview:self.liveStateLabel];
        [self.liveStateContentView addSubview:self.liveEyeImageView];
        [self.liveStateContentView addSubview:self.liveEyeNumsLabel];

        /////
        [self.userControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(36);
            make.width.mas_lessThanOrEqualTo(190);
        }];
        
        [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userControlView.mas_leading);
            make.centerY.mas_equalTo(self.userControlView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
        
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8);
            make.bottom.mas_equalTo(self.userControlView.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(35);
        }];
        
        [self.eyeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8);
            make.top.mas_equalTo(self.userControlView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(14, 12));
        }];
        
        [self.eyeNumsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.eyeImageView.mas_trailing);
            make.centerY.mas_equalTo(self.eyeImageView.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(20);
        }];
        
        [self.userArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.userControlView.mas_centerY);
            make.trailing.mas_equalTo(self.userControlView.mas_trailing).offset(-10);
            make.leading.mas_equalTo(self.userNameLabel.mas_trailing).offset(5);
            make.leading.mas_equalTo(self.eyeNumsLabel.mas_trailing).offset(5);
        }];
        
        [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.userImageView.mas_centerX);
            make.centerY.mas_equalTo(self.userImageView.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(24, 11));
        }];
        
        ////
        [self.liveStateContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(24);
            make.width.mas_lessThanOrEqualTo(190);
        }];
        
        [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.liveStateContentView.mas_leading).offset(8);
            make.centerY.mas_equalTo(self.liveStateContentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(6, 6));
        }];
        
        [self.liveStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.redDotView.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.liveStateContentView.mas_centerY);
        }];
        
        [self.liveEyeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.liveStateLabel.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.liveStateContentView.mas_centerY);
        }];
        
        [self.liveEyeNumsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.liveEyeImageView.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.liveStateContentView.mas_centerY);
            make.trailing.mas_equalTo(self.liveStateContentView.mas_trailing).offset(-8);
        }];
        
        
        [self.liveEyeNumsLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.liveStateLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.liveStateLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)showBackArrowAnimate:(BOOL)animate {
    
}
#pragma mark - XXX Action
- (void)actionUser:(UIControl *)sender {
    if (self.actionUserBlock) {
        self.actionUserBlock();
    }
}

#pragma mark - Property Method

- (void)setEyeNums:(NSInteger)eyeNums {
    if (eyeNums <= 0) {
        eyeNums = 0;
    }
    
    //111,222,333,444
    if (!_formatter) {
        self.formatter = [[NSNumberFormatter alloc]init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
   
    NSString * format_view_num = [self.formatter stringFromNumber:[NSNumber numberWithInteger:eyeNums]];
    self.eyeNumsLabel.text = [NSString stringWithFormat:@"%@ %@",format_view_num,ZFLocalizedString(@"Community_Lives_Live_Views", nil)];
    self.liveEyeNumsLabel.text = [NSString stringWithFormat:@"%@ %@",format_view_num,ZFLocalizedString(@"Community_Lives_Live_Views", nil)];
}

- (void)setUserImageUrl:(NSString *)userImageUrl {
    _userImageUrl = userImageUrl;
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:ZFToString(userImageUrl)] placeholder:[UIImage imageNamed:@"live_default_user"]];
}

- (void)setUserName:(NSString *)userName {
    self.userNameLabel.text = ZFIsEmptyString(userName) ? ZFLocalizedString(@"Community_LivesVideo_Host", nil) : ZFToString(userName);
}

- (void)setIsHideUserInfo:(BOOL)isHideUserInfo {
    _isHideUserInfo = isHideUserInfo;
    
    if ((isHideUserInfo && !self.isLiving && !self.isHotBanner) || self.isVideo) {
        if (self.isVideo && self.isHotBanner) {
            self.isHotBanner = self.isHotBanner;
        } else {
            [self hideUserInfoView];
        }
    } else {
        self.isLiving = self.isLiving;
        self.isHotBanner = self.isHotBanner;
    }
}
- (void)setIsHotBanner:(BOOL)isHotBanner {
    _isHotBanner = isHotBanner;
    
    if (self.isHideUserInfo) {
        self.isHideUserInfo = NO;
    } else {
        self.userControlView.hidden = !isHotBanner;
        self.liveStateContentView.hidden = isHotBanner;
        
        if(isHotBanner) {
            self.stateImageView.hidden = self.isLiving ? NO : YES;
        } else {
            self.stateImageView.hidden = YES;
        }
        
        if (self.isVideo) {
            self.liveStateContentView.hidden = YES;
            self.stateImageView.hidden = YES;
        }
    }
}

- (void)setIsLiving:(BOOL)isLiving {
    _isLiving = isLiving;
    
    if (self.isHideUserInfo) {
        if (_isLiving && !self.isVideo) {
            self.isHideUserInfo = NO;
        }
  
    } else if (self.isHotBanner) {
        self.userControlView.hidden = !self.isHotBanner;
        self.liveStateContentView.hidden = self.isHotBanner;
        self.stateImageView.hidden = self.isLiving ? NO : YES;
        if (self.isVideo) {
            self.stateImageView.hidden = YES;
        }
        
    } else if(!self.isVideo){
        
        if (isLiving) {
            self.redDotView.hidden = NO;
            self.liveStateLabel.text = ZFLocalizedString(@"live_live", nil);
            [self.liveStateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.redDotView.mas_trailing).offset(2);
            }];
        } else {
            self.redDotView.hidden = YES;
            self.liveStateLabel.text = @"";
            [self.liveStateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.redDotView.mas_trailing).offset(-8);
            }];
        }
        self.liveStateContentView.hidden = NO;
        self.userControlView.hidden = YES;
        self.stateImageView.hidden = YES;
    }
}

- (void)setIsVideo:(BOOL)isVideo {
    _isVideo = isVideo;
    if (_isVideo) {
        _isLiving = NO;
        self.isHideUserInfo = YES;
    }
}

- (void)hideUserInfoView {
    self.userControlView.hidden = YES;
    self.liveStateContentView.hidden = YES;
    self.stateImageView.hidden = YES;
}

- (UIControl *)userControlView {
    if (!_userControlView) {
        _userControlView = [[UIControl alloc] initWithFrame:CGRectZero];
        _userControlView.layer.cornerRadius = 18.0;
        _userControlView.layer.masksToBounds = YES;
        _userControlView.backgroundColor = ZFC0x000000_A(0.2);
        [_userControlView addTarget:self action:@selector(actionUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userControlView;
}

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.image = [UIImage imageNamed:@"live_default_user"];
        _userImageView.layer.cornerRadius = 18.0;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNameLabel.textColor = ZFC0xFFFFFF();
        _userNameLabel.font = [UIFont systemFontOfSize:14];
        _userNameLabel.text = ZFLocalizedString(@"Community_LivesVideo_Host", nil);
    }
    return _userNameLabel;
}

- (UIImageView *)eyeImageView {
    if (!_eyeImageView) {
        _eyeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _eyeImageView.image = [UIImage imageNamed:@"live_eyes"];
    }
    return _eyeImageView;
}

- (UILabel *)eyeNumsLabel {
    if (!_eyeNumsLabel) {
        _eyeNumsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _eyeNumsLabel.textColor = ZFC0xFFFFFF();
        _eyeNumsLabel.font = [UIFont systemFontOfSize:10];
    }
    return _eyeNumsLabel;
}

- (UIImageView *)userArrowImageView {
    if (!_userArrowImageView) {
        _userArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userArrowImageView.image = [UIImage imageNamed:@"live_user_arrow"];
    }
    return _userArrowImageView;
}

- (YYAnimatedImageView *)stateImageView {
    if (!_stateImageView) {
        _stateImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _stateImageView.hidden = YES;
        _stateImageView.image = [YYImage imageNamed:@"live_popple.gif"];
    }
    return _stateImageView;
}

////////

- (UIView *)liveStateContentView {
    if (!_liveStateContentView) {
        _liveStateContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _liveStateContentView.layer.cornerRadius = 12.0;
        _liveStateContentView.layer.masksToBounds = YES;
        _liveStateContentView.backgroundColor = ZFC0x000000_A(0.2);
    }
    return _liveStateContentView;
}

- (YYAnimatedImageView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _redDotView.image = [YYImage imageNamed:@"live_red_animation.gif"];
    }
    return _redDotView;
}
- (UILabel *)liveStateLabel {
    if (!_liveStateLabel) {
        _liveStateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _liveStateLabel.textColor = ZFC0xFFFFFF();
        _liveStateLabel.font = [UIFont systemFontOfSize:10];
        _liveStateLabel.text = ZFLocalizedString(@"live_live", nil);
    }
    return _liveStateLabel;
}

- (UIImageView *)liveEyeImageView {
    if (!_liveEyeImageView) {
        _liveEyeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _liveEyeImageView.image = [UIImage imageNamed:@"live_eyes"];
    }
    return _liveEyeImageView;
}

- (UILabel *)liveEyeNumsLabel {
    if (!_liveEyeNumsLabel) {
        _liveEyeNumsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _liveEyeNumsLabel.textColor = ZFC0xFFFFFF();
        _liveEyeNumsLabel.font = [UIFont systemFontOfSize:8];
    }
    return _liveEyeNumsLabel;
}
@end
