//
//  BaseViewModel.h
//  Yoshop
//
//  Created by YW on 16/5/25.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^EmptyOperationBlock)(void);     // 空页面点击的普通操作
typedef void (^EmptyJumpOperationBlock)(void); // 空页面跳转的点击

//等待的空白页面
typedef NS_ENUM(NSUInteger,LoadingViewShowType) {
    LoadingViewIsShow  = 0,
    LoadingViewNoDataType = 1,
    LoadingViewNoNetType = 2
};

//空页面的类型
typedef NS_ENUM(NSUInteger, EmptyViewShowType){
    EmptyViewHideType = 0,
    EmptyShowNoDataType = 1,
    EmptyShowNoNetType = 2
};

@class SYBaseRequest;

@interface BaseViewModel : NSObject

@property (nonatomic, assign) LoadingViewShowType  loadingViewShowType;
@property (nonatomic, assign) EmptyViewShowType emptyViewShowType;
@property (nonatomic, copy)   EmptyOperationBlock emptyOperationBlock;
@property (nonatomic, copy)   EmptyJumpOperationBlock emptyJumpOperationBlock;
@property (nonatomic, weak)   UIViewController *controller;

/**
 *  该方法为页面请求数据，继承BaseViewModel的类要根据自己的需要重写该方法
 *
 *  @param parmaters             网络请求参数
 *  @param completionExcuteBlock 请求完成后所要执行的操作，如：重新页面等
 */
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
/**
 *  数据解析方法，后期要提取通用，如果特殊再重写该方法
 *
 *  @param json    网络请求返回的数据-以JSON格式为主
 *  @param request 发送请求的API
 *
 *  @return 返回所需要的类型可以是字典，model，数组。。。。
 */
- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request;

// 空页面的普通操作
- (void)emptyOperationTouch;
// 空页面跳转的点击
- (void)emptyJumpOperationTouch;

/**
 *  设置NO DATA 的View
 *
 *  @param view     所在的View
 *  @param imgName  图片名字
 *  @param title    文字
 *  @param name     Button名字
 *  @param btnBlock Button事件
 */
- (void)showNoDataInView:(UIView *)view imageView:(NSString *)imgName titleLabel:(NSString *)title button:(NSString *)name buttonBlock:(void (^)(void))btnBlock;

/**
 *  设置空
 *
 *  @param view     所在的view
 *  @param btnBlock Button事件
 */
- (void)showNoNetworkViewInView:(UIView *)view buttonBlock:(void (^)(void))btnBlock;


@end
