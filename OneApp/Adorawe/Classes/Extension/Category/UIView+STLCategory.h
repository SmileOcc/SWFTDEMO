//
//  UIView+STLCategory.h
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UIViewGestureComplete)(UIView *view);

typedef enum : NSUInteger {
    STLDrawLine_top,
    STLDrawLine_left,
    STLDrawLine_bottom,
    STLDrawLine_right,
} STLDrawLinePosition;

@interface UIView (STLCategory)


//获取导航控制器
- (UINavigationController * )navigationController;
//获取标签控制器
- (UITabBarController * )tabBarController;
//获取控制器
- (UIViewController * )viewController;
//获取主窗口
- (UIWindow * )rootWindow;


//获取cell
- (UITableViewCell * )viewTableViewCell;
- (UICollectionViewCell * )viewCollectionViewCell;

- (UICollectionView *)parentCollectionView;
- (UITableView *)parentTableView;

// 判断View是否显示在屏幕上
- (BOOL)isDisplayedInScreen;

#pragma mark - UIView (方向) ==================================================


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


#pragma mark - UIView (STLCorner) ==================================================

/*  设置各边框圆角
 *
 *  @param corners 对应角：UIRectCornerTopLeft | UIRectCornerTopRight
 *  @param cornerRadii 大小
 */
- (void)stlAddCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;


#pragma mark - UIView (Subviews) ==================================================


//动画左右摇摆
- (CAKeyframeAnimation *)stlAnimationLikeShakeTimes:(NSInteger)count;
//缩放动画
- (CAKeyframeAnimation *)stlAnimationFavouriteScale;
//缩放动画 max：结束最大值
- (CAKeyframeAnimation *)stlAnimationFavouriteScaleMax:(CGFloat)max;


#pragma mark - UIView (坐标) ==================================================

// coordinator getters
- (CGFloat)height;
- (CGFloat)width;
- (CGFloat)x;
- (CGFloat)y;
- (CGSize)size;
- (CGPoint)origin;
- (CGFloat)centerX;
- (CGFloat)centerY;

- (CGFloat)left;
- (CGFloat)top;
- (CGFloat)bottom;
- (CGFloat)right;

- (void)setX:(CGFloat)x;
- (void)setLeft:(CGFloat)left;
- (void)setY:(CGFloat)y;
- (void)setTop:(CGFloat)top;
- (void)setBottom:(CGFloat)bottom;

// height
- (void)setHeight:(CGFloat)height;

// width
- (void)setWidth:(CGFloat)width;

// size
- (void)setSize:(CGSize)size;

// center
- (void)setCenterX:(CGFloat)centerX;
- (void)setCenterY:(CGFloat)centerY;


@end

NS_ASSUME_NONNULL_END
