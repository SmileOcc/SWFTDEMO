//
//  SearchHistoryManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "SearchHistoryManager.h"

@implementation SearchHistoryManager

+ (SearchHistoryManager *)singleton
{
    static SearchHistoryManager *sharedInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SearchHistoryManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - searchHistory
- (void)saveSearchHistory:(NSString *)searchWord
{
    NSMutableArray *tempArr = [NSMutableArray array];
    
    [tempArr addObjectsFromArray:[self loadLocalSearchHistory]];
    
    // 判断搜索关键字是否一样
    for (NSString *str in tempArr)
    {
        if ([searchWord isEqualToString:str])  // 先移除相同的关键字
        {
            [tempArr removeObject:str];
            break;
        }
    }
    [tempArr insertObject:searchWord atIndex:0];
    if (tempArr.count > 10)
    {
        //        tempArr = (NSMutableArray *)[tempArr subarrayWithRange:NSMakeRange(0, 10)];
        [tempArr removeLastObject];   // 只保存10条数据
    }
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us setObject:tempArr forKey:@"searchHistory"];
    [us synchronize];
}

- (NSArray *)loadLocalSearchHistory
{
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [us objectForKey:@"searchHistory"];
    return arr;
}

- (void)removeSearchHistory
{
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us removeObjectForKey:@"searchHistory"];
    [us synchronize];
}

@end
