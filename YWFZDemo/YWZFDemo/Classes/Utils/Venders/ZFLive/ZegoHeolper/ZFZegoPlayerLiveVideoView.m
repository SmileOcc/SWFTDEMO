//
//  ZFZegoPlayerLiveVideoView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoPlayerLiveVideoView.h"
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>
#import "UIView+ZFViewCategorySet.h"
#import "YSAlertView.h"

#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWLocalHostManager.h"

@interface ZFZegoPlayerLiveVideoView ()
<
ZegoRoomDelegate,
ZegoLivePlayerDelegate,
ZegoIMDelegate,
ZegoLiveEventDelegate,
ZFZegoMediaPlayerHelperDelegate
>

@property (strong) ZFZegoMediaPlayerHelper *mediaPlayerHelper;
@property (nonatomic, assign) BOOL isFirstStartLive;

@property (nonatomic, copy) NSString *thirdRanmdStreamID;


@end

@implementation ZFZegoPlayerLiveVideoView

- (NSMutableArray<ZegoStream *> *)streamList {
    if (!_streamList) {
        _streamList = [[NSMutableArray alloc] init];
    }
    return _streamList;
}

- (NSMutableDictionary *)viewContainersDict {
    if (!_viewContainersDict) {
        _viewContainersDict = [[NSMutableDictionary alloc] init];
    }
    return _viewContainersDict;
}


- (void)configurationLiveType:(ZegoBasePlayerType)playerType firstStart:(BOOL)firstStart isFull:(BOOL)isFull {

    self.isFull = isFull;
    self.playerType = playerType;
    self.isFirstStartLive = firstStart;
    
    // 即购直播、第三方流
    if (self.playerType == ZegoBasePlayerTypeLiving || self.playerType == ZegoBasePlayerTypeThirdStream) {
        
        // 如果是即购第三方流，如果有录播地址，就默认为录播
        if (self.playerType == ZegoBasePlayerTypeThirdStream && !ZFIsEmptyString(self.sourceVideoAddress)) {
            [self startInitPlayerHelper];
            
        } else {
            
            //直播未开始时，可以获取历史数据,如果开始时，又要隐藏
//            if (!self.isFirstStartLive) {
//                self.operateView.isZegoHistoryComment = YES;
//                if (self.inforModel) {
//                    self.operateView.inforModel = self.inforModel;
//                }
//            }
            
            [self startZegoLive];
        }
        
    } else {
        [self startInitPlayerHelper];
    }
}

- (void)startInitPlayerHelper {
    self.mediaPlayerHelper = [[ZFZegoMediaPlayerHelper alloc] initStartPublish:NO];
    self.mediaPlayerHelper.delegate = self;
    [self.mediaPlayerHelper setVolume:100];
    [self startVideoPlay];
}


#pragma mark - ZegoLiveRoom

- (void)startZegoLive {
    [self setupLiveKit];
    [self loginRoom];
//    self.operateView.progressSlider.userInteractionEnabled = NO;
//    self.operateView.progressSlider.value = self.operateView.progressSlider.maximumValue;
}

- (void)setupLiveKit {
    [[ZFZegoHelper api] setRoomDelegate:self];
    [[ZFZegoHelper api] setPlayerDelegate:self];
    [[ZFZegoHelper api] setIMDelegate:self];
    [[ZFZegoHelper api] setRoomConfig:YES userStateUpdate:YES];
}

- (void)clearAllStream {
    for (ZegoStream *info in self.streamList) {
        [[ZFZegoHelper api] stopPlayingStream:info.streamID];
    }
    BOOL logout = [[ZFZegoHelper api] logoutRoom];
    [self.viewContainersDict removeAllObjects];
    YWLog(@"---- 退出房间: %i",logout);
}

- (void)reLoginRoom {
    if (self.loginRoomSuccess) {
        YWLog(@"-----已登录房间，重新设置用户信息");

        NSString *userID = [AccountManager sharedManager].account.user_id;
        if (!ZFIsEmptyString(userID)) {
            NSString *userName = [AccountManager sharedManager].account.nickname;
            if (ZFIsEmptyString(userName)) {
                userName = @"Z USER";
            }
            [ZegoLiveRoomApi setUserID:userID userName:userName];
            
            [ZFZegoSettings sharedInstance].userID = userID;
            [ZFZegoSettings sharedInstance].userName = userName;
        }
    } else {
        YWLog(@"-----未登录房间，开始登录");
        [self loginRoom];
    }
}

