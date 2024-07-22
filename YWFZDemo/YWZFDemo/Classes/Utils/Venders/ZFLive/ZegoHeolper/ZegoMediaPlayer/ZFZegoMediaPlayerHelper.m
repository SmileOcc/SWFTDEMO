//
//  ZFZegoMediaPlayerHelper.m
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoMediaPlayerHelper.h"
#import "ZGVideoCaptureForMediaPlayer.h"
#import "Constants.h"


@interface ZFZegoMediaPlayerHelper () <ZegoMediaPlayerEventDelegate>

@property (strong) ZegoMediaPlayer* player;
@property (strong) NSTimer* progressUpdateTimer;

@property (strong) ZGVideoCaptureForMediaPlayer* videoCapture;
@property (strong) ZFMediaPlayerPublishingHelper* publishHelper;

@end

@implementation ZFZegoMediaPlayerHelper

- (instancetype)initStartPublish:(BOOL)publish {
    self = [super init];
    if (self) {
        
        if (publish) {
            
            // // 推流播放模式，会将音频混流推流中，调用端和拉流端都可以听到播放的声音。
            self.player = [[ZegoMediaPlayer alloc] initWithPlayerType:MediaPlayerTypeAux];
            [self.player setDelegate:self];
            
            [ZFZegoHelper releaseApi];
            self.videoCapture = [[ZGVideoCaptureForMediaPlayer alloc] init];
            [ZFZegoHelper enableExternalVideoCapture:self.videoCapture videoRenderer:nil];
            [self.player setVideoPlayDelegate:self.videoCapture format:ZegoMediaPlayerVideoPixelFormatBGRA32];
            
            self.publishHelper = [ZFMediaPlayerPublishingHelper new];
            __weak ZFZegoMediaPlayerHelper* weakSelf = self;
            [self.publishHelper setPublishStateObserver:^(NSString * _Nonnull state) {
                YWLog(@"%s: %@", __func__, state);
                ZFZegoMediaPlayerHelper* strongSelf = weakSelf;
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(onPublishState:)]) {
                    [strongSelf.delegate onPublishState: state];
                }
            }];
            [self.publishHelper startPublishing];
            
        } else {
            // 普通播放不需要登录 // 本地播放模式，不会将音频混入推流中，只有调用端可以听到播放的声音。
            self.player = [[ZegoMediaPlayer alloc] initWithPlayerType:MediaPlayerTypePlayer];
            [self.player setDelegate:self];
        }
        
    }
    return self;
}

- (void)dealloc {
    YWLog(@"-----播放器工具：ZFZegoMediaPlayerHelper");
    if (self.progressUpdateTimer) {
        [self.progressUpdateTimer invalidate];
        self.progressUpdateTimer = nil;
    }
    [self.player stop];
    [self.player uninit];
    [ZFZegoHelper.api logoutRoom];
    [ZFZegoHelper releaseApi];
    [ZegoExternalVideoCapture setVideoCaptureFactory:nil channelIndex:ZEGOAPI_CHN_MAIN];
}

- (void)setPlayerType:(MediaPlayerType)type {
    [self.player setPlayerType:type];
}

- (void)setVideoView:(UIView *)view viewModel:(ZegoVideoViewMode)viewModel{
    [self.player setViewMode:viewModel];
    [self.player setView:view];
}

- (void)setVolume:(int)volumn {
    [self.player setVolume:volumn];
}

- (void)startPlaying:(NSString *)url repeat:(BOOL)repeat {
    YWLog(@"%s, %@", __func__, url);
    if (self.playerState == ZGPlayerState_Playing) {
        // * 必须先停止
        [self.player stop];
    }
    
    [self.player start:url repeat:repeat];
    
    self.playerState = ZGPlayerState_Playing;
    self.playingSubState = ZGPlayingSubState_Requesting;
}

- (void)stop {
    YWLog(@"%s", __func__);
    [self.player stop];
    self.playerState = ZGPlayerState_Stopping;
}

- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player resume];
}

- (void)seekTo:(long)millisecond {
    YWLog(@"--- 快进到：%li",millisecond);
    [self.player seekTo:millisecond];
}

- (void)setAudioStream:(int)stream {
    [self.player setAudioStream:stream];
}

#pragma mark - ZegoMediaPlayerEventDelegate

