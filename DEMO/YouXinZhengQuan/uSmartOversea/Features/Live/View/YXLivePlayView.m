//
//  YXLivePlayView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLivePlayView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "NSDictionary+Category.h"
#import "YXLiveBackgroundTool.h"

@implementation YXLiveWatchEndView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    
    UILabel *titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"live_end_tip"] textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:22 weight:UIFontWeightMedium]];
    UILabel *countTitleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"live_viewer_count"] textColor:[UIColor.whiteColor colorWithAlphaComponent:0.6] textFont:[UIFont systemFontOfSize:16]];
    self.countLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:22 weight:UIFontWeightMedium]];
    
    [self addSubview:titleLabel];
    [self addSubview:countTitleLabel];
    [self addSubview:self.countLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(60);
        make.height.mas_equalTo(30);
    }];
    
    [countTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(114);
        make.height.mas_equalTo(22);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(136);
        make.height.mas_equalTo(25);
    }];
    
}

@end


@interface YXLivePlayView() //<TXLivePlayListener>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *startBtn;

@property (nonatomic, strong) UIButton *ratoBtn;

@property (nonatomic, strong) CAGradientLayer *bottomGl;

@end

@implementation YXLivePlayView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}


#pragma mark - 设置UI
- (void)setUI {
 
    self.backgroundColor = UIColor.blackColor;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self startPlay];
    
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(43);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(43);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:tap];
    
    [self hiddenStatus];
    
    @weakify(self);
    [[self.startBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
//        if (!self.startBtn.selected) {
//            [self.txLivePlayer pause];
//        } else {
//            [self.txLivePlayer resume];
//        }
        self.startBtn.selected = !self.startBtn.selected;
    }];
    
    [[self.ratoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self transformVideo];
    }];
}


- (void)tapClick {
    if (self.bottomView.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            if (self.isFullScreen) {
                self.topView.hidden = YES;
            } else {
                self.topView.hidden = NO;
            }
            self.bottomView.hidden = NO;
            [self performSelector:@selector(hiddenStatus) withObject:nil afterDelay:3];
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bottomGl.frame = self.bottomView.bounds;
}


- (void)hiddenStatus {
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
}

- (void)setCountStr:(NSString *)countStr {
    _countStr = countStr;
    self.watchCountLabel.text = [NSString stringWithFormat:@"%@:%@", [YXLanguageUtility kLangWithKey:@"live_viewer_count"], countStr];
}

- (void)transformVideo {
//    self.isFullScreen = !self.isFullScreen;
    self.scaleCallBack(self.isFullScreen);
//    if (self.txLivePlayer.isPlaying) {
//        [self.txLivePlayer pause];
//    }
//    if (self.isFullScreen) {
//        self.topView.hidden = YES;
//    } else {
//        self.topView.hidden = NO;
//    }
//    if (!self.isPortrait) {
//        if (self.isFullScreen) {
//            [self.txLivePlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
//        } else {
//            [self.txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
//        }
//    }
//
//    if (self.isFullScreen && !self.isPortrait) {
//        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.mas_left).offset(20);
//            make.centerY.equalTo(self).offset(10);
//            make.width.mas_equalTo(YXConstant.screenHeight - 40);
//            make.height.mas_equalTo(43);
//        }];
//    } else {
//        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.bottom.right.equalTo(self);
//            make.height.mas_equalTo(43);
//        }];
//    }
//
//    self.bottomView.hidden = YES;
//    [UIView animateWithDuration:1 animations:^{
//        if (self.isFullScreen && !self.isPortrait) {
//            self.bottomView.transform = CGAffineTransformMakeRotation(M_PI_2);
//        } else {
//            self.bottomView.transform = CGAffineTransformIdentity;
//        }
//    } completion:^(BOOL finished) {
//        if (self.isFullScreen && !self.isPortrait) {
//            self.bottomView.transform = CGAffineTransformMakeRotation(M_PI_2);
//        } else {
//            self.bottomView.transform = CGAffineTransformIdentity;
//        }
//        self.bottomView.hidden = NO;
//    }];
}

-(void)setIsPlaying:(BOOL)isPlaying
{
//    _isPlaying = isPlaying;
//    if (isPlaying && self.txLivePlayer.isPlaying == NO ) {
//        [self.txLivePlayer resume];
//        self.startBtn.selected = NO;
//    }
//
//    if (isPlaying == NO ) {
//        [self.txLivePlayer pause];
//        self.startBtn.selected = YES;
//    }

}

#pragma mark - 前后台切换
- (void)willResignActive:(NSNotification *)notification {
//    if (self.txLivePlayer.isPlaying) {
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//        [YXLiveBackgroundTool setBackGroundWithLive:self.liveModel andCallBack:^(YXPlayEvent event) {
//            if (event == YXPlayEventPlay) {
//                [self.txLivePlayer resume];
//                self.startBtn.selected = NO;
//            } else {
//                [self.txLivePlayer pause];
//                self.startBtn.selected = YES;
//            }
//        }];
//    }
}

- (void)didBecomeActive:(NSNotification *)notification {
//    if (self.txLivePlayer) {
//        [self.txLivePlayer resume];
//    }
}


- (void)startPlay {
//    self.txLivePlayer = [[TXLivePlayer alloc] init];
//    self.txLivePlayer.delegate = self;
//    // 设置裁剪
//    [self.txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
//
//    [self.txLivePlayer setupVideoWidget:self.bounds containView:self insertIndex:0];
}

- (void)setShowUrl:(NSString *)showUrl {
    _showUrl = showUrl;
    if (showUrl.length == 0) {
        return;
    }
   // [self.txLivePlayer startPlay:showUrl type:PLAY_TYPE_LIVE_FLV];
}

- (void)closeFullScreen {
    
    [self transformVideo];
}


#pragma mark - txlive
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {

//    if (EvtID == PLAY_EVT_PLAY_BEGIN) {
//        // 播放开始
//        NSLog(@"");
//    } else if (EvtID == PLAY_EVT_PLAY_LOADING) {
//        // 加载中
//        NSLog(@"");
//    } else if (EvtID == PLAY_EVT_CHANGE_RESOLUTION) {
//        // 分辨率改变
//        NSLog(@"");
//        CGFloat width = [param yx_intValueForKey:@"EVT_PARAM1"];
//        CGFloat height = [param yx_intValueForKey:@"EVT_PARAM2"];
//        if (width < height) {
//            self.isPortrait = YES;
//        } else {
//            self.isPortrait = NO;
//        }
//    } else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END) {
//        // 直播结束
//        [self.txLivePlayer startPlay:self.showUrl type:PLAY_TYPE_LIVE_FLV];
//    }
}

- (void)onNetStatus:(NSDictionary *)param {
    
    
}

#pragma mark - lazy load

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] init];
        _topView.clipsToBounds = YES;
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,YXConstant.screenWidth,43);
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 0.94);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        [_topView.layer insertSublayer:gl atIndex:0];
        
