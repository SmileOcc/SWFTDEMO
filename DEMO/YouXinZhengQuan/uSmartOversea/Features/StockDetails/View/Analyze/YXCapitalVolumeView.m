//
//  YXCapitalVolumeView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXCapitalVolumeView.h"
#import "YXLayerGenerator.h"
#import "uSmartOversea-Swift.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>

@interface YXCapitalVolumeSingleView: UIView

@property (nonatomic, strong) NSArray *values;

@property (nonatomic, strong) UILabel *bigLabel;

@property (nonatomic, strong) UILabel *midLabel;

@property (nonatomic, strong) UILabel *smallLabel;

@property (nonatomic, assign) double maxValue;

@property (nonatomic, strong) CAShapeLayer *blackLayer;
@property (nonatomic, strong) CAShapeLayer *greenLayer;
@property (nonatomic, strong) CAShapeLayer *redLayer;


@property (nonatomic, assign) BOOL isGreen;

@property (nonatomic, strong) UIView *zeroLineView;

@end

@implementation YXCapitalVolumeSingleView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.bigLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme stockRedColor] textFont:[UIFont systemFontOfSize:12]];
    self.midLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme stockRedColor] textFont:[UIFont systemFontOfSize:12]];
    self.smallLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme stockRedColor] textFont:[UIFont systemFontOfSize:12]];


    [self addSubview:self.bigLabel];
    [self addSubview:self.midLabel];
    [self addSubview:self.smallLabel];
    
    self.blackLayer = [[CAShapeLayer alloc] init];
    self.blackLayer.lineWidth = 0;
    self.blackLayer.cornerRadius = 2.0;
    
    self.greenLayer = [[CAShapeLayer alloc] init];
    self.greenLayer.lineWidth = 0;
    self.greenLayer.cornerRadius = 2.0;
    
    self.redLayer = [[CAShapeLayer alloc] init];
    self.redLayer.lineWidth = 0;
    self.redLayer.cornerRadius = 2.0;

    self.blackLayer.fillColor = [QMUITheme stockRedColor].CGColor;
    self.greenLayer.fillColor = [[QMUITheme stockRedColor] colorWithAlphaComponent:0.7].CGColor;
    self.redLayer.fillColor = [[QMUITheme stockRedColor] colorWithAlphaComponent:0.4].CGColor;
    
    [self.layer addSublayer:self.blackLayer];
    [self.layer addSublayer:self.greenLayer];
    [self.layer addSublayer:self.redLayer];
    
    CGFloat labelW = (self.mj_w - 15 * 2) / 3;
    self.bigLabel.frame = CGRectMake(0, 0, labelW, 22);

    self.midLabel.frame = CGRectMake(0, 27, labelW, 22);

    self.smallLabel.frame = CGRectMake(0, 54, labelW, 22);

    
    self.bigLabel.hidden = YES;
    self.midLabel.hidden = YES;
    self.smallLabel.hidden = YES;
}

- (void)drawVolume {
    if (self.maxValue <= 0) {
        return;
    }
    self.bigLabel.hidden = NO;
    self.midLabel.hidden = NO;
    self.smallLabel.hidden = NO;

    CGFloat maxWidth = 0;
//    double maxValue = 0;

    for (int i = 0; i < self.values.count; ++i) {
        NSNumber *valueNum = (NSNumber *)self.values[i];
        double value = valueNum.doubleValue;
        if (i < 3 && self.maxValue < value) {
            self.maxValue = value;
        }
        if (i == 0) {
            if (value == 0) {
                self.bigLabel.text = @"0";
            } else {
                NSString *text = [YXToolUtility stockData:value deciPoint:2 stockUnit:@"" priceBase:0];
                self.bigLabel.text = text;
            }
            [self.bigLabel sizeToFit];
            if (maxWidth < self.bigLabel.width) {
                maxWidth = self.bigLabel.width;
            }

        } else if (i == 1){
            if (value == 0) {
                self.midLabel.text = @"0";
            } else {
                NSString *text = [YXToolUtility stockData:value deciPoint:2 stockUnit:@"" priceBase:0];
                self.midLabel.text = text;
            }
            [self.midLabel sizeToFit];
            if (maxWidth < self.midLabel.width) {
                maxWidth = self.midLabel.width;
            }

        } else if (i == 2) {
            if (value == 0) {
                self.smallLabel.text = @"0";
            } else {
                NSString *text = [YXToolUtility stockData:value deciPoint:2 stockUnit:@"" priceBase:0];
                self.smallLabel.text = text;
            }
            [self.smallLabel sizeToFit];
            if (maxWidth < self.smallLabel.width) {
                maxWidth = self.smallLabel.width;
            }
        }
    }

    maxWidth += 4;
    
    UIBezierPath *bigVolumePath = [[UIBezierPath alloc] init];
    UIBezierPath *midVolumePath = [[UIBezierPath alloc] init];
    UIBezierPath *smallVolumePath = [[UIBezierPath alloc] init];

    for (int i = 0; i < self.values.count; ++i) {
        NSNumber *valueNum = (NSNumber *)self.values[i];
        double value = valueNum.doubleValue;
        CGFloat width = self.mj_w - maxWidth;
        if (self.maxValue != 0) {
            width = (self.mj_w - maxWidth) * (value / self.maxValue);
        } else {
            width = 0;
        }

        CGRect drawRect = CGRectZero;
        if (self.isGreen) {
            drawRect = CGRectMake(0, 5 + (14 + 13) * i, width, 14);
        } else {
            drawRect = CGRectMake(self.frame.size.width - width, 5 + (14 + 13) * i, width, 14);
        }

        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:2.0];
        if (i == 0) {
            [bigVolumePath appendPath:path];
            CGFloat x = 0;
            if (self.isGreen) {
                x = width + 4;
            } else {
                x = self.mj_w - width - 4 - self.bigLabel.mj_w;
            }

            self.bigLabel.frame = CGRectMake(x, 0, self.bigLabel.mj_w, 22);
            
        } else if (i == 1){
            [midVolumePath appendPath:path];
            CGFloat x = 0;
            if (self.isGreen) {
                x = width + 4;
            } else {
                x = self.mj_w - width - 4 - self.midLabel.mj_w;
            }

            self.midLabel.frame = CGRectMake(x, 27, self.midLabel.mj_w, 22);

        } else if (i == 2) {
            [smallVolumePath appendPath:path];
            CGFloat x = 0;
            if (self.isGreen) {
                x = width + 4;
            } else {
                x = self.mj_w - width - 4 - self.smallLabel.mj_w;
            }

            self.smallLabel.frame = CGRectMake(x, 54, self.smallLabel.mj_w, 22);

        }
    }
    
    self.blackLayer.path = bigVolumePath.CGPath;
    self.greenLayer.path = midVolumePath.CGPath;
    self.redLayer.path = smallVolumePath.CGPath;
}

