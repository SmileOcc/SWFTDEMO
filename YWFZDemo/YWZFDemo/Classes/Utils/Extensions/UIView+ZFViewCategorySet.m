//
//  UIView+ZFViewCategorySet.m
//  ZZZZZ
//
//  Created by YW on 2018/12/3.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "UIView+ZFViewCategorySet.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "Constants.h"

const void * KTapGesture = "KTapGesture";
const void * KTapGestureComplete = "KTapGestureComplete";

@interface UIView ()

@property (nonatomic, copy) UIViewGestureComplete tapGestureComplete;

@end

@implementation UIView (ZFViewCategorySet)

#pragma mark - UIView (Responder) ==================================================

//获取导航控制器
- (UINavigationController * )navigationController{
    UIResponder * next = [self nextResponder];
    while (next!=nil) {
        if([next isKindOfClass:[UINavigationController class]]){
            return (UINavigationController * )next;
        }
        next = [next nextResponder];
    }
    return nil;
}
//获取标签控制器
- (UITabBarController * )tabBarController{
    UIResponder * next = [self nextResponder];
    while (next!=nil) {
        if([next isKindOfClass:[UITabBarController class]]){
            return (UITabBarController * )next;
        }
        next = [next nextResponder];
    }
    return nil;
}
//获取控制器
- (UIViewController * )viewController{
    UIResponder * next = [self nextResponder];
    while (next!=nil) {
        if([next isKindOfClass:[UIViewController class]]){
            return (UIViewController * )next;
        }
        next = [next nextResponder];
    }
    return nil;
}
//获取主窗口
- (UIWindow * )rootWindow{
    UIResponder * next = [self nextResponder];
    while (next!=nil) {
        if([next isKindOfClass:[UIWindow class]]){
            return (UIWindow * )next;
        }
        next = [next nextResponder];
    }
    return nil;
}

#pragma mark - UIView (AutoLayoutSpace) ==================================================

- (void)distributeSpacingHorizontallyWith:(NSArray*)views
{
    NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
    
    for ( int i = 0 ; i < views.count+1 ; ++i )
    {
        UIView *v = [UIView new];
        [spaces addObject:v];
        [self addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(v.mas_height);
        }];
    }
    
    UIView *v0 = spaces[0];
    
    [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.centerY.equalTo(((UIView*)views[0]).mas_centerY);
    }];
    
    UIView *lastSpace = v0;
    for ( int i = 0 ; i < views.count; ++i )
    {
        UIView *obj = views[i];
        UIView *space = spaces[i+1];
        
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(lastSpace.mas_trailing);
        }];
        
        [space mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(obj.mas_trailing);
            make.centerY.equalTo(obj.mas_centerY);
            make.width.equalTo(v0);
        }];
        
        lastSpace = space;
    }
    
    [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing);
    }];
    
}

- (void) distributeSpacingVerticallyWith:(NSArray*)views
{
    NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
    
    for ( int i = 0 ; i < views.count+1 ; ++i )
    {
        UIView *v = [UIView new];
        [spaces addObject:v];
        [self addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(v.mas_height);
        }];
    }
    
    
    UIView *v0 = spaces[0];
    
    [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.centerX.equalTo(((UIView*)views[0]).mas_centerX);
    }];
    
    UIView *lastSpace = v0;
    for ( int i = 0 ; i < views.count; ++i )
    {
        UIView *obj = views[i];
        UIView *space = spaces[i+1];
        
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastSpace.mas_bottom);
        }];
        
        [space mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(obj.mas_bottom);
            make.centerX.equalTo(obj.mas_centerX);
            make.height.equalTo(v0);
        }];
        
        lastSpace = space;
    }
    
    [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
    }];
    
}

- (void)showDebugUI
{
#if DEBUG
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 0.5;
#else
#endif
}

