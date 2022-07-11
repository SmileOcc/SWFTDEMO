//
//  YXLiveBackgroundTool.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/12/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveBackgroundTool.h"
#import <SDWebImage/SDWebImageDownloader.h>

@implementation YXLiveBackgroundTool

+ (void)setBackGroundWithLive:(YXLiveDetailModel *)liveModel andCallBack: (CommandCallBack)callBack {
    
    NSString *urlStr = liveModel.cover_images.image.firstObject;
    if (urlStr.length > 0) {
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            if (image) {
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: image];
                [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            }
            [songInfo setObject:liveModel.title?:@"" forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:liveModel.anchor.nick_name?:@"" forKey:MPMediaItemPropertyArtist];
            
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            
            
            MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
            
            // 锁屏播放
            MPRemoteCommand *playCommand = commandCenter.playCommand;
            playCommand.enabled = YES;
            [playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                NSLog(@"点击播放");

                if (callBack) {
                    callBack(YXPlayEventPlay);
                }
                return MPRemoteCommandHandlerStatusSuccess;
            }];
            
            // 锁屏暂停
            MPRemoteCommand *pauseCommand = commandCenter.pauseCommand;
            pauseCommand.enabled = YES;
            [pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
                NSLog(@"点击暂停");
                if (callBack) {
                    callBack(YXPlayEventStop);
                }
                return MPRemoteCommandHandlerStatusSuccess;
            }];
        }];
    }

    

}

@end