- (void)loginRoom {
    
    NSString *userID = [AccountManager sharedManager].account.user_id;
    if (!ZFIsEmptyString(userID)) {
        NSString *userName = [AccountManager sharedManager].account.nickname;
        if (ZFIsEmptyString(userName)) {
            userName = @"Z USER";
        }
        [ZegoLiveRoomApi setUserID:userID userName:userName];
        
        [ZFZegoSettings sharedInstance].userID = userID;
        [ZFZegoSettings sharedInstance].userName = userName;
    }
    
    [ZFVideoLiveCommentUtils sharedInstance].nickName = [ZFZegoSettings sharedInstance].userName;
    
    YWLog(@"---- %@",[ZFZegoSettings sharedInstance].userID);
    YWLog(@"本地用户---- %@",[ZFZegoSettings sharedInstance].userName);

#ifdef DEBUG
    if (ZFIsEmptyString(self.roomID)) {
        self.roomID = @"occ";
    }
#endif
    
    [[ZFZegoHelper api] loginRoom:self.roomID role:ZEGO_AUDIENCE withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
        YWLog(@"%s, error: %d", __func__, errorCode);
        if (errorCode == 0) {
            [ZFVideoLiveCommentUtils sharedInstance].isLoginRoom = YES;
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间成功. roomID: %@", nil), self.roomID];
            [self addLogString:logString];

            self.loginRoomSuccess = YES;
            
            
            ZegoStream *stream = [streamList firstObject];
            
            // 第三方存在流id时
            if (self.playerType == ZegoBasePlayerTypeThirdStream && !ZFIsEmptyString(self.thirdStreamID)) {
                
                if (!stream) {
                    stream = [[ZegoStream alloc] init];
                }
                
                ZegoAPIStreamExtraPlayInfo *info = [[ZegoAPIStreamExtraPlayInfo alloc] init];
                 info.params = nil;

                 //以下rtmp或flv的拉流方式，两个选择一个就可以
                NSString *thirdUrl = ZFToString(self.thirdStreamID);
                 info.rtmpUrls = @[thirdUrl];//完整的rtmp拉流，如果有鉴权参数的，将鉴权参数带上
                 //info.flvUrls = @[@"aaa", @"bbb"]; //完整的flv拉流地址，如果有鉴权参数的，将鉴权参数带上

                self.thirdRanmdStreamID = [NSString stringWithFormat:@"%@-%u", @"ZZZZZthirdstream", (unsigned)rand()];
                //这里的streamID一定不能为空，可以自定义一个
                stream.streamID = self.thirdRanmdStreamID;
                //[[ZFZegoHelper api] startPlayingStream:streamID inView:self.view extraInfo:info];

                self.streamExtraPlayInfo = info;
            }
            
            if(!ZFIsEmptyString(stream.streamID)) {
                
                for (ZegoStream *info in self.streamList) {
                    [[ZFZegoHelper api] stopPlayingStream:info.streamID];
                }
                [self.viewContainersDict removeAllObjects];
                
//                [self.operateView updateLiveCoverState:LiveZegoCoverStateLiving];
                [self updateCoverState:LiveZegoCoverStateLiving];
                
                /// 播放
                [self.streamList addObject:stream];
                [self addStreamViewContainer:stream.streamID];
                [self onLoginChannel:self.roomID error:0];
                
                // 登录成功，默认将自己加入
                ZegoUserState *userState = [[ZegoUserState alloc] init];
                userState.userID = [ZFZegoSettings sharedInstance].userID;
                userState.userName = [ZFZegoSettings sharedInstance].userName;
                userState.updateFlag = ZEGO_USER_ADD;
                
                ZFZegoMessageInfo *messageInfo = [[ZFZegoMessageInfo alloc] init];
                messageInfo.nickname = [ZFVideoLiveCommentUtils handleUserName:userState.userName];
                messageInfo.type = @"-1";
                messageInfo.userState = userState;
                [[ZFVideoLiveCommentUtils sharedInstance] addMessage:messageInfo];
                
            } else {
                if (self.isFirstStartLive) {
                    
                    if (self.playerType == ZegoBasePlayerTypeThirdStream) {
//                        [self.operateView updateLiveCoverState:LiveZegoCoverStateWillStart];
                        [self updateCoverState:LiveZegoCoverStateWillStart];

                    } else {
//                        [self.operateView updateLiveCoverState:LiveZegoCoverStateJustLive];
                        [self updateCoverState:LiveZegoCoverStateJustLive];
                    }
                    
                    // 登录成功，默认将自己加入
                    ZegoUserState *userState = [[ZegoUserState alloc] init];
                    userState.userID = [ZFZegoSettings sharedInstance].userID;
                    userState.userName = [ZFZegoSettings sharedInstance].userName;
                    userState.updateFlag = ZEGO_USER_ADD;
                    
                    ZFZegoMessageInfo *messageInfo = [[ZFZegoMessageInfo alloc] init];
                    messageInfo.nickname = [ZFVideoLiveCommentUtils handleUserName:userState.userName];
                    messageInfo.type = @"-1";
                    messageInfo.userState = userState;
                    [[ZFVideoLiveCommentUtils sharedInstance] addMessage:messageInfo];
                    
                } else {
//                    [self.operateView updateLiveCoverState:LiveZegoCoverStateWillStart];
//                    [self.operateView hideBottomOperateView:YES];
                    [self updateCoverState:LiveZegoCoverStateWillStart];
                }
            }
  
        } else {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间失败. error: %d", nil), errorCode];
            [self addLogString:logString];

            self.loginRoomSuccess = NO;
//            [self.operateView updateLiveCoverState:LiveZegoCoverStateNetworkNrror];
            [self updateCoverState:LiveZegoCoverStateNetworkNrror];
            
        }
    }];
    
}