- (void)setValues:(NSArray *)values {
    _values = values;
    
    if (values.count == 0) {
        return;
    }
    [self drawVolume];
}

- (void)setIsGreen:(BOOL)isGreen {
    _isGreen = isGreen;
    if (isGreen) {
        self.blackLayer.fillColor = [QMUITheme stockGreenColor].CGColor;
        self.greenLayer.fillColor = [[QMUITheme stockGreenColor] colorWithAlphaComponent:0.7].CGColor;
        self.redLayer.fillColor = [[QMUITheme stockGreenColor] colorWithAlphaComponent:0.4].CGColor;

        self.bigLabel.textColor = [QMUITheme stockGreenColor];
        self.midLabel.textColor = [QMUITheme stockGreenColor];
        self.smallLabel.textColor = [QMUITheme stockGreenColor];

        self.bigLabel.textAlignment = NSTextAlignmentLeft;
        self.midLabel.textAlignment = NSTextAlignmentLeft;
        self.smallLabel.textAlignment = NSTextAlignmentLeft;
    }
}

@end

@interface YXCapitalVolumeView ()

@property (nonatomic, strong) YXCapitalVolumeSingleView *inView;

@property (nonatomic, strong) YXCapitalVolumeSingleView *outView;

@end

@implementation YXCapitalVolumeView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {

    UILabel *bigTitleLabel = [[UILabel alloc] init];
    bigTitleLabel.text = [YXLanguageUtility kLangWithKey:@"analytics_money_large"];
    bigTitleLabel.textColor = [QMUITheme textColorLevel3];
    bigTitleLabel.font = [UIFont systemFontOfSize:14];

    UILabel *midTitleLabel = [[UILabel alloc] init];
    midTitleLabel.text = [YXLanguageUtility kLangWithKey:@"analytics_money_medium"];
    midTitleLabel.textColor = [QMUITheme textColorLevel3];
    midTitleLabel.font = [UIFont systemFontOfSize:14];

    UILabel *smallTitleLabel = [[UILabel alloc] init];
    smallTitleLabel.text = [YXLanguageUtility kLangWithKey:@"analytics_money_small"];
    smallTitleLabel.textColor = [QMUITheme textColorLevel3];
    smallTitleLabel.font = [UIFont systemFontOfSize:14];

    bigTitleLabel.adjustsFontSizeToFitWidth = YES;
    bigTitleLabel.minimumScaleFactor = 0.3;
    midTitleLabel.adjustsFontSizeToFitWidth = YES;
    midTitleLabel.minimumScaleFactor = 0.3;
    smallTitleLabel.adjustsFontSizeToFitWidth = YES;
    smallTitleLabel.minimumScaleFactor = 0.3;

    bigTitleLabel.textAlignment = NSTextAlignmentCenter;
    midTitleLabel.textAlignment = NSTextAlignmentCenter;
    smallTitleLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:bigTitleLabel];
    [self addSubview:midTitleLabel];
    [self addSubview:smallTitleLabel];

    [bigTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(22);
    }];

    [midTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(bigTitleLabel.mas_bottom).offset(7);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(22);
    }];

    [smallTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(midTitleLabel.mas_bottom).offset(7);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(22);
    }];

    CGFloat margin = 16;
    CGFloat width = (YXConstant.screenWidth - 32 - 65) / 2.0;

    self.inView = [[YXCapitalVolumeSingleView alloc] initWithFrame:CGRectMake(margin, 0, width, self.mj_h)];
    self.outView = [[YXCapitalVolumeSingleView alloc] initWithFrame:CGRectMake(width + margin + 65, 0, width, self.mj_h)];
    self.outView.isGreen = YES;
    [self addSubview:self.inView];
    [self addSubview:self.outView];
}

- (void)setValues:(NSArray<NSNumber *> *)values {
    _values = values;
    
    if (values.count == 0) {
        return;
    }
    
    // 找到最大值
    double maxValue = [[values valueForKeyPath:@"@max.doubleValue"] doubleValue];
    self.inView.maxValue = maxValue;
    self.outView.maxValue = maxValue;
    
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    for (int i = 0; i < values.count; ++i) {
        if (i < 3) {
            [arr1 addObject:values[i]];
        } else {
            [arr2 addObject:values[i]];
        }
    }
    
    self.inView.values = arr1;
    self.outView.values = arr2;
}

@end
