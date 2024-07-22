//
//  CategoryPriceRangeView.m
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryPriceRangeView.h"
#import "TTRangeSlider.h"
#import "CategoryRefineSectionModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface CategoryPriceRangeView ()<TTRangeSliderDelegate>
@property (nonatomic, strong) CALayer           *topLine;
@property (nonatomic, strong) CALayer           *middleLine;
@property (nonatomic, strong) CALayer           *bottomLine;
@property (nonatomic, strong) YYLabel           *titleLabel;
@property (nonatomic, strong) TTRangeSlider     *rangeSlider;
@end

@implementation CategoryPriceRangeView
#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.layer addSublayer:self.topLine];
    [self addSubview:self.titleLabel];
    [self.layer addSublayer:self.middleLine];
    [self addSubview:self.rangeSlider];
    [self.layer addSublayer:self.bottomLine];
}

- (void)autoLayoutSubViews {
    self.topLine.frame = CGRectMake(0, 0, KScreenWidth-75, MIN_PIXEL);
    self.middleLine.frame = CGRectMake(0, 44 - MIN_PIXEL, KScreenWidth-75, MIN_PIXEL);
    self.bottomLine.frame = CGRectMake(0, 124 - MIN_PIXEL, KScreenWidth-75, MIN_PIXEL);
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.leading.equalTo(self).offset(12);
    }];

    [self.rangeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(44);
        make.leading.mas_equalTo(self.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.height.mas_equalTo(80);
    }];
}

#pragma mark - Setter
- (void)setModel:(CategoryRefineSectionModel *)model {
    _model = model;
    
    NSString *maxString = [ExchangeManager transforPrice:[NSString stringWithFormat:@"%f",ceilf([model.priceMax floatValue])]];
    if ([maxString length] >= 8) {
        [self.rangeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            if ([SystemConfigUtils isRightToLeftShow]) {make.leading.mas_equalTo(self.mas_leading).offset(25.0f);
            } else {
                make.trailing.mas_equalTo(self.mas_trailing).offset(-25.0f);
            }
        }];
    }
    
    self.rangeSlider.maxValue = [model.priceMax floatValue];
    self.rangeSlider.minValue = [model.priceMin floatValue];
    
    self.rangeSlider.selectedMinimum = [model.selectPriceMin floatValue];
    
    if (model.selectPriceMax) {
        self.rangeSlider.selectedMaximum = [model.selectPriceMax floatValue];
    } else {
        self.rangeSlider.selectedMaximum = [model.priceMax floatValue];
    }
    [self setNeedsDisplay];
}

#pragma mark - TTRangeSliderDelegate
- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {
    if (self.priceRangeSelectedCompletionHandler) {
        self.priceRangeSelectedCompletionHandler(selectedMinimum, selectedMaximum);
    }
}

#pragma mark - Getter
- (CALayer *)topLine {
    if (!_topLine) {
        _topLine = [CALayer layer];
        _topLine.backgroundColor = ZFCOLOR(176, 176, 176, 1).CGColor;
    }
    return _topLine;
}

- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _titleLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.text = ZFLocalizedString(@"Category_Price_Range", nil);
    }
    return _titleLabel;
}

- (TTRangeSlider *)rangeSlider {
    if (!_rangeSlider) {
        _rangeSlider = [[TTRangeSlider alloc] initWithFrame:CGRectMake(0, 44, KScreenWidth - 75, 80)];
        _rangeSlider.tintColor = ZFC0xFE5269();
        _rangeSlider.delegate = self;
    }
    return _rangeSlider;
}


- (CALayer *)middleLine {
    if (!_middleLine) {
        _middleLine = [CALayer layer];
        _middleLine.backgroundColor = ZFCOLOR(221, 221, 221, 1).CGColor;
    }
    return _middleLine;
}

- (CALayer *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [CALayer layer];
        _bottomLine.backgroundColor = ZFCOLOR(221, 221, 221, 1).CGColor;
    }
    return _bottomLine;
}

@end
