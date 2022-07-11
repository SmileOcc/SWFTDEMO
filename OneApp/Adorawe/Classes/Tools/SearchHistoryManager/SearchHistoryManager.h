//
//  SearchHistoryManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchHistoryManager : NSObject
+ (SearchHistoryManager *)singleton;
// 存取历史搜索记录
- (void)saveSearchHistory:(NSString *)searchWord;
- (NSArray *)loadLocalSearchHistory;
- (void)removeSearchHistory;

@end
