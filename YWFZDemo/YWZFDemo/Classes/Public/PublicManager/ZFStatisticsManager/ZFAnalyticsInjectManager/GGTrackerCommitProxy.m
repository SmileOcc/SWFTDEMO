//
//  GGTrackerCommitProxy.m
//  ZZZZZ
//
//  Created by YW on 2019/2/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "GGTrackerCommitProxy.h"
#import "Constants.h"
#import "ZFTrackerWhiteListManager.h"

@implementation GGTrackerCommitProxy

//点击事件
- (void)ctrlClicked:(NSString*)controlName
             onPage:(NSString*)pageName
               args:(NSDictionary*)args
{
    
}

//曝光事件
- (void)module:(NSString*)moduleName
  showedOnPage:(NSString*)pageName
      duration:(NSUInteger)duration
          args:(NSDictionary *)args
{
//    YWLog(@"\nmoduleName-%@\npageName-%@\nduration-%ld\nargs-%@", moduleName, pageName, duration, args);
//    id<ZFAnalyticsInjectProtocol>protocol = [[ZFTrackerWhiteListManager sharedInstance] gainAnalyticsInjectWithPageName:pageName];
//
//    if (protocol && [protocol respondsToSelector:@selector(module:pageName:duration:args:)]) {
//        [protocol module:moduleName pageName:pageName duration:duration args:args];
//    }
}

@end
