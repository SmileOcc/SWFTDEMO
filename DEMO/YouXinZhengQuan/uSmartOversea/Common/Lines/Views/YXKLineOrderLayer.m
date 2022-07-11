//
//  YXKLineOrderLayer.m
//  uSmartOversea
//
//  Created by youxin on 2020/7/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXKLineOrderLayer.h"

@interface YXKLineOrderLayer()

@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *dashLineLayer;

@property (nonatomic, strong) CAShapeLayer *topLayer;
@end

@implementation YXKLineOrderLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.drawStyle = YXKLineOrderStyleDefault;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        [self addSublayer:self.topLayer];
        [self addSublayer:self.textLayer];
    }
    return self;
}

- (void)layoutSublayers {

    self.textLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    self.textLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.textLayer.bounds.size.height / 2.0 - 1.0);

    if (self.drawStyle == YXKLineOrderStyleDashLine) {
        self.topLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    } else {
        self.topLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }

    self.topLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.topLayer.bounds.size.height / 2.0);

    [self drawTopLayer];

    if (self.drawStyle == YXKLineOrderStyleDashLine) {
        [self drawDashLineStyle];
    }

}

- (void)drawTopLayer {

    CGFloat cornerRadius = 1.0;
    CGSize arrowSize = CGSizeMake(0, 0);
    CGRect roundedRect = self.topLayer.bounds;
    if (self.drawStyle == YXKLineOrderStyleArrow) {
        arrowSize = CGSizeMake(3, 2);
    }

    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);

    // 从左上角逆时针绘制
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];

    [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftBottomArcCenter.y)];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];

    // 箭头向下
    CGFloat arrowMinX = (self.bounds.size.width - arrowSize.width) / 2.0;
    [path addLineToPoint:CGPointMake(arrowMinX, CGRectGetMaxY(roundedRect))];
    [path addLineToPoint:CGPointMake(arrowMinX + arrowSize.width / 2, CGRectGetMaxY(roundedRect) + arrowSize.height)];
    [path addLineToPoint:CGPointMake(arrowMinX + arrowSize.width, CGRectGetMaxY(roundedRect))];

    [path addLineToPoint:CGPointMake(rightBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];

    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightTopArcCenter.y)];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];

    self.topLayer.path = path.CGPath;
}

- (void)drawDashLineStyle {

    self.dashLineLayer.bounds = CGRectMake(0, 0, self.frame.size.width, 5);
    self.dashLineLayer.position = CGPointMake(self.bounds.size.width / 2.0 + 0.5, self.topLayer.frame.size.height + 1.0 + self.dashLineLayer.bounds.size.height / 2.0);

    UIBezierPath *path = [UIBezierPath bezierPath];

    CGFloat patternHeight = self.dashLineLayer.frame.size.height / 5.0;

    [path moveToPoint:CGPointMake(self.dashLineLayer.bounds.size.width / 2.0, 0)];
    [path addLineToPoint:CGPointMake(self.startX, self.dashLineLayer.frame.size.height)];

    self.dashLineLayer.path = path.CGPath;
    self.dashLineLayer.lineDashPattern = @[@(patternHeight), @(patternHeight)];

    if (self.dashLineLayer.superlayer == nil) {
        [self addSublayer:self.dashLineLayer];
    }

}

- (void)setOrderDirection:(YXKLineOrderDirection)orderDirection {
    _orderDirection = orderDirection;
    NSString *text = @"B";
    if (orderDirection == YXKLineOrderDirectionBuy) {
        text = @"B";
    } else if (orderDirection == YXKLineOrderDirectionSell) {
        text = @"S";
    } else {
        text = @"T";
    }
    self.textLayer.string = text;
    UIColor *color = [self orderDirectionColor];

    self.topLayer.fillColor = color.CGColor;
    if (self.drawStyle == YXKLineOrderStyleDashLine) {
        self.dashLineLayer.strokeColor = color.CGColor;
    }
}

- (UIColor *)orderDirectionColor {
    UIColor *color = [QMUITheme themeTextColor];
    switch (_orderDirection) {
        case YXKLineOrderDirectionBuy:
            color = [QMUITheme themeTextColor];
            break;
        case YXKLineOrderDirectionSell:
            color = [UIColor qmui_colorWithHexString:@"#FFBF32"];
            break;

        case YXKLineOrderDirectionBoth:
            color = [UIColor qmui_colorWithHexString:@"#FF7127"];
            break;
    }
    return color;
}

- (CATextLayer *)textLayer {
    if (!_textLayer) {
        _textLayer = [[CATextLayer alloc] init];
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        UIFont *font = [UIFont systemFontOfSize:8 weight:UIFontWeightRegular];
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef =CGFontCreateWithFontName(fontName);
        _textLayer.font = fontRef;
        _textLayer.fontSize = 8;
        CGFontRelease(fontRef);
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    }
    return _textLayer;
}

- (CAShapeLayer *)dashLineLayer {
    if (!_dashLineLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = 1.0;
        layer.fillColor = UIColor.clearColor.CGColor;
        _dashLineLayer = layer;
    }
    return _dashLineLayer;
}

- (CAShapeLayer *)topLayer {
    if (!_topLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        _topLayer = layer;
    }
    return _topLayer;
}
@end
#pragma mark - YXKLineCompanyActionLayer

@implementation YXKLineCompanyActionLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cornerRadius = 3.0;
        self.masksToBounds = YES;
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)setActionStyle:(YXKLineCompanyActionStyle)actionStyle {
    if (actionStyle == YXKLineCompanyActionStyleFinancial) {
        self.backgroundColor = QMUITheme.themeTextColor.CGColor;
    } else if (actionStyle == YXKLineCompanyActionStyleDividend) {
        self.backgroundColor = [UIColor themeColorWithNormalHex:@"#F9A800" andDarkColor:@"#C78600"].CGColor;
    } else {
        self.backgroundColor = [UIColor themeColorWithNormalHex:@"#C4C5CE" andDarkColor:@"#5D5E66"].CGColor;
    }
}

@end

