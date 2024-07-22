//
//  UIViewController+ZFViewControllerCategorySet.h
//  ZZZZZ
//
//  Created by YW on 2018/12/3.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  ZZZZZ UIViewController 分类合集，因为多个分类文件对App启动时间有一点点影响，所以，把项目中全部视图分类继承到一起

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

typedef void(^LeftBarItemBlock)(void);
typedef void(^RightBarItemBlock)(void);

typedef NS_ENUM(NSInteger, YWLoginEnterType) {
    YWLoginEnterTypeLogin = 0,
    YWLoginEnterTypeRegister,
    YWLoginEnterTypeNoromal,
    YWLoginEnterTypeFacebook,
    YWLoginEnterTypeGoogle,
    YWLoginEnterTypeVKontakte
};

typedef NS_ENUM(NSInteger, YWLoginViewControllerEnterType) {
    YWLoginViewControllerEnterTypeDefaut = 0,
    YWLoginViewControllerEnterTypeGuidePage,
    YWLoginViewControllerEnterTypeCartPage,
    YWLoginViewControllerEnterTypeGoodsDetailPage,
    YWLoginViewControllerEnterTypeAccountPage,
    YWLoginViewControllerEnterTypeCommunityHomePage
};

@interface UIViewController (ZFViewControllerCategorySet)

#pragma mark - UIViewController (ZFShowEmptyVeiw) ==================================================

/**
 * 空白页垂直偏移,有些界面是隐藏导航栏的,或是有工具栏的,或是有设置偏移量的,需要进行微调,达到居中效果
 * 默认为 0
 */
@property (nonatomic, assign) CGFloat   edgeInsetTop;

/**
 * 下面两个属性是针对 有网络,接口无数据的情况
 */
@property (nonatomic, strong) UIImage   *emptyImage;
@property (nonatomic, copy) NSString    *emptyTitle;

/**
 * handler:为nil时，不显示按钮事件
 */
- (void)showEmptyViewHandler:(void (^)(void))handler;

- (void)removeEmptyView;

#pragma mark - UIViewController (NavagationBar) ==================================================

@property (nonatomic,copy) LeftBarItemBlock  leftBarItemBlock;
@property (nonatomic,copy) RightBarItemBlock rightBarItemBlock;


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

- (void)setNavagationBarRightButtonWithTitle:(NSString *)title
                                        font:(UIFont *)font
                                       color:(UIColor *)color
                                     enabled:(BOOL)enabled;

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


#pragma mark - UIViewController (ZFExtension) ==================================================

/**
 *  返回到指定控制器
 */
- (BOOL)popToSpecifyVCSuccess:(NSString *)classStr;

/**
 *  执行返回到指定控制器的上层控制器，若没有就返回到上层
 */
- (void)popUpperClassRelativeClass:(NSString *)classStr;

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
- (void)shouldShowLeftHoledSliderView:(CGFloat)height;

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
 判断是否需要, 如果需要登录则弹出登录页面
 @param loginSuccessBlock 登录成功回调
 @param cancelSuccessBlock 取消登录回调
 */
- (void)judgePresentLoginVCCompletion:(void(^)(void))loginSuccessBlock
                      cancelCompetion:(void(^)(void))cancelSuccessBlock;

/**
 *  判断是否需要, 如果需要登录则弹出登录页面
 *  @param loginSuccessBlock 登录成功回调
 *  @param type 登录页面的状态
 */
- (void)judgePresentLoginVCChooseType:(YWLoginEnterType)type
                         comeFromType:(YWLoginViewControllerEnterType)comeFromType
                           Completion:(void(^)(void))loginSuccessBlock;

/**
 * 切换语言后切换系统UI布局方式
 */
+ (void)convertAppUILayoutDirection;


#pragma mark - UIViewController (ZFAppStoreComment) ==================================================

/**
 * 跳转App store 评论App界面
 */
+ (void)showAppStoreReviewVC;

//引导用户给APP Store评论
- (void)showAppStoreCommentWithContactUs:(NSString *)contactUs;


#pragma mark - UIViewController (Touch3DProtocolForward) ==================================================

/**
 * 检测3DTouch是否可用,并且注册3DTouch事件
 */
- (void)register3DTouchAlertWithDelegate:(id)delegate
                              sourceView:(UIView *)sourceView
                              goodsModel:(ZFGoodsModel *)goodsModel;


#pragma mark - UIViewController (删除导航栈中指定的控制器) ==================================================

///删除导航栈中指定的控制器
- (void)deleteVCFromNavgation:(Class)className;

///删除导航栈中前面指定的控制器
- (void)deletePreviousVCFromNavgation:(Class)className;
@end
