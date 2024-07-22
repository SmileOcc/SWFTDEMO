//
//  ZFFullLiveErrorView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveErrorView.h"
#import "ZFProgressHUD.h"

@interface ZFFullLiveErrorView()

@property (nonatomic, strong) YYAnimatedImageView   *recodImageView;
@property (nonatomic, strong) UILabel               *titleLabel;

@property (nonatomic, strong) UIButton              *refreshButton;
@property (nonatomic, strong) UIButton              *changeLineButton;
@property (nonatomic, strong) UIButton              *closeButton;


@property (nonatomic, strong) UIView                *lineContentView;
@property (nonatomic, strong) UILabel               *lineTitleLabel;




@end

@implementation ZFFullLiveErrorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self addSubview:self.closeButton];
        [self addSubview:self.recodImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.refreshButton];
        [self addSubview:self.changeLineButton];
        
        [self addSubview:self.lineContentView];
        [self.lineContentView addSubview:self.lineTitleLabel];
        
        CGFloat navbSpace = (44 - 36) / 2.0;
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.top.mas_equalTo(self.mas_top).offset(IPHONE_X_5_15 ? (20 + navbSpace) : navbSpace);
        }];
        
        [self.recodImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_centerY).offset(-10);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(20);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
            make.top.mas_equalTo(self.recodImageView.mas_bottom);
        }];
        
        [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
            make.height.mas_equalTo(36);
            make.width.mas_lessThanOrEqualTo(160);
            make.width.mas_greaterThanOrEqualTo(120);
        }];
        
        [self.changeLineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_centerX).offset(6);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(160);
        }];
        
        [self.lineContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(400);
            make.width.mas_equalTo(330);
        }];
        
        [self.lineTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.lineContentView.mas_leading).offset(20);
            make.trailing.mas_equalTo(self.lineContentView.mas_trailing).offset(-20);
            make.top.mas_equalTo(self.lineContentView.mas_top).offset(20);
        }];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIColor *gradColor = [UIView bm_colorGradientChangeWithSize:self.frame.size direction:IHGradientChangeDirectionVertical startColor:ColorHex_Alpha(0x524A5F, 1.0) endColor:ColorHex_Alpha(0x2E2B3F, 1.0)];
    self.backgroundColor = gradColor;
}

- (void)showError:(BOOL)show {
    
}
- (void)configurateRotes:(NSArray<ZFCommunityLiveRouteModel *> *)rotes {
    
    self.rotes = rotes;
    self.lineContentView.hidden = YES;
    self.changeLineButton.hidden = YES;
    self.refreshButton.hidden = YES;
}

- (void)updateLiveCoverState:(LiveZegoCoverState)coverState {
 
    if (loadingViewFromView(self)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            HideLoadingFromView(self);
        });
    }
    if (coverState == LiveZegoCoverStateUpdateStreamSuccess) {
        self.hidden = YES;
        return;
    }
    
    self.lineContentView.hidden = YES;
    self.recodImageView.hidden = NO;
    self.titleLabel.hidden = NO;
//    if (coverState == LiveZegoCoverStateReConnectRoomFail) {
//        
//        self.changeLineButton.hidden = YES;
//        self.refreshButton.hidden = NO;
//        [self.refreshButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(self.mas_centerX);
//            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
//            make.height.mas_equalTo(36);
//           make.width.mas_lessThanOrEqualTo(160);
//           make.width.mas_greaterThanOrEqualTo(120);
//        }];
//        
//    } else
//        if(coverState == LiveZegoCoverStateUpdateStreamFail) {
//
//    }
    
    if (ZFJudgeNSArray(self.rotes) && self.rotes.count > 1) {
        
        self.changeLineButton.hidden = NO;
        self.refreshButton.hidden = NO;
        
        [self.refreshButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_centerX).offset(-6);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(160);
        }];
    } else {
        
        self.changeLineButton.hidden = YES;
        self.refreshButton.hidden = NO;
        [self.refreshButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
            make.height.mas_equalTo(36);
           make.width.mas_lessThanOrEqualTo(160);
           make.width.mas_greaterThanOrEqualTo(120);
        }];
    }
}

- (void)endLoading:(BOOL)success {
    HideLoadingFromView(self);
    if (success) {
        self.hidden = YES;
    }
}

- (void)actionRefresh:(UIButton *)sender {
    
    // 延迟只是为了显示加载视图
    ShowLoadingToView(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.refreshBlock) {
            self.refreshBlock();
        }
    });
}

- (void)actionChangeLine:(UIButton *)sender {
    
    self.recodImageView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.refreshButton.hidden = YES;
    self.changeLineButton.hidden = YES;
    self.lineContentView.hidden = NO;
}