- (void)updateCoverState:(LiveZegoCoverState )coverState {
    self.coverState = coverState;
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:updateLiveCoverState:)]) {
        [self.delegate zfZegoLiveVideoPlayer:self updateLiveCoverState:coverState];
    }
}

- (void)operateIsPlaying:(BOOL)isPlaying {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:isPlaying:)]) {
        [self.delegate zfZegoLiveVideoPlayer:self isPlaying:isPlaying];
    }
}

#pragma mark - Stream add & delete function
- (BOOL)isStreamIDExist:(NSString *)streamID {
    for (ZegoStream *info in self.streamList) {
        if ([info.streamID isEqualToString:streamID]){
            return YES;
        }
    }
    return NO;
}

- (void)addStreamViewContainer:(NSString *)streamID {
    
    if (ZFIsEmptyString(streamID) || self.viewContainersDict[streamID] != nil) {
        return;
    }
    
    // 第三方存在流id时
    if (self.playerType == ZegoBasePlayerTypeThirdStream && !ZFIsEmptyString(self.thirdStreamID) && !ZFIsEmptyString(self.thirdRanmdStreamID)) {
        streamID = self.thirdRanmdStreamID;
    }
        
    [ZFVideoLiveCommentUtils sharedInstance].liveType = @"2";
    self.viewContainersDict[streamID] = self.videoConterView;
    
    BOOL flag = [self startPlayingStream:streamID type:self.playerType];
    
    self.streamID = streamID;
    //设置视图模式
    BOOL isFull = self.isFull;
    if (isFull) {
        [[ZFZegoHelper api] setViewMode:ZegoVideoViewModeScaleAspectFill ofStream:streamID];
    } else {
        [[ZFZegoHelper api] setViewMode:ZegoVideoViewModeScaleAspectFit ofStream:streamID];
    }
    //设置播放渲染朝向
    //[[ZFZegoHelper api] setViewRotation:CAPTURE_ROTATE_90 ofStream:streamID];
    
    YWLog(@"播放流状态： %i",flag);
}

- (void)removeStreamViewContainer:(NSString *)streamID {
    if (ZFIsEmptyString(streamID) || !self.viewContainersDict[streamID]) {
        return;
    }
    [self.viewContainersDict removeObjectForKey:streamID];
}

- (void)removeStreamInfo:(NSString *)streamID {
    NSInteger index = NSNotFound;
    for (ZegoStream *info in self.streamList) {
        if ([info.streamID isEqualToString:streamID]) {
            index = [self.streamList indexOfObject:info];
            break;
        }
    }
    
    if (index != NSNotFound) {
        [self.streamList removeObjectAtIndex:index];
    }
}

- (void)onStreamUpdateForAdd:(NSArray<ZegoStream *> *)streamList {
    
    for (ZegoStream *stream in streamList) {
        
        NSString *streamID = stream.streamID;
        if (streamID.length == 0) {
            continue;
        }
        
        if ([self isStreamIDExist:streamID]) {
            continue;
        }
        
        [self.streamList addObject:stream];
        [self addStreamViewContainer:streamID];
        
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"新增一条流, 流ID:%@", nil), streamID];
        [self addLogString:logString];
    }
}

- (void)onStreamUpdateForDelete:(NSArray<ZegoStream *> *)streamList {
    for (ZegoStream *stream in streamList) {
        NSString *streamID = stream.streamID;
        if (streamID.length == 0) {
            continue;
        }
        
        if (![self isStreamIDExist:streamID]) {
            continue;
        }
        
        // 当房间中的某条流被删除后，开发者需要调用 stopPlayingStream 停止拉流
        [[ZFZegoHelper api] stopPlayingStream:streamID];
        
        [self removeStreamViewContainer:streamID];
        [self removeStreamInfo:streamID];
        
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"删除一条流, 流ID:%@", nil), streamID];
        [self addLogString:logString];
        
//        [self.operateView updateLiveCoverState:LiveZegoCoverStateJustLive];
        [self updateCoverState:LiveZegoCoverStateJustLive];
    }
}


#pragma mark - ZegoRoomDelegate

- (void)onKickOut:(int)reason roomID:(NSString *)roomID {
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"踢出房间, error: %d", nil), reason];
    [self addLogString:logString];
    self.loginRoomSuccess = NO;
    [ZFVideoLiveCommentUtils sharedInstance].isLoginRoom = NO;
    [ZFVideoLiveCommentUtils sharedInstance].isLiveConnecting = NO;
    
}

- (void)onTempBroken:(int)errorCode roomID:(NSString *)roomID {
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"连接中断通知，SDK会尝试自动重连, error: %d", nil), errorCode];
    [self addLogString:logString];
    if (errorCode == 0) {
        [ZFVideoLiveCommentUtils sharedInstance].isLiveConnecting = YES;
    } else {
        [ZFVideoLiveCommentUtils sharedInstance].isLiveConnecting = NO;
    }
}
- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID {
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"连接失败, error: %d", nil), errorCode];
    [self addLogString:logString];

    // 尝试重新登录房间
    if (errorCode != 0) {
        self.loginRoomSuccess = NO;
        [self reLoginRoom];
    }
}

