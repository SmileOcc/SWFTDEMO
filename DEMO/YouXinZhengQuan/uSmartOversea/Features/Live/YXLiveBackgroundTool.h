//
//  YXLiveBackgroundTool.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/12/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "YXLiveDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXPlayEvent) {
    YXPlayEventPlay = 0,
    YXPlayEventStop = 1,
};

typedef void(^CommandCallBack)(YXPlayEvent event);

@interface YXLiveBackgroundTool : NSObject

+ (void)setBackGroundWithLive:(YXLiveDetailModel *)liveModel andCallBack: (CommandCallBack)callBack;

@end

NS_ASSUME_NONNULL_END
