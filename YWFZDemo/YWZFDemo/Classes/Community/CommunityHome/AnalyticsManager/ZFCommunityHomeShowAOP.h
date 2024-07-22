//
//  ZFCommunityHomeShowAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseAnalyticsAOP.h"
#import <UIKit/UIKit.h>
#import "AnalyticsInjectManager.h"

@interface ZFCommunityHomeShowAOP : ZFCMSBaseAnalyticsAOP
<
ZFAnalyticsInjectProtocol
>

- (instancetype)initChannelId:(NSString *)channelId;

- (void)baseConfigureChannelId:(NSString *)channelId channelName:(NSString *)channelName;

@end


@interface ZFCommunityHomeShowAnalyticsSet : NSObject

+ (instancetype)sharedInstance;

- (void)addObject:(NSString *)object;

- (BOOL)containsObject:(NSString *)object;

- (void)removeObject:(NSString *)object;

- (void)removeAllObjects;

@end