- (void)onReconnect:(int)errorCode roomID:(NSString *)roomID {
    
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"重新连接通知, error: %d --- streamid: %@", nil), errorCode,self.streamID];
    [self addLogString:logString];
    
    if (errorCode == 0) {
        if (self.playerType == ZegoBasePlayerTypeThirdStream) {
            if (!ZFIsEmptyString(self.thirdStreamID) && !ZFIsEmptyString(self.streamID)) {
//                [self.operateView updateLiveCoverState:LiveZegoCoverStateLiving];
//                [self updateCoverState:LiveZegoCoverStateLiving];
                [self startVideo];

            }
        } else {
            if (!ZFIsEmptyString(self.streamID)) {
//                [self.operateView updateLiveCoverState:LiveZegoCoverStateLiving];
//                [self updateCoverState:LiveZegoCoverStateLiving];
                [self startVideo];
            }
        }
    } else {
        [self updateCoverState:LiveZegoCoverStateReConnectRoomFail];
    }
}

- (void)onLogoutRoom:(NSString *)roomID {
    NSLog(@"---- 退出房间 %s", __func__);
}

// 直播流变更时
- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    if (type == ZEGO_STREAM_ADD) {
        [self onStreamUpdateForAdd:streamList];
    } else if (type == ZEGO_STREAM_DELETE) {
        [self onStreamUpdateForDelete:streamList];
    }
}

- (void)onReceiveCustomCommand:(NSString *)fromUserID userName:(NSString *)fromUserName content:(NSString*)content roomID:(NSString *)roomID {
    
    YWLog(@"--- 自定义消息：%@",content);
    
    ZFZegoMessageInfo *messageInfo = [ZFZegoMessageInfo yy_modelWithJSON:content];
    YWLog(@"======== 消息: %li",(long)messageInfo.infoType);

//#ifdef DEBUG
//    if (messageInfo.infoType == ZegoMessageInfoTypeCart
//        || messageInfo.infoType == ZegoMessageInfoTypeOrder
//        || messageInfo.infoType == ZegoMessageInfoTypePay)
//        ShowAlertToast(content);
//#endif
    
    if (messageInfo.infoType == ZegoMessageInfoTypeGoods) {//推荐商品
        if (ZFJudgeNSDictionary(messageInfo.content)) {
            ZFCommunityVideoLiveGoodsModel *goodsModel = [ZFCommunityVideoLiveGoodsModel yy_modelWithDictionary:messageInfo.content];
            if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:showRecommendGoods:)]) {
                [self.delegate zfZegoLiveVideoPlayer:self showRecommendGoods:goodsModel];
            }
            
        }
    } else if(messageInfo.infoType == ZegoMessageInfoTypeCoupon) {//推荐优惠券
        if (ZFJudgeNSDictionary(messageInfo.content)) {
            ZFGoodsDetailCouponModel *couponModel = [ZFGoodsDetailCouponModel yy_modelWithDictionary:messageInfo.content];
            if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:showCouponAlertView:)]) {
                [self.delegate zfZegoLiveVideoPlayer:self showCouponAlertView:couponModel];
            }
        }
    } else if(messageInfo.infoType == ZegoMessageInfoTypeLiveEnd) { //直播结束
        // 需要告诉外面结束了
        [ZFVideoLiveCommentUtils sharedInstance].liveType = @"3";
//        [self.operateView updateLiveCoverState:LiveZegoCoverStateEnd];
        
        [self updateCoverState:LiveZegoCoverStateEnd];

        
    } else if(messageInfo.infoType == ZegoMessageInfoTypeLike) {//直播点赞

        YWLog(@"--- 点赞消息：%@",content);
        if ([messageInfo.content isKindOfClass:[NSString class]] || [messageInfo.content isKindOfClass:[NSNumber class]]) {
            [ZFVideoLiveCommentUtils sharedInstance].likeNums = [messageInfo.content integerValue];
            [[ZFVideoLiveCommentUtils sharedInstance] refreshLikeNumsAnimate:YES];;
        }
        
    } else {
        [[ZFVideoLiveCommentUtils sharedInstance] addMessage:messageInfo];
    }
    
}

#pragma mark - ZegoIMDelegate

- (void)onUserUpdate:(NSArray<ZegoUserState *> *)userList updateType:(ZegoUserUpdateType)type {
    
    YWLog(@"---这次更新人员集合 --- start");
    if ([[ZFVideoLiveCommentUtils sharedInstance].liveType isEqualToString:@"1"]) {//未开始时，进入用户不显示
        return;
    }
    NSMutableArray *joinRoomUsers = [NSMutableArray array];

    //全量的，直接忽略，因为前面登录地方，将自己加入
    if (type != ZEGO_UPDATE_TOTAL) {

        [userList enumerateObjectsUsingBlock:^(ZegoUserState * _Nonnull userState, NSUInteger idx, BOOL * _Nonnull stop) {
            if (userState.updateFlag == ZEGO_USER_ADD) {
                ZFZegoMessageInfo *messageInfo = [[ZFZegoMessageInfo alloc] init];
                messageInfo.nickname = [ZFVideoLiveCommentUtils handleUserName:userState.userName];
                messageInfo.type = @"-1";
                messageInfo.userState = userState;
                [joinRoomUsers addObject:messageInfo];
            }
            
        }];
        
    }

    YWLog(@"---这次更新人员集合 --- end");
    if (joinRoomUsers.count > 0) {
        [[ZFVideoLiveCommentUtils sharedInstance].liveMessageList addObjectsFromArray:joinRoomUsers];
        [[ZFVideoLiveCommentUtils sharedInstance] refreshCommentNotif:nil];
    }
}

