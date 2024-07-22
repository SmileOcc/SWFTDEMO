//
//  ZFCMSProgressView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSProgressView.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"

@implementation ZFCMSProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFCClearColor();
        [self addSubview:self.progressView];
        [self addSubview:self.progressTrackView];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.height.mas_equalTo(5);
        }];
        
        [self.progressTrackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self.progressView);
            make.width.mas_equalTo(self.progressView.mas_width).multipliedBy(0);
        }];
    }
    return self;
}

- (void)updateProgressMax:(CGFloat)max min:(CGFloat)min {
    self.max = max >= 0 ? max : 0;
    self.min = min >= 0 ? min : 0;
    
    CGFloat multiple = 0;
    if (self.max == 0) {
        multiple = 1.0;
    } else {
        if (self.min >= self.max) self.min = self.max;
        multiple = self.min / self.max;
    }
    
    [self.progressTrackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.progressView);
        make.width.mas_equalTo(self.progressView.mas_width).multipliedBy(multiple);
    }];
}

#pragma mark - Property Method

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor ? trackColor : ZFC0xFFA0AE();
    self.progressTrackView.backgroundColor = _trackColor;
}

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor ? backColor : ZFC0xEEEEEE();
    self.progressView.backgroundColor = _backColor;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressView.backgroundColor = ZFC0xEEEEEE();
        _progressView.layer.cornerRadius = 2.5;
        _progressView.layer.masksToBounds = YES;
    }
    return _progressView;
}

- (UIView *)progressTrackView {
    if (!_progressTrackView) {
        _progressTrackView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressTrackView.backgroundColor = ZFC0xFFA0AE();
        _progressTrackView.layer.cornerRadius = 2.5;
        _progressTrackView.layer.masksToBounds = YES;
    }
    return _progressTrackView;
}

@end


@implementation ZFCMSLineProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pathLineColor = ZFC0xFFFFFF_03();
        self.backgroundColor = ZFCClearColor();
        [self addSubview:self.progressView];
        [self addSubview:self.progressTrackView];
        [self addSubview:self.percentageLabel];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self);
        }];
        
        [self.progressTrackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(0);
        }];
        
        [self.percentageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)updateProgressMax:(CGFloat)max min:(CGFloat)min {
    
    
    CGFloat leftSpace = 5.0;
    CGFloat lineW = 4.0;
    CGFloat w = CGRectGetWidth(self.frame) - 2 * leftSpace;
    CGFloat rechtH = CGRectGetHeight(self.frame);
    NSInteger counts = w / (2 * lineW);
    
    YWLog(@"------- max: %f min: %f   %@",max,min,NSStringFromCGRect(self.frame));
    
    UIBezierPath *path = [UIBezierPath new];
    
    for (int i=0; i<counts; i++) {
        if (i % 2 == 0) {
            [path moveToPoint:CGPointMake(leftSpace + lineW * i, rechtH)];
            [path addLineToPoint:CGPointMake(leftSpace + lineW * (i+1), 0)];
        }
    }
    
    if (!self.lineChartLayer) {
        
        self.lineChartLayer = [CAShapeLayer new];
        self.lineChartLayer.strokeColor = self.pathLineColor.CGColor;
        self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
        
        self.lineChartLayer.lineCap = kCALineCapRound;
        self.lineChartLayer.lineJoin = kCALineJoinRound;
        self.lineChartLayer.lineWidth = lineW;
        self.lineChartLayer.lineDashPattern = @[@(5), @(1)];
        [self.progressTrackView.layer addSublayer: self.lineChartLayer];
        
        self.progressTrackView.layer.cornerRadius = rechtH / 2.0;
    }
    
    self.lineChartLayer.path = path.CGPath;
    
    self.max = max >= 0 ? max : 0;
    self.min = min >= 0 ? min : 0;
    
    CGFloat multiple = 0;
    if (self.max == 0) {
        multiple = 1.0;
    } else {
        if (self.min >= self.max) self.min = self.max;
        multiple = self.min / self.max;
    }
    
    //FIXME: occ Bug 1101 用这个父类可能就没了，刷新时
//    [self.progressTrackView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(self.mas_width).multipliedBy(multiple);
//    }];
    
    [self.progressTrackView mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.leading.top.bottom.mas_equalTo(self);
         make.width.mas_equalTo(self.mas_width).multipliedBy(multiple);
     }];
}


#pragma mark - Property Method

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor ? trackColor : ZFC0xFFA0AE();
    self.progressTrackView.backgroundColor = _trackColor;
}

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor ? backColor : ZFC0xEEEEEE();
    self.progressView.backgroundColor = _backColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor ? textColor: ZFC0x999999();
    self.percentageLabel.textColor = _textColor;
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont ? textFont : [UIFont systemFontOfSize:14];
    self.percentageLabel.font = textFont;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressView.backgroundColor = ZFC0xEEEEEE();
        _progressView.layer.cornerRadius = 2.5;
        _progressView.layer.masksToBounds = YES;
    }
    return _progressView;
}

- (UIView *)progressTrackView {
    if (!_progressTrackView) {
        _progressTrackView = [[UIView alloc] initWithFrame:CGRectZero];
        _progressTrackView.backgroundColor = ZFC0xFFA0AE();
        _progressTrackView.layer.cornerRadius = 2.5;
        _progressTrackView.layer.masksToBounds = YES;
    }
    return _progressTrackView;
}

- (UILabel *)percentageLabel {
    if (!_percentageLabel) {
        _percentageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _percentageLabel.textAlignment = NSTextAlignmentCenter;
        _percentageLabel.textColor = ZFC0xFFFFFF();
    }
    return _percentageLabel;
}
@end
