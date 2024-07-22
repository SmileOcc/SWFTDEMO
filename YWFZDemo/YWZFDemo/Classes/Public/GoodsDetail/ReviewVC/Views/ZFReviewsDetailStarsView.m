
//
//  ZFReviewsDetailStarsView.m
//  ZZZZZ
//
//  Created by YW on 2017/11/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFReviewsDetailStarsView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@interface ZFReviewsDetailStarsView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *starViewFirst;
@property (nonatomic, strong) UIImageView           *starViewSecond;
@property (nonatomic, strong) UIImageView           *starViewThird;
@property (nonatomic, strong) UIImageView           *starViewFourth;
@property (nonatomic, strong) UIImageView           *starViewFiveth;
@property (nonatomic, assign) CGSize                rateSize;
@end

@implementation ZFReviewsDetailStarsView
#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame withRateSize:(CGSize)rateSize
{
    self = [super initWithFrame:frame];

    if (self) {
        if (CGSizeEqualToSize(rateSize, CGSizeZero)) {
            self.rateSize = CGSizeMake(30, 30);
        } else {
            self.rateSize = rateSize;
        }
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.rateSize = CGSizeMake(30, 30);
//        [self zfInitView];
//        [self zfAutoLayoutView];
//    }
//    return self;
//}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ColorHex_Alpha(0xFFFFFF, 1.0);
    [self addSubview:self.starViewFirst];
    [self addSubview:self.starViewSecond];
    [self addSubview:self.starViewThird];
    [self addSubview:self.starViewFourth];
    [self addSubview:self.starViewFiveth];
}

- (void)zfAutoLayoutView {
    CGFloat padding = 2;
    [self.starViewFirst mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.rateSize);
        make.leading.mas_equalTo(self.mas_leading);
    }];
    
    [self.starViewSecond mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.starViewFirst);
        make.leading.mas_equalTo(self.starViewFirst.mas_trailing).offset(padding);
    }];
    
    [self.starViewThird mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.starViewFirst);
        make.leading.mas_equalTo(self.starViewSecond.mas_trailing).offset(padding);
    }];
    
    [self.starViewFourth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.starViewFirst);
        make.leading.mas_equalTo(self.starViewThird.mas_trailing).offset(padding);
    }];
    
    [self.starViewFiveth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.starViewFirst);
        make.leading.mas_equalTo(self.starViewFourth.mas_trailing).offset(padding);
        make.trailing.mas_equalTo(self.mas_trailing);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - setter
- (void)setRateAVG:(NSString *)rateAVG {
    _rateAVG = rateAVG;
    NSInteger count = [_rateAVG integerValue];
    for (int i = 1000; i < 1000 + count; ++i) {
        UIImageView *starView = [self viewWithTag:i];
        starView.image = [UIImage imageNamed:@"starHigh"];
    }
}

#pragma mark - getter
- (UIImageView *)starViewFirst {
    if (!_starViewFirst) {
        _starViewFirst = [[UIImageView alloc] initWithFrame:CGRectZero];
        _starViewFirst.image = [UIImage imageNamed:@"starNormal"];
        _starViewFirst.tag = 1000;
    }
    return _starViewFirst;
}

- (UIImageView *)starViewSecond {
    if (!_starViewSecond) {
        _starViewSecond = [[UIImageView alloc] initWithFrame:CGRectZero];
        _starViewSecond.image = [UIImage imageNamed:@"starNormal"];
        _starViewSecond.tag = 1001;
    }
    return _starViewSecond;
}

- (UIImageView *)starViewThird {
    if (!_starViewThird) {
        _starViewThird = [[UIImageView alloc] initWithFrame:CGRectZero];
        _starViewThird.image = [UIImage imageNamed:@"starNormal"];
        _starViewThird.tag = 1002;
    }
    return _starViewThird;
}

- (UIImageView *)starViewFourth {
    if (!_starViewFourth) {
        _starViewFourth = [[UIImageView alloc] initWithFrame:CGRectZero];
        _starViewFourth.image = [UIImage imageNamed:@"starNormal"];
        _starViewFourth.tag = 1003;
    }
    return _starViewFourth;
}

- (UIImageView *)starViewFiveth {
    if (!_starViewFiveth) {
        _starViewFiveth = [[UIImageView alloc] initWithFrame:CGRectZero];
        _starViewFiveth.image = [UIImage imageNamed:@"starNormal"];
        _starViewFiveth.tag = 1004;
    }
    return _starViewFiveth;
}

@end