- (void)onUpdateOnlineCount:(int)onlineCount room:(NSString *)roomId {
    YWLog(@"-------- 在线人数: %i",onlineCount);
    if (onlineCount >= 0) {
        [ZFVideoLiveCommentUtils sharedInstance].onlineNums = onlineCount;
        [[ZFVideoLiveCommentUtils sharedInstance] sendOnlineCountNotif:onlineCount];
    }
}
///收到房间的广播消息
- (void)onRecvRoomMessage:(NSString *)roomId messageList:(NSArray<ZegoRoomMessage *> *)messageList {
    
    YWLog(@"-------- 收到房间的广播消息");
//    [self updateLayout:messageList];
}

#pragma mark - ZegoLiveEventDelegate

- (void)zego_onLiveEvent:(ZegoLiveEvent)event info:(NSDictionary<NSString*, NSString*>*)info {
    
    YWLog(@"----- 直播状态：%@",info);
}

#pragma mark - ZegoLivePlayerDelegate

- (void)onLoginChannel:(NSString *)channel error:(int)err {
    if (self.streamList.count == 0 && self.loginRoomSuccess) {
        
    } else {
        for (ZegoStream *info in self.streamList) {
            if (self.viewContainersDict[info.streamID] != nil) {
                continue;
            }
            [self addStreamViewContainer:info.streamID];
            
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"继续播放之前的流, 流ID:%@", nil), info.streamID];
            [self addLogString:logString];
        }
    }
}

// 开始拉取新流会 回调这个方法
- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID {
    
    if (self.livePlayingBlock) {
        self.livePlayingBlock(stateCode);
    }
    
    if (stateCode == 0) {
        [self updateCoverState:LiveZegoCoverStateLiving];
        [self operateIsPlaying:YES];

    } else {
        //FIXME: occ Bug 1101 可以优化
        if (self.playerType == ZegoBasePlayerTypeThirdStream && !ZFIsEmptyString(self.thirdStreamID)) {
            [self updateCoverState:LiveZegoCoverStateUpdateStreamFail];
            [self operateIsPlaying:NO];
        } else {
            [self updateCoverState:LiveZegoCoverStateJustLive];
            [self operateIsPlaying:NO];
        }
    }
    
    YWLog(@"------- onPlayStateUpdate: %i  %s, streamID:%@", stateCode,__func__, streamID);
    
#ifdef DEBUG
    if (stateCode == 0) {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"播放流成功, 流ID:%@", nil), streamID];
        [self addLogString:logString];
    } else {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"播放流失败, 流ID:%@,  error:%d", nil), streamID, stateCode];
        [self addLogString:logString];
    }
#endif

}

- (void)onVideoSizeChangedTo:(CGSize)size ofStream:(NSString *)streamID {
    
#ifdef DEBUG
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"第一帧画面, 流ID:%@", nil), streamID];
    [self addLogString:logString];
    YWLog(@"----直播size: %@",NSStringFromCGSize(size));
#endif
    
    //隐藏预览图
//    [self hidePreviewView];
}

- (void)onPlayQualityUpate:(NSString *)streamID quality:(ZegoApiPlayQuality)quality {
    
    //播放过程，字段隐藏
//    [self.operateView autoHideOperateView];
#ifdef DEBUG
//    NSString *detail = [self addStaticsInfo:NO stream:streamID fps:quality.fps kbs:quality.kbps akbs:quality.akbps rtt:quality.rtt pktLostRate:quality.pktLostRate];
//
//    UIView *view = self.viewContainersDict[streamID];
//    if (view) {
//        [self updateQuality:quality.quality detail:detail onView:view];
//    }
#endif
}

#pragma mark -
#pragma mark  视频播放相关

- (void)startVideoPlay {
//    [self.operateView playViewState:YES];
    
    //TODO: occ测试数据 录播菊花
//    [self operateIsPlaying:YES];
    
    if (self.isFull) {
        [self.mediaPlayerHelper setVideoView:self.videoConterView viewModel:ZegoVideoViewModeScaleAspectFill];

    } else {
        [self.mediaPlayerHelper setVideoView:self.videoConterView viewModel:ZegoVideoViewModeScaleAspectFit];
    }
    
    // 如果传空字符，不触发错误回调报错方法
    [self.mediaPlayerHelper startPlaying:!ZFIsEmptyString(self.sourceVideoAddress) ? self.sourceVideoAddress : @"empty" repeat:NO];
}