- (void)showCurrentViewBorder:(CGFloat)borderWidth color:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(YSOscillatoryAnimationType)type
{
    NSNumber *animationScale1 = type == YSOscillatoryAnimationToBigger ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == YSOscillatoryAnimationToBigger ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

- (UIView*)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse
{
    for( UIView* subview in self.subviews ) {
        BOOL stop = NO;
        if( recurse( subview, &stop ) ) {
            return [subview findViewRecursively:recurse];
        } else if( stop ) {
            return subview;
        }
    }
    
    return nil;
}

/**
 * 如果是阿语则左右镜像翻转
 */
- (void)convertUIWithARLanguage {
    if ([SystemConfigUtils isRightToLeftShow]) {//镜像翻转
        if ([self isKindOfClass:[UIButton class]]) {
            UIImageView *imageView = ((UIButton *)self).imageView;
            if (imageView) {
                imageView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        } else {
            self.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
}

/**
 * 如果是阿语则文本改变文本方向
 */
- (void)convertTextAlignmentWithARLanguage {
    if ([self isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self;
        label.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        
    } else if ([self isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self;
        textField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
}

#pragma mark - UIView (Gesture) ==================================================

@dynamic tapGesture;

- (void)addTapGestureWithComplete:(UIViewGestureComplete)complete {
    NSParameterAssert(complete);
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    objc_setAssociatedObject(self, @selector(tapGesture), tapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(tapGestureComplete), complete, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - gesture method
- (void)tapClick{
    self.tapGestureComplete(self);
}

#pragma mark - property get
- (nullable UITapGestureRecognizer *)tapGesture {
    return objc_getAssociatedObject(self,_cmd);
}

- (UIViewGestureComplete)tapGestureComplete {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - UIView (ZFCorner) ==================================================

- (void)zfAddCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii {
    if (self) {
        
        //绘制圆角 要设置的圆角 使用“|”来组合
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
}


#pragma mark - UIView (Subviews) ==================================================


- (UIView*)subViewWithTag:(int)tag {
    for (UIView *v in self.subviews) {
        if (v.tag == tag) {
            return v;
        }
    }
    return nil;
}

/**
 给当前视图添加线条
 
 @param position 添加的位置
 @param lineWidth 天条宽度或高度
 @return 添加的线条
 */
-(instancetype)addLineToPosition:(ZFDrawLinePosition)position
                       lineWidth:(CGFloat)lineWidth
{
    UIView *line = [[UIView alloc] init];
    switch (position) {
        case ZFDrawLine_top:
        {
            line.frame = CGRectMake(0, 0, self.frame.size.width, lineWidth);
        }
        break;
        case ZFDrawLine_left:
        {
            line.frame = CGRectMake(0, 0, lineWidth, self.frame.size.height);
        }
        break;
        case ZFDrawLine_bottom:
        {
            line.frame = CGRectMake(0, self.frame.size.height-lineWidth, self.frame.size.width, lineWidth);
        }
        break;
        case ZFDrawLine_right:
        {
            line.frame = CGRectMake(self.frame.size.width-lineWidth, 0, lineWidth, self.frame.size.height);
        }
        break;
        default:
        break;
    }
    line.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self addSubview:line];
    return line;
}

/**
 * 给指定view顶部添加细线
 */
- (void)addDropShadowWithOffset:(CGSize)offset
                         radius:(CGFloat)radius
                          color:(UIColor *)color
                        opacity:(CGFloat)opacity {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    self.clipsToBounds = NO;
}

/**
 * 因为首次安装进来加载缓存时,没有缓存,因此有缓存的页面需要先加一个loadingView
 */
+ (UIActivityIndicatorView *)zfLoadingView
{
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingView.hidesWhenStopped = YES;
    loadingView.color = [UIColor grayColor];
    [loadingView startAnimating];
    return loadingView;
}

- (CAKeyframeAnimation *)zfAnimationLikeShakeTimes:(NSInteger)count {
    //step1:创建关键帧动画对象
    CAKeyframeAnimation *shakeAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    //step2:设置动画属性
    //让动画先左旋转-M_PI_4 / 5，再右旋转同样的度数，再左旋转。这样就动起来了
    shakeAni.values = @[@(-M_PI_4 / 5),@(M_PI_4 / 5),@(-M_PI_4 / 5)];
    
    shakeAni.duration = 0.25;
    //设置动画重复次数
    shakeAni.repeatCount = count>0 ? count : 1;
    return shakeAni;
}

- (CAKeyframeAnimation *)zfAnimationFavouriteScale {
    return [self zfAnimationFavouriteScaleMax:1.5];
}

- (CAKeyframeAnimation *)zfAnimationFavouriteScaleMax:(CGFloat)max {
    
    //FIXME: occ Bug 1101
    CGFloat a = self.transform.a;
    CGFloat b = self.transform.b;
    CGFloat c = self.transform.c;
    CGFloat d = self.transform.d;
    CGFloat tx = self.transform.tx;
    CGFloat ty = self.transform.ty;
    
    YWLog(@"----kkkkkkkk a:%f b:%f c:%f d:%f tx:%f ty:%f",a,b,c,d,tx,ty);
    
    CGFloat resultAD = 1;
    if (a > 0 || a < 0) {
        resultAD *= a;
    }
    if (b > 0 || b < 0) {
        resultAD *= b;
    }
    if (c > 0 || c < 0) {
        resultAD *= c;
    }
    if (d > 0 || d < 0) {
        resultAD *= d;
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(resultAD*0.1), @(resultAD*1.0), @(resultAD*max)];
    animation.keyTimes = @[@(0.0), @(0.5), @(0.8), @(1.0)];
    animation.calculationMode = kCAAnimationLinear;
    
    return animation;
}

+ (void)removeViewTagFromWindow:(NSInteger)viewTag {
    UIView *tagView = [WINDOW viewWithTag:viewTag];
    if (tagView) {
        [tagView removeFromSuperview];
    }
}

+ (UIColor *)bm_colorGradientChangeWithSize:(CGSize)size
                                     direction:(IHGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                      endColor:(UIColor *)endColor {
    
    if (CGSizeEqualToSize(size, CGSizeZero) || !startcolor || !endColor) {
        return nil;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGPoint startPoint = CGPointZero;
    if (direction == IHGradientChangeDirectionDownDiagonalLine) {
        startPoint = CGPointMake(0.0, 1.0);
    }
    gradientLayer.startPoint = startPoint;
    
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case IHGradientChangeDirectionLevel:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        case IHGradientChangeDirectionVertical:
            endPoint = CGPointMake(0.0, 1.0);
            break;
        case IHGradientChangeDirectionUpwardDiagonalLine:
            endPoint = CGPointMake(1.0, 1.0);
            break;
        case IHGradientChangeDirectionDownDiagonalLine:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        default:
            break;
    }
    gradientLayer.endPoint = endPoint;
    
    gradientLayer.colors = @[(__bridge id)startcolor.CGColor, (__bridge id)endColor.CGColor];
    UIGraphicsBeginImageContext(size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:image];
}
@end
