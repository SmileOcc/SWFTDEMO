//
//  ZFZegoLiveCoverState.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,ZegoBasePlayerType) {
    ZegoBasePlayerTypeUnknow,
    /**直播*/
    ZegoBasePlayerTypeLiving,
    /**录播*/
    ZegoBasePlayerTypeVideo,
    /**直播第三方流*/
    ZegoBasePlayerTypeThirdStream,
};

typedef NS_ENUM(NSInteger,LiveZegoCoverState) {
    LiveZegoCoverStateUnknow,
    /** 网络异常*/
    LiveZegoCoverStateNetworkNrror,
    /** 结束刷新动画*/
    LiveZegoCoverStateEndRefresh,
    /** 将要开始，显示倒计时*/
    LiveZegoCoverStateWillStart,
    /** 直播流播放*/
    LiveZegoCoverStateLiving,
    /** 主播离开*/
    LiveZegoCoverStateJustLive,
    /** 直播结束*/
    LiveZegoCoverStateEnd,
    /** 房间重连失败*/
    LiveZegoCoverStateReConnectRoomFail,
    /** 房间重连失败*/
    LiveZegoCoverStateReConnectRoomSuccess,
    /** 拉取流失败*/
    LiveZegoCoverStateUpdateStreamFail,
    /** 拉取流成功*/
    LiveZegoCoverStateUpdateStreamSuccess,
    /** 录播播放状态*/
    LiveZegoCoverStatePlay,
};

NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoLiveConstants : NSObject

@end

NS_ASSUME_NONNULL_END
