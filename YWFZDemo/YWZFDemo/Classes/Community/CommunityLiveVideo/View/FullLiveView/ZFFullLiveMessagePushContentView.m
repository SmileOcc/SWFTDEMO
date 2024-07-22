//
//  ZFFullLiveMessagePushContentView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveMessagePushContentView.h"
#import "Masonry.h"
#import "Constants.h"


#import "ZFFullLiveLiveMessagePushView.h"
CGFloat const kPushItemHeight = 28;

@interface ZFFullLiveMessagePushContentView ()

/// 当前在屏幕内显示的推流视图
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
/// 消息队列
@property (nonatomic, strong) NSMutableArray <ZFZegoMessageInfo *> *messageInfoArray;

@property (strong, nonatomic) dispatch_source_t messageTimer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger         timeCount;

@end

@implementation ZFFullLiveMessagePushContentView

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
        self.messageInfoArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc {
    YWLog(@"ZFFullLiveMessagePushContentView dealloc");
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Public Method

- (void)pushMessageInfo:(ZFZegoMessageInfo *)messageInfo {
    
    if (messageInfo == nil) {
        return;
    }
    
    if (!self.messageTimer && !self.isNoNeedTimer) {
        [self startMessageTimer];
    }
}

- (void)setIsNoNeedTimer:(BOOL)isNoNeedTimer {
    _isNoNeedTimer = isNoNeedTimer;
    if (!isNoNeedTimer) {
        [self cancelMessageTimer];
    }
}

- (void)cancelMessageTimer {
    if (self.messageTimer) {
        dispatch_source_cancel(self.messageTimer);
        self.messageTimer = nil;
    }
}

- (void)startMessageTimer {
    [self cancelMessageTimer];
    
    if (self.isNoNeedTimer) {
        return;
    }
    
    // 队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建 dispatch_source
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 声明成员变量
    self.messageTimer = timer;
    // 设置两秒后触发
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    // 设置下次触发事件为 DISPATCH_TIME_FOREVER
    dispatch_time_t nextTime = DISPATCH_TIME_FOREVER;
    // 设置精确度
    dispatch_time_t leeway = 0.1 * NSEC_PER_SEC;
    // 配置时间
    dispatch_source_set_timer(timer, startTime, nextTime, leeway);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        [self moveTopMessageAnimate];
    });
    // 激活
    dispatch_resume(self.messageTimer);
    
}

- (void)moveTopMessageAnimate {
    
    if (!self.superview) {
        [self cancelMessageTimer];
        return;
    }
    
    NSMutableArray *msgs = [[ZFVideoLiveCommentUtils sharedInstance] topShowMessageList];
    if (msgs.count > self.timeCount) {
        if ([ZFVideoLiveCommentUtils sharedInstance].topShowIndex < self.timeCount) {
            [ZFVideoLiveCommentUtils sharedInstance].topShowIndex = self.timeCount;
        } else if ([ZFVideoLiveCommentUtils sharedInstance].topShowIndex > self.timeCount){
            self.timeCount = [ZFVideoLiveCommentUtils sharedInstance].topShowIndex;
        }
    } else if(msgs.count <= self.timeCount) {
        [self cancelMessageTimer];
        YWLog(@"-------- 显示完： %lu",(unsigned long)msgs.count);
        return;
    }
    
    if (self.isHidden) {//隐藏状态下，不显示
        [self startMessageTimer];
        return;
    }
    
    if (msgs.count >= ([ZFVideoLiveCommentUtils sharedInstance].topShowIndex + 1)) {
        
        self.timeCount++;
        [self.messageInfoArray addObject:msgs[[ZFVideoLiveCommentUtils sharedInstance].topShowIndex]];
        [self animationViewWithMessageInfo:msgs[[ZFVideoLiveCommentUtils sharedInstance].topShowIndex]];
        [self startMessageTimer];
    } else {
        [self cancelMessageTimer];
    }
}

#pragma mark - Private Method

- (void)animationViewWithMessageInfo:(ZFZegoMessageInfo * )messageInfo {
    
    ZFFullLiveLiveMessagePushView *pushView = [[ZFFullLiveLiveMessagePushView alloc] init];
    [pushView configWithMessageInfo:messageInfo];
    [self addSubview:pushView];
    
    [self startPointWithView:pushView];
    
    if (self.messageInfoArray.count == 1) {
        self.bottomView = pushView;
        [self showWithView:self.bottomView];
        
    } else if (self.messageInfoArray.count == 2) {
        self.topView = self.bottomView;
        [self moveUpWithView:self.topView];
        self.bottomView = pushView;
        [self showWithView:self.bottomView];
        
    } else {
        
        [self dismissWithView:self.topView];
        
        self.topView = self.bottomView;
        [self moveUpWithView:self.topView];
        
        self.bottomView = pushView;
        [self showWithView:self.bottomView];
        
    }
    
}


#pragma mark - Animation Method

- (void)startPointWithView:(UIView *)view{
    
    if (view == nil || view.superview == nil) {
        return;
    }
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.trailing.equalTo(view.superview.mas_leading);
        make.bottom.offset(0);
//        make.height.mas_equalTo(kPushItemHeight);
    }];
    [self layoutIfNeeded];
}


- (void)showWithView:(UIView *)view{
    
    if (view == nil || view.superview == nil) {
        return;
    }
    
    if (((ZFFullLiveLiveMessagePushView *)view).dismissing) {
        return;
    }
    
    [view.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.25 animations:^{
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.offset(0);
            make.trailing.lessThanOrEqualTo(view.superview).offset(-16);
            make.bottom.offset(0);
//            make.height.mas_equalTo(kPushItemHeight);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissWithView:view];
        });
    }];
    
}


- (void)moveUpWithView:(UIView *)view{
    
    if (view == nil || view.superview == nil) {
        return;
    }
    
    if (((ZFFullLiveLiveMessagePushView *)view).dismissing) {
        return;
    }
    
    [view.layer removeAllAnimations];
    
    CGFloat h = CGRectGetHeight(view.frame);
    [UIView animateWithDuration:0.25 animations:^{
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.offset(-(kPushItemHeight + 8));
            make.bottom.offset(-(h + 8));
            make.leading.offset(0);
            make.trailing.lessThanOrEqualTo(view.superview).offset(-16);
//            make.height.mas_equalTo(kPushItemHeight);
        }];
        [self layoutIfNeeded];
    } completion:nil];
}


- (void)dismissWithView:(UIView *)view{
    
    if (view == nil || view.superview == nil) {
        return;
    }
    
    if (((ZFFullLiveLiveMessagePushView *)view).dismissing) {
        return;
    }
    
    [view.layer removeAllAnimations];
    
    ((ZFFullLiveLiveMessagePushView *)view).dismissing = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(view.superview.mas_top);
            make.leading.offset(0);
            make.trailing.lessThanOrEqualTo(view.superview).offset(-16);
//            make.height.mas_equalTo(kPushItemHeight);
        }];
        view.alpha = 0.0;
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        if (self.messageInfoArray.count) {
            [self.messageInfoArray removeObjectAtIndex:0];
        }
    }];
    
}


@end
