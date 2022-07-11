//
//  UIView+STLCategory.m
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "UIView+STLCategory.h"

const void * KTapGesture = "KTapGesture";
const void * KTapGestureComplete = "KTapGestureComplete";

@interface UIView ()

@property (nonatomic, copy) UIViewGestureComplete tapGestureComplete;

@end

@implementation UIView (STLCategory)


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

- (UITableViewCell * )viewTableViewCell {
    if (self && [self isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)self;
    }
    UIResponder * next = [self nextResponder];
    while (next!=nil) {
        if([next isKindOfClass:[UITableViewCell class]]){
            return (UITableViewCell * )next;
        }
        next = [next nextResponder];
    }
    return nil;
}

- (UICollectionViewCell * )viewCollectionViewCell {
    if (self && [self isKindOfClass:[UICollectionViewCell class]]) {
        return (UICollectionViewCell *)self;
    }
    UIResponder * next = [self nextResponder];
    while (next!=nil) {
        if([next isKindOfClass:[UICollectionViewCell class]]){
            return (UICollectionViewCell * )next;
        }
        next = [next nextResponder];
    }
    return nil;
}

- (UICollectionView *)parentCollectionView {
    if (self == nil) {
        return nil;
    }
    if (self.superview) {
        if ([self.superview isKindOfClass:[UICollectionView class]]) {
            return (UICollectionView *)self.superview;
        } else {
            return [self.superview parentCollectionView];
        }
    } else if([self isKindOfClass:[UICollectionView class]]) {
        return (UICollectionView *)self;
    }
    return nil;
}

- (UITableView *)parentTableView {
    if (self == nil) {
        return nil;
    }
    if (self.superview) {
        if ([self.superview isKindOfClass:[UITableView class]]) {
            return (UITableView *)self.superview;
        } else {
            return [self.superview parentTableView];
        }
    } else if([self isKindOfClass:[UITableView class]]) {
        return (UITableView *)self;
    }
    return nil;
}
// 判断View是否显示在屏幕上
- (BOOL)isDisplayedInScreen
{
    if (self == nil || !self.superview || self.hidden) {
        return NO;
    }

    CGRect screenRect = [UIScreen mainScreen].bounds;

    // 转换view对应window的Rect
    UIWindow *win= [UIApplication sharedApplication].keyWindow;
//    CGRect rect = [self convertRect:self.frame toView:win];
    CGRect rect = [self.superview convertRect:self.frame toView:win];
    
    //如果可以滚动，清除偏移量
    if ([[self class] isSubclassOfClass:[UIScrollView class]]) {
        UIScrollView * scorll = (UIScrollView *)self;
        rect.origin.x += scorll.contentOffset.x;
        rect.origin.y += scorll.contentOffset.y;
    }
    
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return NO;
    }

    // 若size为CGrectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  NO;
    }

    // 获取 该view与window 交叉的 Rect
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }

    return YES;
}


#pragma mark - UIView (方向) ==================================================

/**
 * 如果是阿语则左右镜像翻转
 */
- (void)convertUIWithARLanguage {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {//镜像翻转
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
        label.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        
    } else if ([self isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self;
        textField.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
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

#pragma mark - UIView (STLCorner) ==================================================

- (void)stlAddCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii {
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

- (CAKeyframeAnimation *)stlAnimationLikeShakeTimes:(NSInteger)count {
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

- (CAKeyframeAnimation *)stlAnimationFavouriteScale {
    return [self stlAnimationFavouriteScaleMax:1.5];
}

- (CAKeyframeAnimation *)stlAnimationFavouriteScaleMax:(CGFloat)max {
    
    //FIXME: occ Bug 1101
    CGFloat a = self.transform.a;
    CGFloat b = self.transform.b;
    CGFloat c = self.transform.c;
    CGFloat d = self.transform.d;
    CGFloat tx = self.transform.tx;
    CGFloat ty = self.transform.ty;
    
    STLLog(@"----kkkkkkkk a:%f b:%f c:%f d:%f tx:%f ty:%f",a,b,c,d,tx,ty);
    
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

#pragma mark - UIView (坐标) ==================================================


// coordinator getters
- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGSize)size
{
    return self.frame.size;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (CGFloat)bottom
{
    return self.frame.size.height + self.frame.origin.y;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)right
{
    return self.frame.size.width + self.frame.origin.x;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left
{
    self.x = left;
}

- (void)setTop:(CGFloat)top
{
    self.y = top;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

// height
- (void)setHeight:(CGFloat)height
{
    CGRect newFrame = CGRectMake(self.x, self.y, self.width, height);
    self.frame = newFrame;
}

// width
- (void)setWidth:(CGFloat)width
{
    CGRect newFrame = CGRectMake(self.x, self.y, width, self.height);
    self.frame = newFrame;
}

// center
- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = CGPointMake(self.centerX, self.centerY);
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = CGPointMake(self.centerX, self.centerY);
    center.y = centerY;
    self.center = center;
}

// size
- (void)setSize:(CGSize)size
{
    self.frame = CGRectMake(self.x, self.y, size.width, size.height);
}

@end
