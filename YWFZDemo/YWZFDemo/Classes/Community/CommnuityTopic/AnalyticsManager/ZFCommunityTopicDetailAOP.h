//
//  ZFCommunityTopicDetailAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseAnalyticsAOP.h"
#import <UIKit/UIKit.h>
#import "AnalyticsInjectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityTopicDetailAOP : ZFCMSBaseAnalyticsAOP
<
ZFAnalyticsInjectProtocol
>

- (void)baseConfigureChannelId:(NSString *)channelId channelName:(NSString *)channelName;

@end

NS_ASSUME_NONNULL_END
