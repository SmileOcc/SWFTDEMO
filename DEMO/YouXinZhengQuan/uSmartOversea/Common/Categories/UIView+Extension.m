//
//  UIView+Extension.m
//  垂直采1.0
//
//  Created by Leo on 16/2/19.
//  Copyright © 2016年 chuizhicai. All rights reserved.
//

#import "UIView+Extension.h"
#import <UIColor+YYAdd.h>
#import <Masonry/Masonry.h>

@implementation UIView (Extension)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)left { return self.x; }

- (CGFloat)right { return self.x+self.width; }

- (CGFloat)top { return self.y; }

- (CGFloat)bottom { return self.y+self.height; }


+ (UIView *)creatLineView
{
    UIView *view = [UIView new];
//    view.backgroundColor = UICOLOR_APP_LIGHT_GRAY;
    return  view;
}

+ (UIView *)ECMTag {
    
    return [self ECMTagWithText:@"国际认购" gradientColors:@[[UIColor colorWithHexString:@"#2D40AB"], [UIColor colorWithHexString:@"#6D74FF"]]];
}

+ (UIView *)ECMProfessionTagWithText:(NSString *)text {
    return [self ECMTagWithText:text gradientColors:@[[UIColor colorWithHexString:@"#2D40AB"], [UIColor colorWithHexString:@"#6D74FF"]]];
}

+ (UIView *)ECMCustomTagWithText:(NSString *)text {
    return [self ECMTagWithText:text gradientColors:@[[UIColor colorWithHexString:@"#B28B27"], [UIColor colorWithHexString:@"#E5BA61"]]];
}

+ (UIView *)commonBlueTagWithText:(NSString *)text {
    return [self tagWithText:text];
}

+ (UIView *)ECMTagWithText:(NSString *)text gradientColors:(NSArray *)colors {
    UIView *labelBgView = [[UIView alloc] init];
    labelBgView.frame = CGRectMake(0, 0, 48, 16);
    labelBgView.layer.cornerRadius = 1.0;
    labelBgView.layer.masksToBounds = true;

    UILabel *label = [[UILabel alloc] init];
    label.frame = labelBgView.bounds;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.whiteColor;//QMUITheme.textColorLevel1;
    label.font = [UIFont systemFontOfSize:10];
    label.text = text;
    
    CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    
    CAGradientLayer *bgLayer1 = [[CAGradientLayer alloc] init];
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    bgLayer1.colors = cgColors;
    bgLayer1.frame = CGRectMake(0, 0, size.width + 10, labelBgView.bounds.size.height);//labelBgView.bounds;
    bgLayer1.startPoint = CGPointMake(0, 0);
    bgLayer1.endPoint = CGPointMake(1, 0);
    
    [labelBgView.layer addSublayer:bgLayer1];
    
    [labelBgView addSubview:label];
    
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
//        make.width.mas_equalTo(48);
        make.top.bottom.equalTo(labelBgView);
        make.left.equalTo(labelBgView).offset(3);
        make.right.equalTo(labelBgView).offset(-3);
    }];
    
    return labelBgView;
}

+ (UIView *)tagWithText:(NSString *)text {
    UIView *labelBgView = [[UIView alloc] init];
    labelBgView.frame = CGRectMake(0, 0, 48, 16);
    labelBgView.layer.cornerRadius = 2.0;
    labelBgView.layer.masksToBounds = true;
    labelBgView.backgroundColor = [[UIColor colorWithHexString:@"#1E93F3"] colorWithAlphaComponent:0.1];

    UILabel *label = [[UILabel alloc] init];
    label.frame = labelBgView.bounds;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor qmui_colorWithHexString:@"#1E93F3"];
    label.font = [UIFont systemFontOfSize:12];
    label.text = text;
    
//    CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    
    [labelBgView addSubview:label];
    
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.top.equalTo(labelBgView).offset(2);
        make.bottom.equalTo(labelBgView).offset(-2);
        make.left.equalTo(labelBgView).offset(3);
        make.right.equalTo(labelBgView).offset(-3);
    }];
    
    return labelBgView;
}

- (void)startShakeAimation
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = @(-3);
    shake.toValue = @3.0F;
    shake.duration = 0.05;//执行时间
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 2;//次数
    [self.layer addAnimation:shake forKey:@"shakeAnimation"];
}

- (void)startBouncesAnimation
{
    CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    frameAnimation.duration = 0.15;
    frameAnimation.values = @[
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1.0)],
//                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)],
//                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]
                              ];
    [self.layer addAnimation:frameAnimation forKey:nil];
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

//画虚线
- (void)addBorderToLayerWithColor:(UIColor *)color {
    
    self.clipsToBounds = YES;
    
    CAShapeLayer *border = [CAShapeLayer layer];
    //  线条颜色
    border.strokeColor = color.CGColor;
    
    border.fillColor = nil;
    
    
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 0)];
    if (CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame)) {
        [pat addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    }else{
        [pat addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    }
    border.path = pat.CGPath;
    
    border.frame = self.bounds;
    
    // 不要设太大 不然看不出效果
    border.lineWidth = 0.5;
    border.lineCap = @"butt";
    
    //  第一个是 线条长度   第二个是间距    nil时为实线 @(YXConstant.screenWidth)
    border.lineDashPattern = @[@2, @1];
    
    [self.layer addSublayer:border];
}

+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor {
   
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:@[@(lineLength), @(lineSpacing)]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
    
}

@end
