//
//  ZFVideoLiveCommentUtils.h
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWCFunctionTool.h"
#import "NSStringUtils.h"

#import "ZFZegoMessageInfo.h"
#import "ZFZegoSettings.h"

static NSString *const kVideoLiveAddMessageNotification            = @"kVideoLiveAddMessageNotification";

static NSString *const kVideoLiveOrderPayCartNotification            = @"kVideoLiveOrderPayCartNotification";

static NSString *const kVideoLiveLikeNotification                  = @"kVideoLiveLikeNotification";
static NSString *const kVideoLiveCommentInputTextNotification      = @"kVideoLiveCommentInputTextNotification";
static NSString *const kVideoLiveCommentSendTextNotification       = @"kVideoLiveCommentSendTextNotification";
static NSString *const kVideoLiveOnlineCountNotification       = @"kVideoLiveOnlineCountNotification";



NS_ASSUME_NONNULL_BEGIN

@interface ZFVideoLiveCommentUtils : NSObject

+ (instancetype)sharedInstance;


@property (nonatomic, strong) NSMutableArray                             *historyMessageList;

/** 直播评论消息*/
@property (nonatomic, strong) NSMutableArray                             *liveMessageList;

/** 顶部动态滚动消息集合*/
@property (nonatomic, strong) NSMutableArray<ZFZegoMessageInfo*>         *topShowMessageList;
/** 顶部动态滚动消息显示序号*/
@property (nonatomic, assign) NSInteger                                  topShowIndex;
/** 顶部动态滚动消息动画中*/
@property (nonatomic, assign) BOOL                                       isTopMessageMoving;

/** 点赞数*/
@property (nonatomic, assign) NSInteger                                  likeNums;
/** 在线人数*/
@property (nonatomic, assign) int                                        onlineNums;
/** 评论输入内容*/
@property (nonatomic, copy) NSString                                     *inputText;
/** 直播房间id*/
@property (nonatomic, copy) NSString                                     *roomId;

/** 直播详情id*/
@property (nonatomic, copy) NSString                                     *liveDetailID;
/** 是否在请求历史评论中*/
@property (nonatomic, assign) BOOL                                       isLoadingRequest;

/** 1待直播 2直播中 3已结束*/
@property (nonatomic, copy) NSString                                     *liveType;
/** 是否登录房间*/
@property (nonatomic, assign) BOOL                                       isLoginRoom;
/** 直播链接中*/
@property (nonatomic, assign) BOOL                                       isLiveConnecting;

@property (nonatomic, copy) NSString                                     *nickName;




+ (NSString *)formatNumberStr:(NSString *)string;

+ (NSString *)handleUserName:(NSString *)string;

/** 添加消息到数据源*/
- (void)addMessage:(ZFZegoMessageInfo *)messageInfo;
/**点赞动画*/
- (void)refreshLikeNumsAnimate:(BOOL)animated;
/** 刷新评论*/
- (void)refreshCommentNotif:(NSObject *)messageInfo;
/** 消息输入成功*/
- (void)refreshInputTextNotif;
/** 发送消息成功*/
- (void)sendCommentSuccessNotif;
/** 发送在线人数*/
- (void)sendOnlineCountNotif:(int)onlineCount;

- (void)refreshOrderPayCartNotif:(NSObject *)messageInfo;

- (void)removeAllMessages;




@property (nonatomic, assign) NSInteger testPlayFail;

@end

NS_ASSUME_NONNULL_END
