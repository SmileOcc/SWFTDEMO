//
//  ZFLaunchAdvertView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFLaunchAdvertView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+LayoutMethods.h"

static NSString *const kAdvertViewAnimationType = @"pageCurl";

typedef void(^AdvertSkipBlock)(void);
typedef void(^AdvertJumpBannerBlock)(void);

@interface ZFLaunchAdvertView () <ZFInitViewProtocol>
@property (nonatomic, strong) NSData                *imageData;
@property (nonatomic, copy) AdvertJumpBannerBlock   jumpBannerBlock;
@property (nonatomic, copy) AdvertSkipBlock         skipBannerBlock;
@property (nonatomic, strong) YYAnimatedImageView   *loadImageView;
@property (nonatomic, strong) UIButton              *skipButton;
@property (nonatomic, strong) dispatch_source_t     timer;
@property (nonatomic, assign) NSInteger             countDownSecond;
@end

@implementation ZFLaunchAdvertView

+ (void)showAdvertWithImageData:(NSData *)imageData
                jumpBannerBlock:(void(^)(void))jumpBannerBlock
                skipBannerBlock:(void(^)(void))skipBannerBlock
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    //防止走两次
    UIView *oldAdvertView = [window viewWithTag:kZFLaunchAdvertViewTag];
    if (oldAdvertView && [oldAdvertView isKindOfClass:[ZFLaunchAdvertView class]]) {
        [oldAdvertView removeFromSuperview];
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    ZFLaunchAdvertView *advertView = [[ZFLaunchAdvertView alloc] initWithFrame:screenRect];
    advertView.tag = kZFLaunchAdvertViewTag;
    advertView.imageData = imageData;
    advertView.skipBannerBlock = skipBannerBlock;
    advertView.jumpBannerBlock = jumpBannerBlock;
    [window addSubview:advertView];
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.countDownSecond = 3;
        self.clipsToBounds = YES;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)skipButtonAction:(UIButton *)sender {
    dispatch_source_cancel(self.timer);
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self showPageCurlAnimation];
//        [UIView animateWithDuration:1.0f animations:^{
//            self.alpha = 0.0;
//        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (self.skipBannerBlock) {
                self.skipBannerBlock();
            }
//        }];
    });
}

#pragma mark - private methods
- (void)openTimeCountToRefreshView {
    __block NSInteger time = self.countDownSecond; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_QUEUE_PRIORITY_HIGH);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, (int)(1.0 * NSEC_PER_SEC)), 1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{
        if(time <= 0){ //倒计时结束，关闭
            [self skipButtonAction:nil];
        }else{
            NSInteger seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.skipButton setTitle:[NSString stringWithFormat:@"%@ %lu", ZFLocalizedString(@"StartLoad_Skip_Tips", nil), seconds] forState:UIControlStateNormal];
            });
            time--;
        }
    });
    dispatch_resume(self.timer);
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.loadImageView];
    [self addSubview:self.skipButton];
}

- (void)zfAutoLayoutView {
    [self.loadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    CGFloat width = 68;
    NSString *localeLanguageCode = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    if ([localeLanguageCode hasPrefix:@"fr"]) {
        width = 90;
    }
    
    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(48);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-24);
        make.height.mas_equalTo(28);
    }];
    self.skipButton.layer.cornerRadius = 14;
}

#pragma mark - setter
- (void)setImageData:(NSData *)imageData {
    _imageData = imageData;
    
    UIImage *showImage = nil;
    if ([imageData isKindOfClass:[NSData class]]) {
        UIImage *cacheImage = [UIImage imageWithData:imageData];
        if ([cacheImage isKindOfClass:[UIImage class]]) {
            showImage = cacheImage;
        }
    }
    
    if (!showImage) {
        UIImage *launchImage = [UIImage imageNamed:getLaunchImageName()];
        if ([launchImage isKindOfClass:[UIImage class]]) {
            showImage = launchImage;
        } else {
            showImage = ZFImageWithName(@"loading_product");
        }
    }
    
    self.loadImageView.image = showImage;
    [self openTimeCountToRefreshView];
}

/**
 * 展示翻页动画过渡效果
 */
- (void)showPageCurlAnimation {
    CATransition *transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 1.0f;
    transition.type = kAdvertViewAnimationType; // 指定动画类型
    transition.subtype = @"fromRight"; // 指定过渡方向
    transition.startProgress = 0.0f;
    transition.endProgress = 1.0f;
    [self.layer addAnimation:transition forKey:@"AnimationKey"];
}

#pragma mark - getter
- (YYAnimatedImageView *)loadImageView {
    if (!_loadImageView) {
        _loadImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _loadImageView.userInteractionEnabled = YES;
        _loadImageView.contentMode = UIViewContentModeScaleAspectFill;
        @weakify(self);
        [_loadImageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.jumpBannerBlock) {
                dispatch_source_cancel(self.timer);
                self.jumpBannerBlock();
                
                // 点击跳转Push动画
                [UIView animateWithDuration:0.2f
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.x = -[UIScreen mainScreen].bounds.size.width;
                                 } completion:^(BOOL finished) {
                                     [self removeFromSuperview];
                                 }];
            }
        }];
    }
    return _loadImageView;
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.layer.borderColor = [UIColor blackColor].CGColor;
        _skipButton.layer.borderWidth = 1.f;
        [_skipButton setTitle:[NSString stringWithFormat:@"%@ %ld", ZFLocalizedString(@"StartLoad_Skip_Tips", nil), self.countDownSecond] forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_skipButton setEnlargeEdge:30];//扩大点击区域
        [_skipButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    return _skipButton;
}

@end