//        _topView
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_people"]];
        [_topView addSubview:imageView];
        [_topView addSubview:self.watchCountLabel];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView).offset(12);
            make.centerY.equalTo(self.topView);
            make.width.height.mas_equalTo(16);
        }];
        
        [self.watchCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(3);
            make.centerY.equalTo(self.topView);
        }];
        
    }
    return _topView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.clipsToBounds = YES;
        // gradient
        CAGradientLayer *gl = [CAGradientLayer layer];
        self.bottomGl = gl;
        gl.frame = CGRectMake(0,0,YXConstant.screenWidth,43);
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 0.94);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        [_bottomView.layer insertSublayer:gl atIndex:0];
        
        [_bottomView addSubview:self.startBtn];
        [_bottomView addSubview:self.ratoBtn];
        
        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView).offset(12);
            make.centerY.equalTo(self.bottomView);
            make.width.height.mas_equalTo(24);
        }];
        
        [self.ratoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView).offset(-12);
            make.centerY.equalTo(self.bottomView);
            make.width.height.mas_equalTo(24);
        }];
    }
    return _bottomView;
}

- (UIButton *)startBtn {
    if (_startBtn == nil) {
        _startBtn = [[UIButton alloc] init];
        [_startBtn setImage:[UIImage imageNamed:@"live_stop"] forState:UIControlStateNormal];
        [_startBtn setImage:[UIImage imageNamed:@"live_play"] forState:UIControlStateSelected];
    }
    return _startBtn;
}

- (UIButton *)ratoBtn {
    if (_ratoBtn == nil) {
        _ratoBtn = [[UIButton alloc] init];
        [_ratoBtn setImage:[UIImage imageNamed:@"live_rota"] forState:UIControlStateNormal];
    }
    return _ratoBtn;
}

- (UILabel *)watchCountLabel {
    if (_watchCountLabel == nil) {
        _watchCountLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:12]];
    }
    return _watchCountLabel;
}

@end
