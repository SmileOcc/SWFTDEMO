//
//  ZFMediaPlayerPublishingHelper.h
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ZFMediaPlayerPublishingStateObserver)(NSString* _Nonnull);

@interface ZFMediaPlayerPublishingHelper : NSObject

/// 播放视频推送
- (void)startPublishing;
- (void)setPublishStateObserver:(ZFMediaPlayerPublishingStateObserver _Nullable)observer;

@end

NS_ASSUME_NONNULL_END
