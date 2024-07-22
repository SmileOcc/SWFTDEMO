//
//  YouTuBePlayerView.h
//  YouTuBePlayer
//
//  Created by liwei on 2017/5/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

/** V3.8.0加入 (为了解决视频播放时自动全屏的bug)
 * 此库也是Github上第三方的: https://github.com/LittleCuteCat/YouTuBePlayer
 * 如果后续有bug就换回YouTuBe官方的: https://github.com/youtube/youtube-ios-player-helper
 */

#import "ZFLiveBaseView.h"
#import "ZFGoodsModel.h"

#import "ZFVideoLiveOperateView.h"

@interface YouTuBePlayerView : ZFLiveBaseView


/// 是否显示系统自带的控件
@property (nonatomic, assign) BOOL                       isShowSystemView;

@property (nonatomic,copy) void (^videoPlayStatusChange)(PlayerState playerState);

/** 真实的开发播放*/
@property (nonatomic,copy) void (^videoRealStartPlay)(void);

/// 隐藏自定义的操作图层
- (void)cancelSettingOperateView;

@end

