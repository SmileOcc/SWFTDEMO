//
//  ZFZegoMediaPlayerHelper.h
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "ZGApiManager.h"
#import "ZFZegoHelper.h"
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#import <ZegoLiveRoomOSX/zego-api-mediaplayer-oc.h>
#elif TARGET_OS_IOS
#import <UIKit/UIKit.h>
#import <ZegoLiveRoom/zego-api-mediaplayer-oc.h>
#endif

#import "ZFMediaPlayerPublishingHelper.h"
#import "ZFZegoUtils.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ZGPlayerState_Stopped,
    ZGPlayerState_Stopping,
    ZGPlayerState_Playing
} ZGPlayerState;

typedef enum {
    ZGPlayingSubState_Requesting,
    ZGPlayingSubState_PlayBegin,
    ZGPlayingSubState_Paused,
    ZGPlayingSubState_Buffering
} ZGPlayingSubState;

@protocol ZFZegoMediaPlayerHelperDelegate <NSObject>

@optional
- (void)onPlayerState:(NSString*)state;
- (void)onPlayerProgress:(long)current max:(long)max desc:(NSString*)desc;
- (void)onPlayerStop;
- (void)onPlayerErrorCode:(int)code;

// 发布录播视频
- (void)onPublishState:(NSString*)state;

- (void)onGetAudioStreamCount:(int)count;

@end


@interface ZFZegoMediaPlayerHelper : NSObject

@property (nonatomic,weak) id<ZFZegoMediaPlayerHelperDelegate> delegate;

- (instancetype)initStartPublish:(BOOL)publish;

@property (nonatomic) ZGPlayerState playerState;
@property (nonatomic) ZGPlayingSubState playingSubState;
@property (nonatomic) int duration;
@property (nonatomic) int currentProgress;

- (void)setPlayerType:(MediaPlayerType)type;
- (void)setVideoView:(UIView* _Nullable)view viewModel:(ZegoVideoViewMode)viewModel;
- (void)setVolume:(int)volume;
- (void)startPlaying:(NSString* _Nonnull)url repeat:(BOOL)repeat;
- (void)stop;
- (void)pause;
- (void)resume;

- (void)seekTo:(long)millisecond;

- (void)setAudioStream:(int)stream;

@end

NS_ASSUME_NONNULL_END
