//
//  ZFGoodsReviewsRankingView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsReviewsRankingView.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "NSString+Extended.h"

@interface ZFGoodsReviewsRankingView()
@property (nonatomic, strong) UILabel                   *smallLabel;
@property (nonatomic, strong) UILabel                   *middleLabel;
@property (nonatomic, strong) UILabel                   *largeLabel;
@property (nonatomic, strong) UIProgressView            *smallProcessView;
@property (nonatomic, strong) UIProgressView            *middleProcessView;
@property (nonatomic, strong) UIProgressView            *largeProcessView;
@property (nonatomic, strong) UILabel                   *smallValueLabel;
@property (nonatomic, strong) UILabel                   *middleValueLabel;
@property (nonatomic, strong) UILabel                   *largeValueLabel;
@end

@implementation ZFGoodsReviewsRankingView

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.smallLabel];
    [self addSubview:self.middleLabel];
    [self addSubview:self.largeLabel];
    [self addSubview:self.smallProcessView];
    [self addSubview:self.middleProcessView];
    [self addSubview:self.largeProcessView];
    [self addSubview:self.smallValueLabel];
    [self addSubview:self.middleValueLabel];
    [self addSubview:self.largeValueLabel];
}

- (void)zfAutoLayoutView {
    CGFloat valueWidth = 50;
    [self.smallValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.trailing.mas_equalTo(self.mas_trailing).offset(0);
        make.width.mas_equalTo(valueWidth);
    }];
    
    [self.middleValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.smallValueLabel.mas_bottom).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(0);
        make.width.mas_equalTo(valueWidth);
    }];
    
    [self.largeValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.middleValueLabel.mas_bottom).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(0);
        make.width.mas_equalTo(valueWidth);
    }];
    
//============================
    CGFloat leftMaxWidth = 80;
    NSString *maxWidthText = ZFLocalizedString(@"OverallFit_TrueToSize", nil);
    CGSize textize = [maxWidthText textSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(leftMaxWidth, 25) lineBreakMode:NSLineBreakByCharWrapping];
    if (textize.width < leftMaxWidth) {
        leftMaxWidth = textize.width + 5;
    }
    
    [self.smallLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.smallValueLabel.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading);
        make.width.mas_equalTo(leftMaxWidth);
    }];
    
    [self.middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.middleValueLabel.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading);
        make.width.mas_equalTo(leftMaxWidth);
    }];
    
    [self.largeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.largeValueLabel.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading);
        make.width.mas_equalTo(leftMaxWidth);
    }];
    
//============================
    CGFloat processHeight = 8;
    
    [self.smallProcessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.smallValueLabel.mas_centerY);
        make.leading.mas_equalTo(self.smallLabel.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.smallValueLabel.mas_leading).offset(-12);
        make.height.mas_equalTo(processHeight);
    }];
    
    [self.middleProcessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.middleValueLabel.mas_centerY);
        make.leading.mas_equalTo(self.middleLabel.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.middleValueLabel.mas_leading).offset(-12);
        make.height.mas_equalTo(processHeight);
    }];
    
    [self.largeProcessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.largeValueLabel.mas_centerY);
        make.leading.mas_equalTo(self.largeLabel.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.largeValueLabel.mas_leading).offset(-12);
        make.height.mas_equalTo(processHeight);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

- (void)refreshSmallValue:(CGFloat)smallValue
              middleValue:(CGFloat)middleValue
               largeValue:(CGFloat)largeValue
{
    CGFloat percentAllValue = (smallValue + middleValue + largeValue);
    if (percentAllValue <= 0.0) {
        percentAllValue = 1.0;
    }
    self.smallProcessView.progress = smallValue / percentAllValue;
    self.middleProcessView.progress = middleValue / percentAllValue;
    self.largeProcessView.progress = largeValue / percentAllValue;
    
    self.smallValueLabel.text = [NSString stringWithFormat:@"%.2f%%", self.smallProcessView.progress * 100.0];
    self.middleValueLabel.text = [NSString stringWithFormat:@"%.2f%%", self.middleProcessView.progress * 100.0];
    self.largeValueLabel.text = [NSString stringWithFormat:@"%.2f%%", self.largeProcessView.progress * 100.0];
}

#pragma mark - getter

- (UILabel *)smallLabel {
    if (!_smallLabel) {
        _smallLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _smallLabel.backgroundColor = [UIColor whiteColor];
        _smallLabel.font = [UIFont systemFontOfSize:12];
        _smallLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _smallLabel.text = ZFLocalizedString(@"OverallFit_Small", nil);
    }
    return _smallLabel;
}

- (UILabel *)middleLabel {
    if (!_middleLabel) {
        _middleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _middleLabel.backgroundColor = [UIColor whiteColor];
        _middleLabel.font = [UIFont systemFontOfSize:12];
        _middleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _middleLabel.text = ZFLocalizedString(@"OverallFit_TrueToSize", nil);
        _middleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _middleLabel;
}

- (UILabel *)largeLabel {
    if (!_largeLabel) {
        _largeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _largeLabel.backgroundColor = [UIColor whiteColor];
        _largeLabel.font = [UIFont systemFontOfSize:12];
        _largeLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _largeLabel.text = ZFLocalizedString(@"OverallFit_Large", nil);
    }
    return _largeLabel;
}

- (UIProgressView *)smallProcessView {
    if (!_smallProcessView) {
        _smallProcessView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _smallProcessView.opaque = YES;
        _smallProcessView.trackTintColor = ZFCOLOR(240, 240, 240, 1);
        _smallProcessView.progressTintColor = ZFCOLOR(255, 160, 8, 1);
        _smallProcessView.progress = 0.01;
    }
    return _smallProcessView;
}

- (UIProgressView *)middleProcessView {
    if (!_middleProcessView) {
        _middleProcessView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _middleProcessView.backgroundColor = [UIColor whiteColor];
        _middleProcessView.trackTintColor = ZFCOLOR(240, 240, 240, 1);
        _middleProcessView.progressTintColor = ZFCOLOR(255, 160, 8, 1);
        _middleProcessView.progress = 0.01;
    }
    return _middleProcessView;
}

- (UIProgressView *)largeProcessView {
    if (!_largeProcessView) {
        _largeProcessView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _largeProcessView.backgroundColor = [UIColor whiteColor];
        _largeProcessView.trackTintColor = ZFCOLOR(240, 240, 240, 1);
        _largeProcessView.progressTintColor = ZFCOLOR(255, 160, 8, 1);
        _largeProcessView.progress = 0.01;
    }
    return _largeProcessView;
}

- (UILabel *)smallValueLabel {
    if (!_smallValueLabel) {
        _smallValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _smallValueLabel.backgroundColor = [UIColor whiteColor];
        _smallValueLabel.font = [UIFont systemFontOfSize:12];
        _smallValueLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _smallValueLabel;
}

- (UILabel *)middleValueLabel {
    if (!_middleValueLabel) {
        _middleValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _middleValueLabel.backgroundColor = [UIColor whiteColor];
        _middleValueLabel.font = [UIFont systemFontOfSize:12];
        _middleValueLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _middleValueLabel;
}

- (UILabel *)largeValueLabel {
    if (!_largeValueLabel) {
        _largeValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _largeValueLabel.backgroundColor = [UIColor whiteColor];
        _largeValueLabel.font = [UIFont systemFontOfSize:12];
        _largeValueLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _largeValueLabel;
}
@end

