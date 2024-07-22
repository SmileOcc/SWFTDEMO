//
//  ZFLaunchAnimationView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLaunchAnimationView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

typedef void(^AnimationCompletionBlock)(void);

@interface ZFLaunchAnimationView () <ZFInitViewProtocol>
@property (nonatomic, copy) AnimationCompletionBlock completionBlock;
@property (nonatomic, strong) UIImageView   *logoImageView;
@property (nonatomic, strong) UIView        *emptyView;//此视图是为了盖住logo视图来做动画
@property (nonatomic, strong) UIImageView   *iconImageView;
@end

@implementation ZFLaunchAnimationView

+ (void)showAnimationViewCompletion:(void(^)(void))completionBlock
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    //防止走两次
    UIView *oldAnimationView = [window viewWithTag:kZFLaunchAnimationViewTag];
    if (oldAnimationView && [oldAnimationView isKindOfClass:[ZFLaunchAnimationView class]]) {
        [oldAnimationView removeFromSuperview];
    }
    CGRect screenRect = [UIScreen mainScreen].bounds;
    ZFLaunchAnimationView *advertView = [[ZFLaunchAnimationView alloc] initWithFrame:screenRect completionBlock:completionBlock];
    advertView.tag = kZFLaunchAnimationViewTag;
    [window addSubview:advertView];
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame completionBlock:(void(^)(void))completionBlock {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.completionBlock = completionBlock;
        [self zfInitView];
        [self zfAutoLayoutView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showAniamtion];
        });
    }
    return self;
}

#pragma mark - private methods

- (void)showAniamtion {
    CGFloat middleSpace = 5;
    CGFloat leftCenterX = (KScreenWidth - (self.logoImage.size.width + self.iconImage.size.width + middleSpace)) / 2;
    CGFloat multiplied = 0.4;
    
    [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-(leftCenterX - middleSpace/2));
        make.centerY.mas_equalTo(self.mas_bottom).multipliedBy(multiplied);
    }];
    
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_bottom).multipliedBy(multiplied);
        make.trailing.mas_equalTo(self.iconImageView.mas_leading);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, 80));
    }];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(leftCenterX - middleSpace/2);
        make.centerY.mas_equalTo(self.mas_bottom).multipliedBy(multiplied);
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.completionBlock) {
                self.completionBlock();
            }
            [self removeFromSuperview];
        });
    }];
}

- (UIImage *)logoImage {
    return [UIImage imageNamed:@"launch_animation_logo"];
}

- (UIImage *)iconImage {
    return [UIImage imageNamed:@"launch_animation_icon"];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.logoImageView];
    [self addSubview:self.emptyView];
    [self addSubview:self.iconImageView];
}

- (void)zfAutoLayoutView {
    CGFloat multiplied = 0.4;
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_bottom).multipliedBy(multiplied);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_bottom).multipliedBy(multiplied);
        make.trailing.mas_equalTo(self.iconImageView.mas_trailing);
    }];
    
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_bottom).multipliedBy(multiplied);
        make.trailing.mas_equalTo(self.logoImageView.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, 80));
    }];
}

#pragma mark - getter

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithImage:self.logoImage];
        _logoImageView.backgroundColor = [UIColor whiteColor];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _logoImageView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = [UIColor whiteColor];
    }
    return _emptyView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:self.iconImage];
        _iconImageView.backgroundColor = [UIColor whiteColor];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconImageView;
}


@end