- (void)actionClose:(UIButton *)sender {
    
    if (!self.lineContentView.isHidden) {
        self.lineContentView.hidden = YES;
        
        self.recodImageView.hidden = NO;
        self.titleLabel.hidden = NO;
        self.refreshButton.hidden = NO;
        self.changeLineButton.hidden = NO;
        
    } else {
        if (self.closeBlock) {
            self.closeBlock();
        }
    }
}

- (void)actionLine:(UIButton *)sender {
    NSInteger tag = sender.tag - 220000;
    if (tag >= 0 && self.rotes.count > tag) {
        ZFCommunityLiveRouteModel *model = self.rotes[tag];
        if (self.changeRoteBlock) {
            self.changeRoteBlock(model);
        }
    }
    self.hidden = YES;
}

- (void)createLineButtons {
    NSArray *subViews = self.lineContentView.subviews;
    for (UIView *subView in subViews) {
        if (subView != self.lineTitleLabel) {
            [subView removeFromSuperview];
        }
    }
    if (ZFJudgeNSArray(self.rotes) && self.rotes.count) {
        
        UIButton *tempButton;
        for (int i=0; i<self.rotes.count; i++) {
            
            UIButton *button = [self createItemButton];
            button.tag = 220000 + i;
            NSString *lineTitle = [NSString stringWithFormat:@"%@ %i",ZFLocalizedString(@"Live_line", nil),(i+1)];
            [button setTitle:lineTitle forState:UIControlStateNormal];
            [self.lineContentView addSubview:button];
            
            
            if (!tempButton) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.trailing.mas_equalTo(self.lineContentView.mas_centerX).offset(-8);
                    make.top.mas_equalTo(self.lineTitleLabel.mas_bottom).offset(30);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(36);
                    
                }];
            } else {
                if (i%2) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.mas_equalTo(tempButton.mas_trailing).offset(8);
                        make.top.mas_equalTo(tempButton.mas_top);
                        make.width.mas_equalTo(120);
                        make.height.mas_equalTo(36);
                    }];
                } else {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.mas_equalTo(self.lineContentView.mas_centerX).offset(-8);
                        make.top.mas_equalTo(tempButton.mas_bottom).offset(20);
                        make.width.mas_equalTo(120);
                        make.height.mas_equalTo(36);
                    }];
                }
            }

            tempButton = button;
        }
        
    }
}

- (UIButton *)createItemButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = ZFC0xFFFFFF();
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.titleLabel.numberOfLines = 2;
    [button setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    button.layer.cornerRadius = 18;
    button.layer.masksToBounds = YES;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [button addTarget:self action:@selector(actionLine:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Property Method

- (void)setRotes:(NSArray<ZFCommunityLiveRouteModel *> *)rotes {
    _rotes = rotes;
    [self createLineButtons];
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (YYAnimatedImageView *)recodImageView {
    if (!_recodImageView) {
        _recodImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _recodImageView.image = [UIImage imageNamed:@"live_record"];
    }
    return _recodImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFC0xFFFFFF();
        _titleLabel.text = ZFLocalizedString(@"Live_download_livestream_fail", nil);
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.backgroundColor = ZFC0xFFFFFF();
        _refreshButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_refreshButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_refreshButton setTitle:ZFLocalizedString(@"Live_Network_Refresh", nil) forState:UIControlStateNormal];
        _refreshButton.layer.cornerRadius = 18;
        _refreshButton.layer.masksToBounds = YES;
        _refreshButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_refreshButton addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (UIButton *)changeLineButton {
    if (!_changeLineButton) {
        _changeLineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeLineButton.backgroundColor = ZFC0xFFFFFF();
        _changeLineButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_changeLineButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_changeLineButton setTitle:ZFLocalizedString(@"Live_switch_line", nil) forState:UIControlStateNormal];
        _changeLineButton.layer.cornerRadius = 18;
        _changeLineButton.layer.masksToBounds = YES;
        _changeLineButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_changeLineButton addTarget:self action:@selector(actionChangeLine:) forControlEvents:UIControlEventTouchUpInside];
        _changeLineButton.hidden = YES;
    }
    return _changeLineButton;
}

- (UIView *)lineContentView {
    if (!_lineContentView) {
        _lineContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _lineContentView;
}

- (UILabel *)lineTitleLabel {
    if (!_lineTitleLabel) {
        _lineTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        _lineTitleLabel.textAlignment = NSTextAlignmentCenter;
        _lineTitleLabel.textColor = ZFC0xFFFFFF();
        _lineTitleLabel.text = ZFLocalizedString(@"Live_livestream_line", nil);
    }
    return _lineTitleLabel;
}
@end
