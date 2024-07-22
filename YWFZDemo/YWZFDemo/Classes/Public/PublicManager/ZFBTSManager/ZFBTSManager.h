//
//  ZFBTSManager.h
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//
//  用于大数据平台BTS分流的获取

#import <Foundation/Foundation.h>
#import "ZFBTSModel.h"

/// 实验版本标识(对应plancode)
static NSString * const kZFBts_A                    = @"A";
static NSString * const kZFBts_B                    = @"B";
static NSString * const kZFBts_C                    = @"C";

/// A版本：原始版本 B版本：商品首图片替换显示博主图  C版本：商品所有图片替换为博主图
static NSString * const kZFBtsProductPhoto          = @"iosproductphoto";

/// 类页或搜索页时，便进入实验 A 原始版本 B 新版本
//V5.7.0:@产品说不请求保留默认版本 (但是要保留代码)
static NSString * const kZFBtsIOSListfilter         = @"ioslistfilter";

///APP商详页优化: 原始版本A:啥都不动
static NSString * const kZFBtsIosxaddbag            = @"iosxaddbag";

///APP商详页物流时效显示 (包括订单确认页)
static NSString * const kZFBtsIosdeliverytime       = @"iosdeliverytime";





@interface ZFBTSManager : NSObject


/// App生命周期内是否已经请求保存过
+ (ZFBTSModel *)containsBtsForKey:(NSString *)plancode;

+ (ZFBTSModel *)getBtsModel:(NSString *)plancode defaultPolicy:(NSString *)defaultPolicy;

+ (NSString *)getBtsPolicyWithCode:(NSString *)plancode defaultPolicy:(NSString *)defaultPolicy;

/**
 * 清除Bts数据
 * @param plancodArray 支持清除指定plancode的bts,传空清除所有
 */
+ (void)clearBTSWithPlancodeArray:(NSArray<NSString *> *)plancodArray;

/**
 *  异步从网络获取BTS单个实验数据
 *  @params defaultValue 默认值
 *  @params timeoutInterval 接口超时时间
 *  @params completionHandler 回调函数，主线程回调
 */
+ (NSURLSessionDataTask *)asynGetBtsModel:(NSString *)plancode
                            defaultPolicy:(NSString *)defaultPolicy
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                        completionHandler:(void (^)(ZFBTSModel *model, NSError *error))completionHandler;

/**
 *  异步从网络获取BTS一组实验数据(数组方式)
 *  @params  plancodeInfo: @{Plancode: DefaultPolicy}
 *  @params timeoutInterval 接口超时时间
 *  @params completionHandler 回调函数，主线程回调
 */
+ (NSURLSessionDataTask *)requestBtsModelList:(NSDictionary *)plancodeInfo
                              timeoutInterval:(NSTimeInterval)timeoutInterval
                            completionHandler:(void (^)(NSArray <ZFBTSModel *> *modelArray, NSError *error))completionHandler;

@end
