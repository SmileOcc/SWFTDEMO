//
//  ZFCountDownButton.m
//  ZZZZZ
//
//  Created by YW on 2019/5/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCountDownButton.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger) {
    CountDownButtonStatus_CountDowning, ///正在倒计时
    CountDownButtonStatus_EndCountDown, ///倒计时已结束
    CountDownButtonStatus_StartCountDown  ///倒计时开始
}CountDownButtonStatus;

@interface ZFCountDownButton ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) CountDownButtonStatus status;
@property (nonatomic, assign) NSInteger currentCountDown;

@end

@implementation ZFCountDownButton
{
    dispatch_source_t timer;
}

-(void)dealloc
{
    [self stopTime];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.countDownInterval = 60;
        self.currentCountDown = self.countDownInterval;
        [self addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.size.mas_offset(CGSizeMake(25, 25));
        }];
    }
    return self;
}

#pragma mark - public method

-(void)startCountDownAnimation
{
    self.enabled = NO;
    if ([self.indicatorView isAnimating]) {
        [self.indicatorView stopAnimating];
    }
    [self resetTitleStatus:CountDownButtonStatus_StartCountDown];
    [self.indicatorView startAnimating];
}

- (void)startCountDown
{
    [self stopTime];
    [self.indicatorView stopAnimating];
    [self resetTitleStatus:CountDownButtonStatus_CountDowning];
    @weakify(self)
    timer = [ZFCountDownButton startGCDTimerWithInterval:1 block:^{
        @strongify(self)
        if (self.currentCountDown < 1) {
            [self stopConutDown];
        } else {
            self.currentCountDown -= 1;
            [self resetTitleStatus:CountDownButtonStatus_CountDowning];
        }
    }];
}

- (void)stopConutDown
{
    [self stopTime];
    [self resetTitleStatus:CountDownButtonStatus_EndCountDown];
    self.enabled = YES;
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - Property Method

-(void)setNormalTitle:(NSString *)normalTitle
{
    _normalTitle = normalTitle;
    
    [self setTitle:_normalTitle forState:UIControlStateNormal];
}

-(void)setCountDownTitle:(NSString *)countDownTitle
{
    _countDownTitle = countDownTitle;
}

-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

#pragma mark - private method

- (void)resetTitleStatus:(CountDownButtonStatus)status
{
    switch (status) {
        case CountDownButtonStatus_CountDowning:{
            self.titleLabel.alpha = 1.0;
            self.layer.borderColor = ZFC0xCCCCCC().CGColor;
            NSString *title = [NSString stringWithFormat:@"%@ %lds", self.countDownTitle, self.currentCountDown];
            [self setTitle:title forState:UIControlStateNormal];
            [self setTitleColor:ZFC0xCCCCCC() forState:UIControlStateNormal];
        }
            break;
        case CountDownButtonStatus_EndCountDown:{
            self.currentCountDown = self.countDownInterval;
            self.titleLabel.alpha = 1.0;
            self.layer.borderColor = ZFC0x2D2D2D().CGColor;
            [self setTitle:self.normalTitle forState:UIControlStateNormal];
            [self setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        }
            break;
        case CountDownButtonStatus_StartCountDown:{
            self.titleLabel.alpha = 0.0;
            self.layer.borderColor = ZFC0xCCCCCC().CGColor;
            [self setTitle:self.normalTitle forState:UIControlStateNormal];
            [self setTitleColor:ZFC0xCCCCCC() forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)stopTime
{
    [ZFCountDownButton stopGCDTimer:timer];
}

+ (dispatch_source_t)startGCDTimerWithInterval:(double)interval block:(dispatch_block_t)block
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, // source type
                                                     0, // handle
                                                     0, // mask
                                                     dispatch_get_main_queue()); // queue
    
    dispatch_source_set_timer(timer, // dispatch source
                              dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), // start
                              interval * NSEC_PER_SEC, // interval
                              0 * NSEC_PER_SEC); // leeway
    
    dispatch_source_set_event_handler(timer, block);
    
    dispatch_resume(timer);
    
    return timer;
}

+ (void)stopGCDTimer:(dispatch_source_t)timer
{
    if (timer) {
        dispatch_source_cancel(timer);
    }
}

@end
