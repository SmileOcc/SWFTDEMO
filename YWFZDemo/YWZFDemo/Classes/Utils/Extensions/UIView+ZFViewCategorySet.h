//
//  UIView+ZFViewCategorySet.h
//  ZZZZZ
//
//  Created by YW on 2018/12/3.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  ZZZZZ UIView 分类合集，因为多个分类文件对App启动时间有一点点影响，所以，把项目中全部视图分类继承到一起

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    YSOscillatoryAnimationToBigger,
    YSOscillatoryAnimationToSmaller,
} YSOscillatoryAnimationType;

typedef void(^UIViewGestureComplete)(UIView *view);

typedef enum : NSUInteger {
    ZFDrawLine_top,
    ZFDrawLine_left,
    ZFDrawLine_bottom,
    ZFDrawLine_right,
} ZFDrawLinePosition;

/**
 渐变方式
 
 - IHGradientChangeDirectionLevel:              水平渐变
 - IHGradientChangeDirectionVertical:           竖直渐变
 - IHGradientChangeDirectionUpwardDiagonalLine: 向下对角线渐变
 - IHGradientChangeDirectionDownDiagonalLine:   向上对角线渐变
 */
typedef NS_ENUM(NSInteger, IHGradientChangeDirection) {
    IHGradientChangeDirectionLevel,
    IHGradientChangeDirectionVertical,
    IHGradientChangeDirectionUpwardDiagonalLine,
    IHGradientChangeDirectionDownDiagonalLine,
};


@interface UIView (ZFViewCategorySet)

#pragma mark - UIView (Responder) ==================================================

//获取导航控制器
- (UINavigationController * )navigationController;
//获取标签控制器
- (UITabBarController * )tabBarController;
//获取控制器
- (UIViewController * )viewController;
//获取主窗口
- (UIWindow * )rootWindow;

#pragma mark - UIView (AutoLayoutSpace) ==================================================

/*!
 *  @brief Masonry并没有直接提供等间隙排列的方法，水平方向的等间隙排列 注意是由父视图调用！
 *
 *  @param views 需要等间隙排列的视图集合
 */
- (void) distributeSpacingHorizontallyWith:(NSArray*)views;

/*!
 *  @brief Masonry并没有直接提供等间隙排列的方法，垂直方向的等间隙排列 注意是由父视图调用！
 *
 *  @param views 需要等间隙排列的视图集合
 */
- (void) distributeSpacingVerticallyWith:(NSArray*)views;


/*!
 *  @brief 显示当前视图的边框，用于UI调试
 *
 *  @param borderWidth 边框宽度
 *  @param borderColor 边框颜色
 */
- (void)showCurrentViewBorder:(CGFloat)borderWidth color:(UIColor *)borderColor;

/*!
 *  @brief 显示UI 默认红色
 */
- (void)showDebugUI;

/*!
 *  @brief 提醒数字动弹效果
 *
 *  @param layer 需要做动画的视图 layer
 *  @param type  动画类型
 */
+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(YSOscillatoryAnimationType)type;

- (UIView*)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop))recurse;

/**
 * 如果是阿语则左右翻转180度
 */
- (void)convertUIWithARLanguage;

/**
 * 如果是阿语则文本改变文本方向
 */
- (void)convertTextAlignmentWithARLanguage;

#pragma mark - UIView (Gesture) ==================================================

@property (nonatomic, strong, readonly,nullable) UITapGestureRecognizer *tapGesture;

- (void)addTapGestureWithComplete:(UIViewGestureComplete)complete;


#pragma mark - UIView (ZFCorner) ==================================================

/*  设置各边框圆角
 *
 *  @param corners 对应角：UIRectCornerTopLeft | UIRectCornerTopRight
 *  @param cornerRadii 大小
 */
- (void)zfAddCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;


#pragma mark - UIView (Subviews) ==================================================


- (UIView*)subViewWithTag:(int)tag;

/**
 给当前视图添加线条
 
 @param position 添加的位置
 @param lineWidth 天条宽度或高度
 @return 添加的线条
 */
-(instancetype)addLineToPosition:(ZFDrawLinePosition)position
                       lineWidth:(CGFloat)lineWidth;

/**
 * 给指定view顶部添加细线
 */
- (void)addDropShadowWithOffset:(CGSize)offset
                         radius:(CGFloat)radius
                          color:(UIColor *)color
                        opacity:(CGFloat)opacity;

/**
 * 因为首次安装进来加载缓存时,没有缓存,因此有缓存的页面需要先加一个loadingView
 */
+ (UIActivityIndicatorView *)zfLoadingView;

//动画左右摇摆
- (CAKeyframeAnimation *)zfAnimationLikeShakeTimes:(NSInteger)count;
//缩放动画
- (CAKeyframeAnimation *)zfAnimationFavouriteScale;
//缩放动画 max：结束最大值
- (CAKeyframeAnimation *)zfAnimationFavouriteScaleMax:(CGFloat)max;

+ (void)removeViewTagFromWindow:(NSInteger)viewTag;

+ (UIColor *)bm_colorGradientChangeWithSize:(CGSize)size
                                     direction:(IHGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                   endColor:(UIColor *)endColor;
@end

NS_ASSUME_NONNULL_END
