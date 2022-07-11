//
//  UIViewController+STLCategory.h
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^LeftBarItemBlock)();
typedef void(^RightBarItemBlock)();


@interface UIViewController (STLCategory)

@property (nonatomic,copy) LeftBarItemBlock  leftBarItemBlock;
@property (nonatomic,copy) RightBarItemBlock rightBarItemBlock;

/**
 * 切换语言后切换系统UI布局方式
 */
+ (void)convertAppUILayoutDirection;


/**
 *  获取App最顶层的控制器
 */
+ (UIViewController *)currentTopViewController;

/**
 *  获取App最顶层的控制器
 */
+ (UIViewController *)lastNavTopViewController;

+ (NSString *)currentTopViewControllerPageName;

//上一个页面
+ (NSString *)lastViewControllerPageName;

/**
 *  判断在导航栏控制器中有没存在该类
 *
 *  @param className 类名
 *
 *  @return 返回存在的控制器  没有存在则为nil
 */
- (UIViewController *)isExistClassInSelfNavigation:(NSString *)className;

/**
 *  页面执行push跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic  控制器需要的参数
 */
- (void)pushToViewController:(NSString *)vcName
                 propertyDic:(NSDictionary *)propertyDic;


#pragma mark - (Navigation)


/**
 *  @brief 设置全局默认导航栏返回键
 */
- (void)setNavagationBarDefaultBackButton;

/**
 *  @brief 根据UI设计设置导航栏返回键
 *
 *  @param image 返回键
 */
- (void)setNavagationBarBackBtnWithImage:(UIImage *)image;

/**
 *  @brief 设置导航栏右键
 *
 *  @param image 右键图片
 */
- (void)setNavagationBarRightButtonWithImage:(UIImage *)image;

/**
 *  @brief 设置导航栏左键
 *
 *  @param title 左键标题
 *  @param font  文字字号
 *  @param color 文字颜色
 *  @param size  文字位置
 */
- (void)setNavagationBarLeftButtonWithTitle:(NSString *)title
                                        font:(UIFont *)font
                                      color:(UIColor *)color;


/**
 *  @brief 设置导航栏右键
 *
 *  @param title 右键标题
 *  @param font  文字字号
 *  @param color 文字颜色
 *  @param size  文字位置
 */
- (void)setNavagationBarRightButtonWithTitle:(NSString *)title
                                        font:(UIFont *)font
                                       color:(UIColor *)color;

/**
 *  @brief 设置导航栏标题
 *
 *  @param title 标题
 *  @param font  字体
 *  @param color 颜色
 */
- (void)setNavagationBarTitle:(NSString *)title
                         font:(UIFont *)font
                        color:(UIColor *)color;

/*!
 *  @brief 模态一个半透明的视图。
 *  @brief 透明度由 viewControllerToPresent 的 backgroundColor 控制
 */
- (void)presentTranslucentViewController:(UIViewController *)viewControllerToPresent
                                animated: (BOOL)flag
                              completion:(void (^)(void))completion;



@end

