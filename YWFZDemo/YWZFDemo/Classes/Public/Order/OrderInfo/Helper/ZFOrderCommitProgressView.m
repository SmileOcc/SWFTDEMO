//
//  ZFOrderCommitProgressView.m
//  ZZZZZ
//
//  Created by YW on 2019/2/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderCommitProgressView.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFColorDefiner.h"
#import "ZFLocalizationString.h"

#import <Masonry/Masonry.h>
#import <YYImage/YYImage.h>
#import <Lottie/Lottie.h>

@interface ZFOrderCommitProgressView ()
{
    dispatch_source_t timer;
}
//A测试视图
@property (nonatomic, strong) UIView *containView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIProgressView *progressView;

//B测试视图
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) LOTAnimationView *giftAnimView;

//公共参数
@property (nonatomic, assign) BOOL ad_params;
@property (nonatomic, weak) id<ZFOrderCommitProgressViewDelegate>delegate;
@property (nonatomic, assign) ZFProgressViewType type;
@end

@implementation ZFOrderCommitProgressView

-(void)dealloc
{
    YWLog(@"ZFOrderCommitProgressView");
}

-(instancetype)initWithFlag:(NSInteger)flag
{
    self = [super init];
    
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    [self addSubview:self.containView];
    [self.containView addSubview:self.contentLabel];
    [self.containView addSubview:self.progressView];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    
    self.contentLabel.preferredMaxLayoutWidth = KScreenWidth * 0.48;
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containView.mas_top).mas_offset(13);
        make.leading.mas_equalTo(self.containView.mas_leading).mas_offset(13);
        make.trailing.mas_equalTo(self.containView.mas_trailing).mas_offset(-13);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(12);
        make.leading.trailing.mas_equalTo(self.contentLabel);
        make.bottom.mas_equalTo(self.containView.mas_bottom).mas_offset(-23);
        make.height.mas_offset(6);
    }];
}

- (void)initUIFlag2
{
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    [self addSubview:self.maskView];
    [self addSubview:self.containView];
    [self.containView addSubview:self.contentLabel];
    [self.containView addSubview:self.giftAnimView];
    
    self.containView.backgroundColor = [UIColor whiteColor];
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];

    [self.giftAnimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containView.mas_top).mas_offset(13);
        make.centerX.mas_equalTo(self.containView);
        make.size.mas_equalTo(CGSizeMake(85, 85));
    }];
    
    self.contentLabel.preferredMaxLayoutWidth = KScreenWidth * 0.48;
    self.contentLabel.textColor = [UIColor blackColor];
    self.contentLabel.text = ZFLocalizedString(@"OrderInfo_CheckSafety_Msg2", nil);
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.giftAnimView.mas_bottom).mas_offset(13);
        make.leading.mas_equalTo(self.containView.mas_leading).mas_offset(13);
        make.trailing.mas_equalTo(self.containView.mas_trailing).mas_offset(-13);
        make.bottom.mas_equalTo(self.containView.mas_bottom).mas_offset(-13);
    }];
}

+(void)showProgressViewType:(ZFProgressViewType)type delegate:(id<ZFOrderCommitProgressViewDelegate>)delegate
{
    ZFOrderCommitProgressView *progressView = [[ZFOrderCommitProgressView alloc] initWithFlag:0];
    progressView.delegate = delegate;
    progressView.type = type;
    progressView.tag = 10000011;
    progressView.ad_params = NO;
    [progressView showProgressView];
}

+(void)hiddenProgressView:(void (^)(void))block
{
    if ([WINDOW viewWithTag:10000011]) {
        ZFOrderCommitProgressView *view = [WINDOW viewWithTag:10000011];
        [view stopProgressView:block];
    } else {
        if (block) {
            block();
        }
    }
}

+(void)cancelProgressView
{
    if ([WINDOW viewWithTag:10000011]) {
        ZFOrderCommitProgressView *view = [WINDOW viewWithTag:10000011];
        [view hiddenProgressView];
    }
}

- (void)showProgressView
{
    //0--代表新版本，添加安全支付提示
    if (!self.superview) {
        [WINDOW addSubview:self];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderCommitProgressViewShowProgressView)]) {
        [self.delegate ZFOrderCommitProgressViewShowProgressView];
    }
    
    self.progressView.progress = 0.0;
    
    CGFloat random = 0.02;
    if (self.type == ZFProgressViewType_Fixed) {
        random = 0.06;
    }
    
    if (self.giftAnimView) {
        [self.giftAnimView play];
    }
    
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create("com.progress.view", DISPATCH_QUEUE_SERIAL));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressView.progress >= 1) {
                [self hiddenProgressView];
                return;
            }
            if (self.type == ZFProgressViewType_Fixed) {
                self.progressView.progress += random;
            }else{
                self.progressView.progress += random * (1.0 - self.progressView.progress);
            }
            [self.progressView setProgress:self.progressView.progress animated:YES];
        });
    });
    dispatch_resume(timer);
}

- (void)stopProgressView:(void(^)(void))block
{
    CGFloat lastProgress = (1.0 - self.progressView.progress);
    
    if (lastProgress > 0.5) {
        lastProgress = lastProgress / 5.0;
    }else{
        lastProgress = lastProgress / 2.0;
    }
    
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressView.progress >= 1) {
                [self hiddenProgressView];
                if (block) {
                    block();
                }
                return;
            }
            self.progressView.progress += lastProgress;
            [self.progressView setProgress:self.progressView.progress animated:YES];
        });
    });
}

- (void)hiddenProgressView
{
    [self stoptimer];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderCommitProgressViewDidStopProgress)]) {
        [self.delegate ZFOrderCommitProgressViewDidStopProgress];
    }
    if (self.giftAnimView) {
        [self.giftAnimView stop];
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)stoptimer
{
    dispatch_source_cancel(timer);
}

#pragma mark - setter

-(UIView *)containView
{
    if (!_containView) {
        _containView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ColorHex_Alpha(0x000000, 0.7);
            view.layer.cornerRadius = 4;
            view;
        });
    }
    return _containView;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"OrderInfo_CheckSafety_Msg", nil);
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
    }
    return _contentLabel;
}

-(UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = ({
            UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            progressView.progressTintColor = [UIColor whiteColor];
            progressView.backgroundColor = ColorHex_Alpha(0xFFFFFF, 0.2);
            progressView.progress = 0.0;
            progressView.layer.cornerRadius = 4;
            progressView.layer.masksToBounds = YES;
            progressView;
        });
    }
    return _progressView;
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = ({
            UIView *view = [[UIView alloc] init];
            view.frame = self.bounds;
            view.backgroundColor = ColorHex_Alpha(0x000000, 0.2);
            view;
        });
    }
    return _maskView;
}

// 分享送礼图标动画
- (LOTAnimationView *)giftAnimView {
    if(!_giftAnimView){
        _giftAnimView = [LOTAnimationView animationNamed:@"ZZZZZ_safeCheck"];
//        _giftAnimView.frame = CGRectMake(0, 0, 36, 36);
        _giftAnimView.loopAnimation = YES;
        _giftAnimView.userInteractionEnabled = NO;
        _giftAnimView.clipsToBounds = YES;
        _giftAnimView.layer.cornerRadius = 18;
    }
    return _giftAnimView;
}


@end
