//
//  STLTabbarModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTabbarModel.h"

@implementation STLTabbarModel

-(BOOL)isDownLoadTabbarIcon
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if ((time >= self.start_time.longLongValue && time <= self.end_time.longLongValue))
    {
        BOOL success = [[NSUserDefaults standardUserDefaults] boolForKey:TabbarDownLoadSuccess];
        return success && self.isCache;
    }
    return NO;
}

-(BOOL)isDownLoadNaviIcon
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if ((time >= self.start_time.longLongValue && time <= self.end_time.longLongValue))
    {
        BOOL success = [[NSUserDefaults standardUserDefaults] boolForKey:NaviBarDownLoadSuccess];
        return success && self.isCache;
    }
    return NO;
}

-(BOOL)isDownLoadAccountIcon
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if ((time >= self.start_time.longLongValue && time <= self.end_time.longLongValue))
    {
        BOOL success = [[NSUserDefaults standardUserDefaults] boolForKey:AccountDownLoadSuccess];
        return success && self.isCache;
    }
    return NO;
}

@end
