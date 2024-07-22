//
//  ZFMediaPlayerPublishingHelper.m
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFMediaPlayerPublishingHelper.h"

#import "ZFZegoHelper.h"
#import "ZFZegoUtils.h"

@interface ZFMediaPlayerPublishingHelper () <ZegoRoomDelegate, ZegoLivePublisherDelegate> {
    ZFMediaPlayerPublishingStateObserver observer_;
}

@end

@implementation ZFMediaPlayerPublishingHelper

- (void)setPublishStateObserver:(ZFMediaPlayerPublishingStateObserver)observer {
    observer_ = observer;
}

- (void)startPublishing {
    [[ZFZegoHelper api] setPublisherDelegate:self];
    
    __weak ZFMediaPlayerPublishingHelper* weak_self = self;
    [[ZFZegoHelper api] loginRoom:[ZFZegoUtils getDeviceUUID] role:ZEGO_ANCHOR withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
        ZFMediaPlayerPublishingHelper* strong_self = weak_self;
        if (errorCode == 0) {
            [ZegoLiveRoomApi requireHardwareEncoder:true];
            //发布播放视频推送
            BOOL state = [[ZFZegoHelper api] startPublishing:[ZFZegoUtils getDeviceUUID] title:[ZFZegoUtils getDeviceUUID] flag:ZEGOAPI_SINGLE_ANCHOR];
            if (strong_self->observer_) {
                strong_self->observer_(state ? @"START PUBLISHING SUCCESS" : @"LOGIN FAILED!");
            }
        } else {
            if (strong_self->observer_) {
                strong_self->observer_(@"LOGIN FAILED!");
            }
        }
    }];
}

#pragma mark - ZegoLivePublisherDelegate

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary *)info {
    if (!observer_) return;
    
    if (stateCode == 0) {
        observer_([NSString stringWithFormat:@"PUBLISH STARTED: \n%@\n%@\n%@",
                   [info[kZegoRtmpUrlListKey] firstObject],
                   [info[kZegoFlvUrlListKey] firstObject],
                   [info[kZegoHlsUrlListKey] firstObject]]
                  );
    } else {
        observer_([NSString stringWithFormat:@"PUBLISH STOP: %d", stateCode]);
    }
}

#pragma mark - ZegoRoomDelegate

- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID {
    if (observer_) {
        observer_([NSString stringWithFormat:@"ROOM DISCONNECTED: %d", errorCode]);
    }
}

@end
