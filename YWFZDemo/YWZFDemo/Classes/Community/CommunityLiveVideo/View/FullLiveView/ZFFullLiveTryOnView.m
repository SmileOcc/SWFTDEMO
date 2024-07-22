//
//  ZFFullLiveTryOnView.m
//  ZZZZZ
//
//  Created by YW on 2020/1/2.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveTryOnView.h"
#import "ZFLocalizationString.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"

@interface ZFFullLiveTryOnView()

@property (nonatomic, strong) CABasicAnimation          *translate;
@property (nonatomic, copy) NSString *animateKey;


@end

@implementation ZFFullLiveTryOnView

- (void)dealloc {
    YWLog(@"ZFFullLiveTryOnView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.animateKey = [NSString stringWithFormat:@"TryOn_%i_%i",arc4random() % 10000,arc4random() % 20000];
    }
    return self;
}


- (void)zfInitView {
    [self addSubview:self.liveMarkImageView];
    [self addSubview:self.liveMarkTitleLabel];
    [self addSubview:self.liveAnimationImageView];
}

- (void)zfAutoLayoutView {
    
    [self.liveMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(5);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.liveMarkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.liveMarkImageView.mas_trailing);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-5);
    }];
    
    [self.liveAnimationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 45));
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat maxWidth = CGRectGetWidth(self.frame);
    CGFloat toValue = [self.translate.toValue floatValue];
    if (maxWidth != toValue && self.isAnimate) {
        self.translate.toValue = [NSNumber numberWithFloat:maxWidth];
        [self startShimmer];
    }
}



- (UIImageView *)liveMarkImageView {
    if (!_liveMarkImageView) {
        _liveMarkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _liveMarkImageView.image = [UIImage imageNamed:@"live_goods_try"];
    }
    return _liveMarkImageView;
}

- (UILabel *)liveMarkTitleLabel {
    if (!_liveMarkTitleLabel) {
        _liveMarkTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _liveMarkTitleLabel.textColor = ZFC0xFFFFFF();
        _liveMarkTitleLabel.font = [UIFont systemFontOfSize:12];
        _liveMarkTitleLabel.text = ZFLocalizedString(@"Live_trying_on", nil);
    }
    return _liveMarkTitleLabel;
}

- (UIImageView *)liveAnimationImageView {
    if (!_liveAnimationImageView) {
        _liveAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _liveAnimationImageView.image = [UIImage imageNamed:@"live_try_on_line"];
    }
    return _liveAnimationImageView;
}

- (void)startLoading {
    self.alpha = 1.0;
    self.isAnimate = YES;
    [self startShimmer];
}

- (void)endLoading {
    self.isAnimate = NO;
    NSArray *animationKeys = [self.liveAnimationImageView.layer animationKeys];
    if (animationKeys.count > 0) {
        [self.liveAnimationImageView.layer removeAllAnimations];
    }
}

- (void)startShimmer {
    self.liveAnimationImageView.hidden = NO;
    [self.liveAnimationImageView.layer removeAllAnimations];
    [self.liveAnimationImageView.layer addAnimation:self.translate forKey:self.animateKey ? self.animateKey : [NSString stringWithFormat:@"TryOn_%i_%i",arc4random() % 10000,arc4random() % 20000]];
}


- (CABasicAnimation *)translate {
    if (!_translate) {
        _translate = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        _translate.fromValue = [NSNumber numberWithFloat:-50];
        _translate.toValue = [NSNumber numberWithFloat:200];
        _translate.repeatCount = MAXFLOAT;
        _translate.duration = 1.0;
        _translate.autoreverses = NO;
//        _translate.removedOnCompletion = NO;
    }
    return _translate;
}
@end
