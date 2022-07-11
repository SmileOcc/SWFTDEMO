//
//  OSSVAdvsEventsManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVHotsSearchWordsModel.h"
#import "OSSVAccounteMyeOrdersListeModel.h"


@class OSSVAdvsEventsModel;

@interface OSSVAdvsEventsManager : NSObject

+(OSSVAdvsEventsManager*)sharedManager;
@property (nonatomic,strong) OSSVAdvsEventsModel *advEventModel;   // APP启动广告图数据


+ (void)advEventTarget:(id)target withEventModel:(OSSVAdvsEventsModel *)advEventModel;

+(void)advEventOrderListWithPaymentStutas:(STLOrderPayStatus)status;
+(void)advEventOrderListWithPaymentStutas:(STLOrderPayStatus)status OSSVAddresseBookeModel:(OSSVAccounteMyeOrdersListeModel *)orderAddress;

+ (UIViewController *)gainTopViewController;

+ (void)goHomeModule;

/**
 * 根据url解析Deeplink参数
 */
+ (NSMutableDictionary *)parseDeeplinkParamDicWithURL:(NSURL *)url;

/**
 * Deeplink数据源解析
 */
+ (void)jumpDeeplinkTarget:(id)target deeplinkParam:(NSDictionary *)paramDict;

/**
 * 保存推送信息
 */
+ (void)saveNotificationsPaymentParmaters:(NSDictionary *)userInfo;

/**
 * 保存广告推广信息
 */
+ (void)saveOneLinkeParams:(NSDictionary *)paramDict;


+ (NSString *)adv_utm_source;

+ (NSString *)adv_utm_medium;

+ (NSString *)adv_utm_campaign;

+ (NSString *)adv_utm_date;

+(NSString *)adv_shared_uid;

@end
