//
//  ZFCommunityLiveWaitView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveWaitView.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFCountDownView.h"
#import "ZFThemeManager.h"
#import "ZFTimerManager.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFCommunityLiveWaitView()

@property (nonatomic, strong) UIView               *topView;
@property (nonatomic, strong) UIButton             *backButton;
@property (nonatomic, strong) UIButton             *cartButton;

@property (nonatomic, strong) UILabel              *descLabel;
@property (nonatomic, strong) YYAnimatedImageView  *imageView;
@property (nonatomic, strong) ZFCountDownView      *timeDownView;


@end

@implementation ZFCommunityLiveWaitView

- (void)dealloc {
    YWLog(@"---------%@ 释放啊 ",NSStringFromClass(self.class));
    [[ZFTimerManager shareInstance] stopTimer:_inforModel.startTimerKey];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.topView];
        [self.topView addSubview:self.backButton];
        [self.topView addSubview:self.cartButton];
        
        [self addSubview:self.descLabel];
        [self addSubview:self.imageView];
        [self addSubview:self.timeDownView];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(44);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.topView.mas_leading).offset(16);
            make.centerY.mas_equalTo(self.topView.mas_centerY);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton.mas_centerY);
            make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-16);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.descLabel.mas_top).offset(-10);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        CGFloat tempHeight = [self.timeDownView heightTimerLump];
        [self.timeDownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.descLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(tempHeight);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
    }
    return self;
}


- (void)stopTimer {
    [[ZFTimerManager shareInstance] stopTimer:_inforModel.startTimerKey];
}

- (void)actionBack:(UIButton *)sender {
    if (self.gobackBlock) {
        self.gobackBlock(YES);
    }
}

- (void)actionCart:(UIButton *)sender {
    if (self.cartBlock) {
        self.cartBlock(YES);
    }
}

#pragma mark - Property Method
- (void)setInforModel:(ZFCommunityLiveWaitInfor *)inforModel {
    _inforModel = inforModel;
    
    self.descLabel.text = ZFToString(inforModel.content);
    [[ZFTimerManager shareInstance] startTimer:inforModel.startTimerKey];
    [self.timeDownView startTimerWithStamp:inforModel.time timerKey:inforModel.startTimerKey];
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"camera_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [_backButton convertUIWithARLanguage];
    }
    return _backButton;
}


- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[UIImage imageNamed:@"cart_bag_white"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(actionCart:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        
    }
    return _cartButton;
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"community_play_wait_hourglass"]];
    }
    return _imageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = ZFC0xFFFFFF();
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

- (ZFCountDownView *)timeDownView {
    if (!_timeDownView) {
        _timeDownView = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:20 showDay:YES];
        _timeDownView.timerCircleRadius = 4;
        _timeDownView.timerTextBackgroundColor = ZFC0x2D2D2D();
        _timeDownView.timerTextColor = ZFC0xFFFFFF();
        _timeDownView.timerBackgroundColor = ZFCClearColor();
    }
    return _timeDownView;
}
@end