#pragma mark  ZFZegoMediaPlayerHelperDelegate

- (void)onPlayerState:(NSString *)state {
    YWLog(@"----- 视频播放状态: %@",state);
    
    if ([state containsString:@"Requesting"]) {
        
//        if (!self.activityView.superview) {
//            [self addSubview:self.activityView];
//            [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.mas_equalTo(self.mas_centerX);
//                make.centerY.mas_equalTo(self.mas_centerY);
//                make.size.mas_equalTo(CGSizeMake(30, 30));
//            }];
//        }
        
    } else if([state containsString:@"Begin"]) {
//        [self.activityView stopAnimating];
        [self operateIsPlaying:YES];
    } else {
//        [self.activityView stopAnimating];
    }
}

- (void)onPlayerProgress:(long)current max:(long)max desc:(NSString *)desc {
//    [self.operateView startTime:[NSString stringWithFormat:@"%ld",current/1000] endTime:[NSString stringWithFormat:@"%ld",max/1000] isEnd:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:videoProgress:max:isEnd:)]) {
        [self.delegate zfZegoLiveVideoPlayer:self videoProgress:[NSString stringWithFormat:@"%ld",current/1000] max:[NSString stringWithFormat:@"%ld",max/1000] isEnd:NO];
    }
}

- (void)onPlayerStop {
    YWLog(@"---- 视频停止播放: %i    %i",self.mediaPlayerHelper.currentProgress,self.mediaPlayerHelper.duration);
//    [self.operateView startTime:[NSString stringWithFormat:@"%d",self.mediaPlayerHelper.currentProgress / 1000] endTime:[NSString stringWithFormat:@"%d",self.mediaPlayerHelper.duration / 1000] isEnd:NO];
//    [self.operateView playViewState:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:videoProgress:max:isEnd:)]) {
        [self.delegate zfZegoLiveVideoPlayer:self videoProgress:[NSString stringWithFormat:@"%d",self.mediaPlayerHelper.currentProgress / 1000] max:[NSString stringWithFormat:@"%d",self.mediaPlayerHelper.duration / 1000] isEnd:NO];
    }
    [self operateIsPlaying:NO];

}

- (void)onPlayerErrorCode:(int)code {
    YWLog(@"----- 录播错误：%i",code);
    //FIXME: occ Bug 1101
    if (code == 0) {
//        [self.operateView updateLiveCoverState:LiveZegoCoverStatePlay];
        [self updateCoverState:LiveZegoCoverStatePlay];
    } else {
//        [self.operateView updateLiveCoverState:LiveZegoCoverStateEnd];
        [self updateCoverState:LiveZegoCoverStateEnd];
    }
}
#pragma mark - 复写方法 播放事件

- (void)basePlayVideoWithVideoID:(NSString *)videoID {
    
    if (self.playerType == ZegoBasePlayerTypeLiving || self.playerType == ZegoBasePlayerTypeThirdStream) {
//        if (self.operateView.playState == ZFVideoPlayStatePlay) {
//            [self pauseVideo];
//        } else {
//            [self startVideo];
//        }
    } else {
        // 录播
        if (self.mediaPlayerHelper.playerState == ZGPlayerState_Playing) {
            if (self.mediaPlayerHelper.playingSubState == ZGPlayingSubState_Paused) {
                [self.mediaPlayerHelper resume];
//                [self.operateView playViewState:YES];
                [self operateIsPlaying:YES];
                
            } else if(self.mediaPlayerHelper.playingSubState == ZGPlayingSubState_PlayBegin) {
                [self.mediaPlayerHelper pause];
//                [self.operateView playViewState:NO];
                [self operateIsPlaying:NO];
            }
        } else if (self.mediaPlayerHelper.playerState == ZGPlayerState_Stopped) {
            [self.mediaPlayerHelper startPlaying:self.sourceVideoAddress repeat:NO];
        } else {
            
        }
    }
}

- (void)baseSeekToSecondsPlayVideo:(float)seconds {
    [self.mediaPlayerHelper seekTo:seconds * 1000];
}

- (void)startVideo {
    
    if (self.playerType == ZegoBasePlayerTypeLiving || self.playerType == ZegoBasePlayerTypeThirdStream) {
        if (!ZFIsEmptyString(self.streamID)) {
            
            BOOL flag = [self startPlayingStream:self.streamID type:self.playerType];
            if (flag) {
//                [self.operateView playViewState:YES];
            }
            [self operateIsPlaying:flag];
            
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:startPlayingStream:)]) {
                [self.delegate zfZegoLiveVideoPlayer:self startPlayingStream:NO];
            }
        }
    } else {
        [self.mediaPlayerHelper resume];
//        [self.operateView playViewState:YES];
        [self operateIsPlaying:YES];
    }
}

- (void)stopVideo {
    if (self.playerType == ZegoBasePlayerTypeLiving || self.playerType == ZegoBasePlayerTypeThirdStream) {
        [[ZFZegoHelper api] stopPlayingStream:self.streamID];
    } else {
        [self.mediaPlayerHelper stop];
        self.mediaPlayerHelper = nil;
    }
}

