//
//  BaseViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EmptyOperationBlock)(); // 空页面点击的普通操作
typedef void (^EmptyJumpOperationBlock)(); // 空页面跳转的点击

@class OSSVBasesRequests;

//typedef void (^CompletionExcuteBlock)(id obj);
@interface BaseViewModel : NSObject

@property (nonatomic, strong) EmptyCustomViewManager                    *emptyViewManager;
@property (nonatomic, assign) EmptyViewShowType                         emptyViewShowType;
@property (nonatomic, copy) EmptyOperationBlock                         emptyOperationBlock;
@property (nonatomic, copy) EmptyJumpOperationBlock                     emptyJumpOperationBlock;
@property (nonatomic, strong, readonly) NSMutableArray<OSSVBasesRequests *> *queueList;

///已经获取的缓存（需要自己赋值）
@property (nonatomic, strong) id                                        hadGetCacheJSONObject;

- (void)baseViewChangePV:(id)params first:(BOOL)isFirst;

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
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request;
/**
 *  提示信息
 *
 *  @param info 提示信息
 */
- (void)alertMessage:(NSString *)info;


// 空页面的普通操作
- (void)emptyOperationTouch;
// 空页面跳转的点击
- (void)emptyJumpOperationTouch;

- (void)freesource;

@end
