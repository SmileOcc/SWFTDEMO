//
//  ZFCommonRequestManager.h
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MyOrdersModel;
@class ZFRequestModel;
@class ZFBTSModel;

typedef enum : NSUInteger {
    ZFCMSAppAdvertsType_AppLaunching,
    ZFCMSAppAdvertsType_HomeBigFloating,
    ZFCMSAppAdvertsType_HomeSmallFloating,
    ZFCMSAppAdvertsType_CategoryPage,
    ZFCMSAppAdvertsType_UserCenter,
    ZFCMSAppAdvertsType_PaySuccess,
    ZFCMSAppAdvertsType_OrderDetail,
} ZFCMSAppAdvertsType; //所有CMS广告类型


/**
 * 把常用的接口请求放在当前类中统一处理, 同一接口不要到页面上写多个
 */
@interface ZFCommonRequestManager : NSObject



/**
 用于请求延时随机时间

 @param maxMillisecond 毫秒
 @return 返回 秒
 */
+ (CGFloat)randomSecondsForMaxMillisecond:(NSInteger)maxMillisecond;

/**
 * 请求汇率接口
 */
+ (void)requestExchangeData:(void(^)(BOOL success))completeHandler;

/**
 * 请求是否需要清除缓存数据
 */
+ (void)requestiSNeedCleanAppData;

/**
 * 清除所有的YYCache缓存
 */
+ (void)cleanAppNetWorkCahceData;

/**
 * 启动时异步请求必要接口数据
 */
+ (void)requestNecessaryData;

/**
 * 请求cod接口
 */
+ (void)requestCurrencyData;

/**
 * 放在首页请求其他接口
 * cod,广告启动图,app Icon
 */
+ (void)asyncRequestOtherApi;

/**
 * 用户信息定位接口
 */
+ (void)requestLocationInfo;

/**
 * 请求基础信息接口
 */
+ (void)requestInitializeData:(void(^)(BOOL success))completeHandler;

/**
 * 检查App版本更新
 */
+ (void)checkUpgradeZFApp:(void(^)(BOOL hasNoNewVersion))finishBlock;

/**
 * 换肤接口
 */
+ (void)requestZFSkin;

/**
 * 获取当前国家
 */
//+ (void)requestCountryName:(void (^)(NSDictionary *countryInfoDic))completion;

/**
 * 请求推荐搜索词
 */
+ (void)requestHotSearchKeyword:(NSString *)catId completion:(void (^)(NSArray *array))completion;

/**
 * 保存FCM推送的信息到leancloud
 */
+(void)saveFCMUserInfo:(NSString *)paid_order_number
             pushPower:(BOOL)pushPower
              fcmToken:(NSString *)fcmToken;

/**
 * 同步点击远程推送的信息给服务端
 */
+(void)syncClickRemotePushWithPid:(NSString *)pid
                          cString:(NSString *)cString
                           pushId:(NSString *)pushId;

/**
 * 首次登陆请求谷歌 S2S API
 */
    
+ (void)firstOpenPOSTGoogleApi;
/*
 * 请求 主页提示有未支付订单接口
 */
+ (void)requestHasNoPayOrderTodo:(void (^)(MyOrdersModel *orderModel))completion
                       failBlcok:(void(^)(NSError *error))failBlcok
                          target:(id)target;

/**
 * 在主页上展示未支付订单提示弹框
 */
+ (void)showUnpaidOrderViewToHomeVC:(MyOrdersModel *)orderModel;


/**
 下单成功时，保存订单时间

 @param orderId 订单号
 */
+ (void)savePlaceOrderUnpaidMark:(NSString *)orderId;

/**
 * 查看订单详情
 */
+ (void)gotoOrderDetail:(MyOrdersModel *)orderModel orderReloadBlock:(void (^)(void))orderReloadBlock;

/**
 * 首页未支付订单弹框点击 -> 去支付 (有做首页统计)
 */
+ (void)gotoPayOrderInfo:(MyOrdersModel *)orderModel;

/**
* 去支付 (纯支付入口,没有做任何统计)
*/
+ (void)dealWithGotoPayWithOrderModel:(MyOrdersModel *)orderModel;

/**
 * 展示未支付订单提示弹框
 */
+ (void)requestUnpaidOrderDate;

///是否新用户接口
+ (void)requestIsNewUser;

/**
 * 所有的CMS广告数据接口
 */
+ (void)requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType)advertsType
                             otherId:(NSString *)other
                          completion:(void (^)(NSDictionary *responseObject))completion
                              target:(id)target;

/**
 * 获取CMS请求模型
 */
+ (ZFRequestModel *)gainCmsRequestModelWithTpye:(ZFCMSAppAdvertsType)advertsType
                                        otherId:(NSString *)other
                                         target:(id)target;

/**
 *  获取登录用户的oxxo和bolote的支付成功订单并补齐统计
 */
+ (void)requestUserOfflinePaySuccessOrder;

/** 商图片AB样式展示
 *  A版本：原始版本
 *  B版本：商品首图片替换显示博主图
 *  C版本：商品所有图片替换为博主图
 */
+ (void)requestProductPhotoBts:(void (^)(ZFBTSModel *))completionHandler;


@end
