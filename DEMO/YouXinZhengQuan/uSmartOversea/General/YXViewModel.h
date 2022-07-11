//
//  YXViewModel.h
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>


/**
 网络请求时，加载中视图所在的位置

 - YXRequestViewPositionShowInController: QMUITips显示在ViewController的View中
 - YXRequestViewPositionHideInController: 隐藏ViewController View上的QMUITips
 - YXRequestViewPositionShowInWindow: QMUITips显示在KeyWindow中
 - YXRequestViewPositionHideInWindow: 隐藏KeyWindow上的QMUITips
 */
typedef NS_ENUM(NSUInteger, YXRequestViewPosition) {
    YXRequestViewPositionShowInController,
    YXRequestViewPositionHideInController,
    YXRequestViewPositionShowInWindow,
    YXRequestViewPositionHideInWindow,
};

typedef void (^VoidBlock_id)(id);

@protocol YXViewModelServices;

@interface YXViewModel : NSObject

/**
 初始化

 @param services model服务总线
 @param params 传递的参数
 @return viewModel
 */
- (instancetype _Nonnull)initWithServices:(id<YXViewModelServices> _Nonnull)services params:(NSDictionary * _Nullable)params;


/**
 在此函数中做一些初始化操作 需要子类直接继承
 */
- (void)initialize;

@property (nonatomic, strong, readonly, nonnull) id<YXViewModelServices> services;
@property (nonatomic, copy, readonly, nullable) NSDictionary *params;


/**
 标题
 */
@property (nonatomic, copy, nullable) NSString *  title;

/**
 子标题
 */
@property (nonatomic, copy, nullable) NSString *subtitle;


@property (nonatomic, copy, nullable) VoidBlock_id block;
@property (nonatomic, copy, nullable) void (^dataCallBack)(id object);
@property (nonatomic, copy, nullable) void (^cancelCallBack)(void);

@property (nonatomic, strong, readonly, nonnull) RACSubject *errors;

/**
 当viewModel对应的vc将要消失
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *willDisappearSignal;

/**
 当viewModel对应的vc消失
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *didDisappearSignal;

/**
 当viewModel对应的vc 调用viewDidLoad
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *didLoadSignal;

/**
 当viewModel对应的vc将要出现
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *willAppearSignal;

/**
 当viewModel对应的vc出现
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *didAppearSignal;

/**
 处理网络请求的加载中对话框
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *requestShowLoadingSignal;

/**
 处理网络请求的错误对话框
 */
@property (nonatomic, strong, readonly, nonnull) RACSubject *requestShowErrorSignal;

/**
 作为requestShowLoadingSignal返回的字典中的Key
 例如dictionary[loadingViewPositionKey] = @(YXRequestViewPositionShowInController),则显示在viewController中
 参见@see <YXRequestViewPosition>
 
 @return key
 */
+ (NSString * _Nonnull )loadingViewPositionKey;

/**
 作为requestShowLoadingSignal返回的字典中的Key
 例如dictionary[loadingMessageKey] = @"网络加载中",则显示在viewController中的Loading会显示这句话

 @return key
 */
+ (NSString * _Nonnull)loadingMessageKey;


/**
 作为requestShowErrorSignal默认的errorDomain

 @return errorDomain
 */
+ (NSErrorDomain _Nonnull)defaultErrorDomain;

@property (nonatomic, assign) BOOL shouldFetchLocalDataOnViewModelInitialize;
@property (nonatomic, assign) BOOL shouldRequestRemoteDataOnViewDidLoad;


@end
