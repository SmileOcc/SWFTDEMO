//
//  ZFRefreshFooter.m
//  ZZZZZ
//
//  Created by YW on 23/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRefreshFooter.h"
#import <Lottie/Lottie.h>
#import "ZFFrameDefiner.h"
#import "Constants.h"

@interface ZFRefreshFooter ()
@property (nonatomic,strong) LOTAnimationView *animView;
@property (nonatomic,strong) UILabel *zfNoMoreDataTipLabel;
@end

@implementation ZFRefreshFooter
#pragma mark 初始化配置（添加子控件）
- (void)prepare {
    [super prepare];
    self.backgroundColor = [UIColor clearColor];
    self.automaticallyRefresh = YES;
    
    self.mj_h = 50;
    
    
    CGFloat preloadHight = KScreenHeight * 1; ///< 预加载一页数据
    
    self.triggerAutomaticallyRefreshPercent = -preloadHight / self.mj_h;
    
    // 设置动画
    self.animView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_downloading"];
    self.animView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.animView];
    self.animView.loopAnimation = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setZfNoMoreDataTipText:(NSString *)zfNoMoreDataTipText {
    _zfNoMoreDataTipText = zfNoMoreDataTipText;
}

- (UILabel *)zfNoMoreDataTipLabel {
    if(!_zfNoMoreDataTipLabel){
        _zfNoMoreDataTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 20)];
        _zfNoMoreDataTipLabel.text = self.zfNoMoreDataTipText;
        _zfNoMoreDataTipLabel.textAlignment = NSTextAlignmentCenter;
        _zfNoMoreDataTipLabel.textColor = [UIColor grayColor];
        _zfNoMoreDataTipLabel.font = ZFFontSystemSize(14);
        [self addSubview:_zfNoMoreDataTipLabel];
        [self bringSubviewToFront:_zfNoMoreDataTipLabel];
    }
    return _zfNoMoreDataTipLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    YWLog(@"释放ZFRefreshFooter动画");
}

- (void)appDidBecomeActive
{
    if (self.state == MJRefreshStateRefreshing) {
        [self.animView play];
        YWLog(@"激活ZFRefreshFooter动画");
    }
}

- (void)placeSubviews {
    [super placeSubviews];
    
    self.animView.bounds = CGRectMake(0, 0, 30, 30);
    self.animView.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.5);
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    
    if (state == MJRefreshStateRefreshing) {
        [self.animView play];
    } else if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        [self.animView stop];
    }
    
    if (state == MJRefreshStateNoMoreData) {
        if (self.zfNoMoreDataTipText) {
            self.hidden = NO;
            self.animView.hidden = YES;
            self.zfNoMoreDataTipLabel.hidden = NO;
        }
    } else {
        _zfNoMoreDataTipLabel.hidden = YES;
    }
}

#pragma mark 监听拖拽比例
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    
    if (self.state != MJRefreshStateIdle) return;
    
    self.animView.animationProgress = pullingPercent;
}


@end