- (void)pauseVideo {
    if (self.playerType == ZegoBasePlayerTypeLiving || self.playerType == ZegoBasePlayerTypeThirdStream) {
        
//        [self showPreviewView:[self snapshotVideoImage]];
        BOOL state = [[ZFZegoHelper api] stopPlayingStream:self.streamID];
        if (state) {
//            [self.operateView playViewState:NO];
            [self operateIsPlaying:NO];
        }
        
        //zego截图太慢了 如果调用结束后，截取不到什么
    } else {
        [self.mediaPlayerHelper pause];
//        [self.operateView playViewState:NO];
        [self operateIsPlaying:NO];
    }
}


- (BOOL)startPlayingStream:(NSString *)streameId type:(ZegoBasePlayerType)playerType {
    
    if (ZFIsEmptyString(streameId)) {
        streameId = @"ZZZZZ";
    }
    BOOL flag = NO;
    if (self.playerType == ZegoBasePlayerTypeThirdStream) {// 播放第三方流
        flag = [[ZFZegoHelper api] startPlayingStream:streameId inView:self.videoConterView extraInfo:self.streamExtraPlayInfo];
    } else {
        flag = [[ZFZegoHelper api] startPlayingStream:streameId inView:self.videoConterView];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfZegoLiveVideoPlayer:startPlayingStream:)]) {
        [self.delegate zfZegoLiveVideoPlayer:self startPlayingStream:flag];
    }
    
    return flag;
}


#pragma mark - Property Method

- (void)setVideoDetailID:(NSString *)videoDetailID {
//    _videoDetailID = videoDetailID;
//    self.operateView.videoDetailID = videoDetailID;
}

#pragma mark - 测试功能
- (void)testAlertView {
#ifdef DEBUG
    ZFZegoMessageInfo *messageInfo = [self testMessageCoupon];
    if (messageInfo.infoType == ZegoMessageInfoTypeGoods) {//推荐商品
        if (ZFJudgeNSDictionary(messageInfo.content)) {
            ZFCommunityVideoLiveGoodsModel *goodsModel = [ZFCommunityVideoLiveGoodsModel yy_modelWithDictionary:messageInfo.content];
//            [self showGoodsAlertView:goodsModel];
        }
    } else if(messageInfo.infoType == ZegoMessageInfoTypeCoupon) {//推荐优惠券
        if (ZFJudgeNSDictionary(messageInfo.content)) {
            ZFGoodsDetailCouponModel *couponModel = [ZFGoodsDetailCouponModel yy_modelWithDictionary:messageInfo.content];
//            [self showCouponAlertView:couponModel];
        }
    } else {
        [[ZFVideoLiveCommentUtils sharedInstance] addMessage:messageInfo];
    }
#endif
}

- (ZFZegoMessageInfo *)testMessageGoods {
    
    NSString *ttt = @"{\"type\":1,\"nickname\":\"cccc\",\"content\":{\"goods_id\":\"558877\",\"goods_sn\":\"280165302\",\"cat_id\":\"28\",\"cat_name\":\"Earrings\",\"title\":\"Mask Design Hook Drop Earrings\",\"market_price\":\"4.83\",\"url\":\"http://www.pc-ZZZZZ.com.master.php5.egomsl.com\",\"pic_url\":\"https://gloimg.ywzf.com/ZZZZZ/pdm-product-pic/Clothing/2018/08/24/goods-img/1535073753295009607.jpg\",\"goods_cate_detail\":{\"parent_cat_list\":[{\"cat_id\":\"4\",\"cat_name\":\"Accessories\"},{\"cat_id\":\"3\",\"cat_name\":\"Jewelry\"}],\"child_cat_list\":[]},\"goods_is_on_sale\":1,\"shop_price\":\"3.50\"}}";
    ZFZegoMessageInfo *messageInfo = [ZFZegoMessageInfo yy_modelWithJSON:ttt];
    return messageInfo;
}

- (ZFZegoMessageInfo *)testMessageCoupon {
    
    NSString *ttt = @"{\"type\":2,\"nickname\":\"cccc\",\"content\":{\"couponId\":\"1153\",\"endTime\":\"Aug. 29, 2019 at 11:00:00 AM\",\"discounts\":\"$2 off $9+\",\"preferentialHead\":\"\",\"preferentialFirst\":\"$2 off $9+\",\"noMail\":\"0\",\"couponStats\":1}}";
    ZFZegoMessageInfo *messageInfo = [ZFZegoMessageInfo yy_modelWithJSON:ttt];
    return messageInfo;
}




