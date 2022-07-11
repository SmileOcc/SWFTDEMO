//
//  YXSocketSingleton.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/5.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXSocketTopic.h"
#import "YXTimerSingleton.h"
#import "YXKitMacro.h"
#import "YXSocketConfig.h"
#import "proto.h"

typedef YXTimerFlag YXSocketSeqFlag;

#define kYXSocketReconnectNotification  @"kYXSocketReconnectNotification"
#define kYXSocketConnectNotification  @"kYXSocketConnectNotification"
#define kYXSocketLogoutNotification  @"kYXSocketLogoutNotification"
#define kYXSocketSmartNotification  @"kYXSocketSmartNotification"
#define kYXSocketQuoteLevelChangeNotification  @"kYXSocketQuoteLevelChangeNotification"
#define kYXSocketTradeAccountChangeNotification  @"kYXSocketTradeAccountChangeNotification"
#define kYXSocketTodayOrderChangeNotification  @"kYXSocketTodayOrderChangeNotification"

NS_ASSUME_NONNULL_BEGIN

@interface  YXSocketPushModel: NSObject

@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSDictionary *data;

@end

@protocol YXSocketReceiveDataProtocol <NSObject>

@optional

//分时
- (void)socketDidReceiveTSPush:(YXSocketPushModel *)pushModel;
//逐笔
- (void)socketDidReceiveTKPush:(YXSocketPushModel *)pushModel;
//实时(表盘参数, 买卖十档)
- (void)socketDidReceiveRTPush:(YXSocketPushModel *)pushModel scene:(OBJECT_QUOTEQuoteScene)scene;
//Kline
- (void)socketDidReceiveKLPush:(YXSocketPushModel *)pushModel type:(OBJECT_QUOTEKLineType)kLineType direction:(OBJECT_QUOTEKLineDirection)direction;

- (void)socketDidReceiveClientPush:(API_CLIENTPush *)clientPush;

@end

typedef void (^ServiceNode)(void(^complete)(NSURL * _Nullable url));
typedef void (^MessageBlock)(NSDictionary *dict);

@interface YXSocketSingleton : NSObject

@property (nonatomic, assign) uint64_t uuid;
@property (nonatomic, copy) NSString * _Nonnull deviceId;
@property (nonatomic, copy) NSString * _Nullable accessToken;
@property (nonatomic, copy) NSArray<NSURL *> * _Nonnull urls;
@property (nonatomic, assign) YXSocketAppType appType;
@property (nonatomic, assign) YXSocketLangType langType;

@property (nonatomic, assign) BOOL needReconnect;
@property (nonatomic, assign, readonly) BOOL connecting;

@property (nonatomic, copy) MessageBlock messageBlock;

+ (instancetype)shareInstance;

/**
 Socket连接
 */
- (void)socketConnectHost;


/**
 断开Socket连接
 */
- (void)cutOffSocket;


/**
 @return 是否已连接
 */
- (BOOL)isConnected;


/**
 鉴权
 */
- (void)authWithServer;

/**
 订阅

 @param topics 订阅模型数组
 @param target 订阅时所在的对象
 @return 唯一序列号, 需要保存，取消订阅时用，若count为0返回0
 */
- (YXSocketSeqFlag)subWithServer:(NSArray<YXSocketTopic *> * _Nonnull)topics target:(id<YXSocketReceiveDataProtocol> _Nonnull)target;

/**
 取消订阅
 
 @param flag 订阅时返回的唯一序列号，
 @return 唯一序列号, 可不做处理， 若订阅flag已取消，则返回0,
 */
- (YXSocketSeqFlag)unSubWithFlag:(YXSocketSeqFlag)flag;

///**
// 取消所有订阅(服务端处理)，慎用
// @return 唯一序列号
// */
//- (YXSocketSeqFlag)unAllSubWithServer;


/**
 获取服务器socket的ip和端口号
 */
- (void)getServerNode:(ServiceNode)serviceNode;

@end

NS_ASSUME_NONNULL_END
