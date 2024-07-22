//
//  ZFCommunityRefreshHeader.m
//  ZZZZZ
//
//  Created by YW on 2018/7/16.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityRefreshHeader.h"
#import <Lottie/Lottie.h>
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityRefreshHeader ()

@property (nonatomic,strong) LOTAnimationView *startAnimView;
@property (nonatomic,strong) LOTAnimationView *loadingAnimView;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZFCommunityRefreshHeader

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.bottom.offset(-5);
        }];
    }
    return self;
}

#pragma mark 初始化配置（添加子控件）
- (void)prepare {
    [super prepare];
    
    self.backgroundColor = [UIColor clearColor];
    
    // 设置控件的高度
    self.mj_h = 68;
    
    // 第一阶段动画 (从小变大)
    self.startAnimView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_uploadingstart"];
    self.startAnimView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.startAnimView];
    self.startAnimView.loopAnimation = YES;
    
    // 第二阶段动画 (填充转圈)
    self.loadingAnimView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_uploading"];
    self.loadingAnimView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.loadingAnimView];
    [self.loadingAnimView stop];
    self.loadingAnimView.loopAnimation = YES;
    
    [self.startAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-10);
        make.size.mas_equalTo(44);
    }];
    
    [self.loadingAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-22);
        make.size.mas_equalTo(44);
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-15);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    YWLog(@"释放ZFRefreshHeader动画");
}

- (void)appDidBecomeActive
{
    if (self.state == MJRefreshStateRefreshing) {
        [self.loadingAnimView play];
        YWLog(@"激活ZFRefreshHeader动画");
    }
}

- (void)setHeaderTipMessage:(NSString *)message {
    self.titleLabel.text = message;
}

#pragma mark 设置子控件的位置和尺寸
- (void)placeSubviews {
    [super placeSubviews];
    
    [self.startAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-22);
        make.size.mas_equalTo(44);
    }];
    
    [self.loadingAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-22);
        make.size.mas_equalTo(44);
    }];
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
        {
            [self.startAnimView stop];
            [self.loadingAnimView stop];
            [UIView animateWithDuration:0.3 animations:^{
                self.loadingAnimView.alpha = 0;
            }];
        }
            break;
        case MJRefreshStatePulling:
        {
            [self.startAnimView pause];
            [self.loadingAnimView pause];
            [UIView animateWithDuration:0.3 animations:^{
                self.loadingAnimView.alpha = 0;
            }];
        }
            break;
        case MJRefreshStateRefreshing:
        {
            [self.startAnimView stop];
            [UIView animateWithDuration:0.25 animations:^{
                self.loadingAnimView.alpha = 1;
            }];
            [self.loadingAnimView play];
        }
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    if (self.state != MJRefreshStateIdle) return;
    self.startAnimView.animationProgress = pullingPercent;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ColorHex_Alpha(0x999999, 1);
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = ZFLocalizedString(@"community_showoutfit_title", nil);;
    }
    return _titleLabel;
}


@end
