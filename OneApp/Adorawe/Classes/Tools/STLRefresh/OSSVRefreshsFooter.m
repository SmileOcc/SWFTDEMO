//
//  OSSVRefreshsFooter.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVRefreshsFooter.h"

@interface OSSVRefreshsFooter ()
//@property (nonatomic,strong) LOTAnimationView *animView;
@property (nonatomic,strong) UILabel *noMoreDataTipLabel;
@end

@implementation OSSVRefreshsFooter

#pragma mark 初始化配置（添加子控件）
- (void)prepare {
    [super prepare];
    self.backgroundColor = [UIColor clearColor];
    self.automaticallyRefresh = YES;
    
    self.mj_h = 50;
    
    
    CGFloat preloadHight = SCREEN_HEIGHT * 1; ///< 预加载一页数据
    
    self.triggerAutomaticallyRefreshPercent = -preloadHight / self.mj_h;
    
    // 设置动画
//    self.animView = [LOTAnimationView animationNamed:@"Adorawe_loading_downloading"];
//    self.animView.contentMode = UIViewContentModeScaleAspectFit;
//    [self addSubview:self.animView];
//    self.animView.loopAnimation = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setNoMoreDataTipText:(NSString *)noMoreDataTipText {
    _noMoreDataTipText = noMoreDataTipText;
}


- (UILabel *)noMoreDataTipLabel {
    
    if(!_noMoreDataTipLabel){
        _noMoreDataTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        _noMoreDataTipLabel.text = self.noMoreDataTipText;
        _noMoreDataTipLabel.textAlignment = NSTextAlignmentCenter;
        _noMoreDataTipLabel.textColor = [UIColor grayColor];
        _noMoreDataTipLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_noMoreDataTipLabel];
        [self bringSubviewToFront:_noMoreDataTipLabel];
    }
    return _noMoreDataTipLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    STLLog(@"释放OSSVRefreshsFooter动画");
}

- (void)appDidBecomeActive
{
    if (self.state == MJRefreshStateRefreshing) {
        //[self.animView play];
        STLLog(@"激活OSSVRefreshsFooter动画");
    }
}

- (void)placeSubviews {
    [super placeSubviews];
    
   // self.animView.bounds = CGRectMake(0, 0, 30, 30);
   // self.animView.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.5);
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    
    if (state == MJRefreshStateRefreshing) {
        //[self.animView play];
    } else if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        //[self.animView stop];
    }
    
    if (state == MJRefreshStateNoMoreData) {
        if (self.noMoreDataTipText) {
            self.hidden = NO;
            //self.animView.hidden = YES;
            _noMoreDataTipLabel.hidden = NO;
        }
    } else {
        _noMoreDataTipLabel.hidden = YES;
    }
}

#pragma mark 监听拖拽比例
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    
    if (self.state != MJRefreshStateIdle) return;
    
    //self.animView.animationProgress = pullingPercent;
}

@end
