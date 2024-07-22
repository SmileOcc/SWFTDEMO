//
//  ZFCommunityHomeOutfitsAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AnalyticsInjectManager.h"

@interface ZFCommunityHomeOutfitsAOP : NSObject
<
ZFAnalyticsInjectProtocol
>

- (instancetype)initChannelId:(NSString *)channelId;
- (void)baseConfigureChannelId:(NSString *)channelId channelName:(NSString *)channelName;
@end



@interface ZFCommunityHomeOutfitsAnalyticsSet : NSObject

+ (instancetype)sharedInstance;

- (void)addObject:(NSString *)object;

- (BOOL)containsObject:(NSString *)object;

- (void)removeObject:(NSString *)object;

- (void)removeAllObjects;

@end