- (void)onPlayStart {
    YWLog(@"%s", __func__);
    
    assert(self.playerState == ZGPlayerState_Playing);
    assert(self.playingSubState == ZGPlayingSubState_Requesting);
    
    self.playingSubState = ZGPlayingSubState_PlayBegin;
    
    self.currentProgress = 0;
    self.duration = (int)[self.player getDuration];
    
    [self updateProgressDesc];
    
    int audioStreamCount = (int)[self.player getAudioStreamCount];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGetAudioStreamCount:)]) {
        [self.delegate onGetAudioStreamCount:audioStreamCount];
    }
}

- (void)onPlayPause {
    YWLog(@"%s", __func__);
    assert(self.playerState == ZGPlayerState_Playing);
    self.playingSubState = ZGPlayingSubState_Paused;
}

- (void)onPlayResume {
    YWLog(@"%s", __func__);
    assert(self.playerState == ZGPlayerState_Playing);
    self.playingSubState = ZGPlayingSubState_PlayBegin;
}

- (void)onPlayError:(int)code  {
    YWLog(@"---onPlayError：%s : %i", __func__,code);
    self.playerState = ZGPlayerState_Stopped;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerErrorCode:)]) {
        [self.delegate onPlayerErrorCode:code];
    }
}

- (void)onVideoBegin  {
    YWLog(@"%s", __func__);
}

- (void)onAudioBegin {
    YWLog(@"%s", __func__);
}

- (void)onPlayEnd {
    YWLog(@"%s", __func__);
    self.playerState = ZGPlayerState_Stopped;
}

- (void)onPlayStop {
    YWLog(@"%s", __func__);
    if (self.playerState == ZGPlayerState_Stopping) {
        self.playerState = ZGPlayerState_Stopped;
    }
}

- (void)onBufferBegin {
    YWLog(@"%s onBufferBegin", __func__);
    if (self.playerState == ZGPlayerState_Playing) {
        self.playingSubState = ZGPlayingSubState_Buffering;
    } else {
        assert(false);
    }
}

- (void)onBufferEnd {
    YWLog(@"%s", __func__);
    if (self.playerState == ZGPlayerState_Playing) {
        if (self.playingSubState == ZGPlayingSubState_Buffering) {
            self.playingSubState = ZGPlayingSubState_PlayBegin;
        } else {
            assert(false);
        }
    } else {
        assert(false);
    }
}

- (void)onSeekComplete:(int)code when:(long)millisecond {
    YWLog(@"onSeekComplete  code: %i %s",code, __func__);
}


#pragma mark - Private

- (void)setPlayerState:(ZGPlayerState)playerState {
    YWLog(@"%s, %d", __func__, playerState);
    
    _playerState = playerState;
    [self updateCurrentState];
    
    if (_playerState == ZGPlayerState_Playing) {
        if (self.progressUpdateTimer) {
            [self.progressUpdateTimer invalidate];
        }
        self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    } else if (self.progressUpdateTimer.valid) {
        [self.progressUpdateTimer invalidate];
        self.progressUpdateTimer = nil;
        
        if (self.playerState == ZGPlayerState_Stopped) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerStop)]) {
                [self.delegate onPlayerStop];
            }
        }
    }
}

- (void)onTimer:(NSTimer*)timer {
    self.currentProgress = (int)[self.player getCurrentDuration];
    [self updateProgressDesc];
}

- (void)setPlayingSubState:(ZGPlayingSubState)playingSubState {
    _playingSubState = playingSubState;
    [self updateCurrentState];
}

- (void)updateCurrentState {
    NSString* currentStateDesc = nil;
    switch (self.playerState) {
        case ZGPlayerState_Stopped:
            currentStateDesc = @"Stopped";
            break;
        case ZGPlayerState_Stopping:
            currentStateDesc = @"Stopping";
            break;
        case ZGPlayerState_Playing: {
            NSString* prefix = @"Playing";
            NSString* subState = nil;
            switch (self.playingSubState) {
                case ZGPlayingSubState_Requesting:
                    subState = @"Requesting";
                    break;
                case ZGPlayingSubState_PlayBegin:
                    subState = @"Begin";
                    break;
                case ZGPlayingSubState_Paused:
                    subState = @"Paused";
                    break;
                case ZGPlayingSubState_Buffering:
                    subState = @"Buffering";
                    break;
                default:
                    break;
            }
            currentStateDesc = [NSString stringWithFormat:@"%@: %@", prefix, subState];
            break;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerState:)]) {
        [self.delegate onPlayerState:currentStateDesc];
    }
}

- (void)updateProgressDesc {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerProgress:max:desc:)]) {
        [self.delegate onPlayerProgress:self.currentProgress max:self.duration desc:[NSString stringWithFormat:@"%d/%d", self.currentProgress/1000, self.duration/1000]];
    }
}

@end
