//
//  UIViewController+ZFExtension.h
//  IntegrationDemo
//
//  Created by mao wangxin on 2018/3/6.
//  Copyright © 2018年 mao wangxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ZFExtension)

/**
 *  返回到指定控制器
 */
- (BOOL)popToSpecifyVCSuccess:(NSString *)classStr;

/**
 *  获取App最顶层的控制器
 */
+ (UIViewController *)currentTopViewController;

/**
 *  判断在导航栏控制器中有没存在该类
 *
 *  @param className 类名
 *
 *  @return 返回存在的控制器  没有存在则为nil
 */
- (UIViewController *)isExistClassInSelfNavigation:(NSString *)className;

/**
 * 添加一个透明视图让事件传递到顶层,使其能够侧滑返回
 */
- (void)shouldShowLeftHoledSliderView;

/**
 带参数跳转到目标控制器, 如果导航栈中存在目标器则pop, 不存在则push
 
 @param vcName 目标控制器
 @param propertyDic 目标控制器属性字典
 @param selectorStr 跳转完成后需要执行的方法
 */
- (void)pushOrPopToViewController:(NSString *)vcName
                       withObject:(NSDictionary *)propertyDic
                        aSelector:(NSString *)selectorStr
                         animated:(BOOL)animated;

/**
 *  页面执行push跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic  控制器需要的参数
 */
- (void)pushToViewController:(NSString *)vcName
                 propertyDic:(NSDictionary *)propertyDic;

/**
 *  执行push页面跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic 控制器需要的参数
 *  @param animated 是否显示动画
 */
- (void)pushToViewController:(NSString *)vcName
                 propertyDic:(NSDictionary *)propertyDic
                    animated:(BOOL)animated;

/**
 *  页面执行present跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic 控制器需要的参数
 */
- (void)presentToViewController:(NSString *)vcName
                     withObject:(NSDictionary *)propertyDic
                  showTargetNav:(BOOL)showNavigation
                     completion:(void(^)(void))completionBlcok;

/**
 判断是否需要, 如果需要登录则弹出登录页面
 @param loginSuccessBlock 登录成功回调
 */
 - (void)judgePresentLoginVCCompletion:(void(^)(void))loginSuccessBlock;

/**
 *  判断是否需要, 如果需要登录则弹出登录页面
 *  @param loginSuccessBlock 登录成功回调
 *  @param type 登录页面的状态
 */
- (void)judgePresentLoginVCChooseType:(ZFLoginEnterType)type
                         comeFromType:(NSInteger)comeFromType
                           Completion:(void(^)(void))loginSuccessBlock;

/**
 * 切换语言后切换系统UI布局方式
 */
+ (void)convertAppUILayoutDirection;

@end
