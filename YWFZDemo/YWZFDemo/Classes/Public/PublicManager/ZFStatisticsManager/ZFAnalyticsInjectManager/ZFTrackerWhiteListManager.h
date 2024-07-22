//
//  ZFTrackerWhiteListManager.h
//  ZZZZZ
//
//  Created by YW on 2019/2/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFTrackerWhiteListManager : NSObject

+ (instancetype)sharedInstance;

//开始统计
- (void)startTrack;

- (id<ZFAnalyticsInjectProtocol>)gainAnalyticsInjectWithPageName:(NSString *)pageName;

@end

NS_ASSUME_NONNULL_END