- (NSString *)addStaticsInfo:(BOOL)publish stream:(NSString *)streamID fps:(double)fps kbs:(double)kbs akbs:(double)akbs rtt:(int)rtt pktLostRate:(int)pktLostRate
{
    if (streamID.length == 0)
        return nil;
    
    // 丢包率的取值为 0~255，需要除以 256.0 得到丢包率百分比
    NSString *qualityString = [NSString stringWithFormat:NSLocalizedString(@"[%@] 帧率: %.3f, 视频码率: %.3f kb/s, 音频码率: %.3f kb/s, 延时: %d ms, 丢包率: %.3f%%", nil), publish ? NSLocalizedString(@"推流", nil): NSLocalizedString(@"拉流", nil), fps, kbs, akbs, rtt, pktLostRate/256.0 * 100];
    NSString *totalString =[NSString stringWithFormat:NSLocalizedString(@"[%@] 流ID: %@, 帧率: %.3f, 视频码率: %.3f kb/s, 音频码率: %.3f kb/s, 延时: %d ms, 丢包率: %.3f%%", nil), publish ? NSLocalizedString(@"推流", nil): NSLocalizedString(@"拉流", nil), streamID, fps, kbs, akbs, rtt, pktLostRate/256.0 * 100];
//    [self.staticsArray insertObject:totalString atIndex:0];
    
    //YWLog(@"---------直播状态:  %@",totalString);
    
    // 通知 log 界面更新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logUpdateNotification" object:self userInfo:nil];
    
    return qualityString;
}

#pragma mark -- Update pubslish and play quality statistics

- (void)updateQuality:(int)quality detail:(NSString *)detail onView:(UIView *)playerView
{
    if (playerView == nil)
        return;
    
    CALayer *qualityLayer = nil;
    CATextLayer *textLayer = nil;
    
    for (CALayer *layer in playerView.layer.sublayers)
        {
        if ([layer.name isEqualToString:@"quality"])
            qualityLayer = layer;
        
        if ([layer.name isEqualToString:@"indicate"])
            textLayer = (CATextLayer *)layer;
        }
    
    int originQuality = 0;
    if (qualityLayer != nil)
        {
        if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor greenColor].CGColor))
            originQuality = 0;
        else if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor yellowColor].CGColor))
            originQuality = 1;
        else if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor redColor].CGColor))
            originQuality = 2;
        else
            originQuality = 3;
        
        //        if (quality == originQuality)
        //            return;
        }
    
    UIFont *textFont = [UIFont systemFontOfSize:12];
    
    if (qualityLayer == nil)
        {
        qualityLayer = [CALayer layer];
        qualityLayer.name = @"quality";
        [playerView.layer addSublayer:qualityLayer];
        qualityLayer.frame = CGRectMake(12, 44, 10, 10);
        qualityLayer.contentsScale = [UIScreen mainScreen].scale;
        qualityLayer.cornerRadius = 5.0f;
        }
    
    if (textLayer == nil)
        {
        textLayer = [CATextLayer layer];
        textLayer.name = @"indicate";
        [playerView.layer addSublayer:textLayer];
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        textLayer.wrapped = YES;
        textLayer.font = (__bridge CFTypeRef)textFont.fontName;
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.fontSize = textFont.pointSize;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        }
    
    UIColor *qualityColor = nil;
    NSString *text = nil;
    if (quality == 0)
        {
        qualityColor = [UIColor greenColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"优", nil)];
        }
    else if (quality == 1)
        {
        qualityColor = [UIColor yellowColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"良", nil)];
        }
    else if (quality == 2)
        {
        qualityColor = [UIColor redColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"中", nil)];
        }
    else
        {
        qualityColor = [UIColor grayColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"差", nil)];
        }
    
    qualityLayer.backgroundColor = qualityColor.CGColor;
    
    NSString *totalString = [NSString stringWithFormat:@"%@  %@", text, detail];
    
    //    CGSize textSize = [totalString sizeWithAttributes:@{NSFontAttributeName: textFont}];
    
    CGSize textSize = [totalString boundingRectWithSize:CGSizeMake(playerView.bounds.size.width - 30, 0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:textFont}
                                                context:nil].size;
    
    CGRect textFrame = CGRectMake(CGRectGetMaxX(qualityLayer.frame) + 3,
                                  CGRectGetMinY(qualityLayer.frame) - 3,
                                  ceilf(textSize.width),
                                  ceilf(textSize.height) + 10);
    textLayer.frame = textFrame;
    textLayer.string = totalString;
}

#pragma mark comment

- (void)updateLayout:(NSArray<ZegoRoomMessage *> *)messageList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (ZegoRoomMessage *message in messageList) {
            if (message.category == ZEGO_CHAT) {
                //                [self caculateLayout:@"" userName:message.fromUserName content:message.content];
            } else if (message.category == ZEGO_LIKE) {
                //解析Content 内容
                NSData *contentData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:contentData options:0 error:nil];
                
                NSUInteger count = [contentDict[@"likeCount"] unsignedIntegerValue];
                if (count != 0) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self updateLikeAnimation:count];
//                    });
                }
//                [self caculateLayout:@"" userName:message.fromUserName content:@"点赞了主播"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.messageView reloadData];
//                [self scrollTableViewToBottom];
            });
        }
    });
}

- (void)addLogString:(NSString *)log {
    YWLog(@"----- %@",log);
}

- (NSDictionary *)decodeJSONToDictionary:(NSString *)json
{
    if (json == nil)
        return nil;
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData)
        {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        return dictionary;
        }
    
    return nil;
}
@end
