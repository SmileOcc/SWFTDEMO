//
//  ZFLoadingAnimationView.m
//  ZZZZZ
//
//  Created by Tsang_Fa on 2017/9/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFLoadingAnimationView.h"
#import <Lottie/Lottie.h>
#import "Constants.h"

static CGFloat const kContentViewH = 72.f;

@interface ZFLoadingAnimationView ()
@property (nonatomic,strong) LOTAnimationView *animView;
@end

@implementation ZFLoadingAnimationView

- (CGSize)intrinsicContentSize {
    CGFloat contentViewH = kContentViewH;
    CGFloat contentViewW = kContentViewH;
    return CGSizeMake(contentViewW, contentViewH);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    YWLog(@"释放请求loading动画");
}

- (void)appDidBecomeActive
{
    [self.animView play];
    YWLog(@"激活请求loading动画");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self.animView play];
    } else {
        [self.animView stop];
    }
}

- (void)configureUI {
    self.animView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_pushloading"];
    self.animView.frame = self.bounds;
    [self addSubview:self.animView];
    self.animView.loopAnimation = YES;
}


@end
