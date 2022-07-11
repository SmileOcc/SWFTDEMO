//
//  CouponsItemView.m
//  testLayer
//
//  Created by Starlinke on 2021/7/30.
//

#import "CouponsItemView.h"

@interface CouponsItemView()

@property (nonatomic, strong) UIView *bgView;


@end

@implementation CouponsItemView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    [self addSubview:self.bgView];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

// 设置源
- (void)setStartY:(CGFloat)startY{
    _startY = startY;
}

- (void)setCornerType:(couponsCornerType)cornerType{
    _cornerType = cornerType;
}

- (void)setCornerValue:(CGFloat)cornerValue{
    _cornerValue = cornerValue;
}

- (void)setDiretion:(couponsDiretion)diretion{
    _diretion = diretion;
}

- (void)setStartColor:(NSString *)startColor{
    _startColor = startColor;
}

- (void)setEndColor:(NSString *)endColor{
    _endColor = endColor;
}

- (void)setLineColor:(NSString *)lineColor{
    _lineColor = lineColor;
}

- (void)setLineBorderColor:(NSString *)lineBorderColor{
    _lineBorderColor = lineBorderColor;
}

- (void)setRadio:(CGFloat)radio{
    _radio = radio;
}

- (void)startDrawView{
    [self layoutIfNeeded];
    [self addlayerWithView:self.bgView withStokeColor:[self colorWithHex:_lineBorderColor] fromColor:_startColor toColor:_endColor lineColor:_lineColor];
}

#pragma mark --- lazy
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

/// 绘制控件
/// @param view 对哪个控件进行绘制
/// @param stokeColor 边框的颜色
/// @param fromColor 渐变初始颜色
/// @param toColor 渐变最终颜色
/// @param lineColor 虚线的颜色
 - (void)addlayerWithView:(UIView *)view withStokeColor:(UIColor *)stokeColor fromColor:(NSString *)fromColor toColor:(NSString *)toColor lineColor:(NSString *)lineColor{
     
     if (!stokeColor) {
         stokeColor = [UIColor clearColor];
     }
     
     UIBezierPath *path = [UIBezierPath bezierPath];
     if (self.cornerType == couponsCornerTypeNone) {
         // 不带圆角
         path.lineCapStyle = kCGLineCapSquare;
         path.lineJoinStyle = kCGLineCapSquare;
         
         [path moveToPoint:CGPointMake(0, 0)];

         [path addLineToPoint:CGPointMake(view.bounds.size.width, 0)];
         [path addLineToPoint:CGPointMake(view.bounds.size.width, self.startY)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width, self.startY+_radio) radius:_radio startAngle:1.5*M_PI endAngle:0.5*M_PI clockwise:NO];
         [path addLineToPoint:CGPointMake(view.bounds.size.width, view.bounds.size.height)];
         [path addLineToPoint:CGPointMake(0, view.bounds.size.height)];
         [path addLineToPoint:CGPointMake(0, self.startY + 2*_radio)];
         [path addArcWithCenter:CGPointMake(0, self.startY+_radio) radius:_radio startAngle:0.5*M_PI endAngle:1.5*M_PI clockwise:NO];
         [path addLineToPoint:CGPointMake(0, 0)];
         
         [path stroke];
     }else if(self.cornerType == couponsCornerTypeCorner){
         // 带圆角 圆角半径
         if (self.cornerValue == 0) {
             self.cornerValue = 6;
         }
         CGFloat radio = self.cornerValue;
         
         [path addArcWithCenter:CGPointMake(radio, radio) radius:radio startAngle:M_PI endAngle:M_PI*3/2 clockwise:YES];
         [path addLineToPoint:CGPointMake(view.bounds.size.width - radio, 0)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width - radio, radio) radius:radio startAngle:M_PI*3/2 endAngle:0 clockwise:YES];
         [path addLineToPoint:CGPointMake(view.bounds.size.width, self.startY)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width, self.startY+_radio) radius:_radio startAngle:1.5*M_PI endAngle:0.5*M_PI clockwise:NO];
         
         [path addLineToPoint:CGPointMake(view.bounds.size.width, view.bounds.size.height-radio)];
         
         [path addArcWithCenter:CGPointMake(view.bounds.size.width - radio, view.bounds.size.height-radio) radius:radio startAngle:0 endAngle:0.5*M_PI clockwise:YES];
         [path addLineToPoint:CGPointMake(radio, view.bounds.size.height)];
         
         [path addArcWithCenter:CGPointMake(radio, view.bounds.size.height-radio) radius:radio startAngle:0.5*M_PI endAngle:M_PI clockwise:YES];
         [path addArcWithCenter:CGPointMake(0, self.startY+_radio) radius:_radio startAngle:0.5*M_PI endAngle:1.5*M_PI clockwise:NO];
         [path addLineToPoint:CGPointMake(0, radio)];
         [path stroke];
     }
     
     CAShapeLayer *layer = [[CAShapeLayer alloc] init];
     layer.frame = view.bounds;
     layer.path = path.CGPath;
     layer.lineWidth = 1;
     layer.strokeColor = stokeColor.CGColor;
     layer.fillColor = [UIColor orangeColor].CGColor;


     CAGradientLayer *jianBianLayer = [self setGradualChangingColor:self.bgView fromColor:fromColor toColor:toColor];
     jianBianLayer.mask = layer;

     [self.bgView.layer addSublayer: jianBianLayer];

     CAShapeLayer *borderlayer = [[CAShapeLayer alloc] init];
     borderlayer.frame = view.bounds;
     borderlayer.path = path.CGPath;
     borderlayer.lineWidth = 1;
     borderlayer.strokeColor = stokeColor.CGColor;
     borderlayer.fillColor = [UIColor clearColor].CGColor;
     [self.bgView.layer addSublayer: borderlayer];

     UIColor *xuLineColor = nil;
     if (STLIsEmptyString(lineColor)) {
         xuLineColor = [UIColor clearColor];
     }else{
         xuLineColor = [self colorWithHex:lineColor];
     }
     

    [self drawLineOfDashByCAShapeLayer:self.bgView lineLength:5 lineSpacing:2 lineColor:xuLineColor];
}

//绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr{
    
    UIColor *fromColor = nil;
    UIColor *endColor = nil;
    if (STLIsEmptyString(fromHexColorStr)) {
        fromColor = [UIColor clearColor];
    }else{
        fromColor = [self colorWithHex:fromHexColorStr];
    }
    if (STLIsEmptyString(toHexColorStr)) {
        endColor = [UIColor clearColor];
    }else{
        endColor = [self colorWithHex:toHexColorStr];
    }

//    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;

    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)endColor.CGColor];

    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    switch (_diretion) {
        case couponsDiretionLeftToRight:{
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(1, 0);
        }
            break;
        case couponsDiretionRightToLeft:{
            startPoint = CGPointMake(1, 0);
            endPoint = CGPointMake(0, 0);
        }
            break;
        case couponsDiretionTopToBottom:{
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(0, 1);
        }
            break;
        case couponsDiretionBottomToTop:{
            startPoint = CGPointMake(0, 1);
            endPoint = CGPointMake(0, 0);
        }
            break;
            
        default:{
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(1, 0);
        }
            break;
    }
    
    
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;

    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];

    return gradientLayer;
}

//获取16进制颜色的方法
- (UIColor *)colorWithHex:(NSString *)hexColor {
    hexColor = [hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([hexColor length] < 6) {
        return nil;
    }
    if ([hexColor hasPrefix:@"#"]) {
        hexColor = [hexColor substringFromIndex:1];
    }
    NSRange range;
    range.length = 2;
    range.location = 0;
    NSString *rs = [hexColor substringWithRange:range];
    range.location = 2;
    NSString *gs = [hexColor substringWithRange:range];
    range.location = 4;
    NSString *bs = [hexColor substringWithRange:range];
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rs] scanHexInt:&r];
    [[NSScanner scannerWithString:gs] scanHexInt:&g];
    [[NSScanner scannerWithString:bs] scanHexInt:&b];
    if ([hexColor length] == 8) {
        range.location = 4;
        NSString *as = [hexColor substringWithRange:range];
        [[NSScanner scannerWithString:as] scanHexInt:&a];
    } else {
        a = 255;
    }
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:((float)a / 255.0f)];
}


/**
 *  通过 CAShapeLayer 方式绘制虚线
 *
 *  param lineView:       需要绘制成虚线的view
 *  param lineLength:     虚线的宽度
 *  param lineSpacing:    虚线的间距
 *  param lineColor:      虚线的颜色
 **/
- (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(lineView.bounds.size.width / 2.0,       lineView.bounds.size.height/2.0)];
//    //设置虚线颜色
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //设置虚线宽度
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //设置虚线的线宽及间距
     [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
     //创建虚线绘制路径
     CGMutablePathRef path = CGPathCreateMutable();
     //设置虚线绘制路径起点
     CGPathMoveToPoint(path, NULL, _radio, self.startY + _radio);
     //设置虚线绘制路径终点
      CGPathAddLineToPoint(path, NULL, lineView.bounds.size.width - _radio, self.startY + _radio);
       //设置虚线绘制路径
     [shapeLayer setPath:path];
     CGPathRelease(path);
     //添加虚线
     [lineView.layer addSublayer:shapeLayer];
}

@end
