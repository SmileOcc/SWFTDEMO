//
//  ZFPorpularSearchManager.m
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFPorpularSearchManager.h"
#import "ZFTimerManager.h"

@implementation ZFPorpularSearchManager

+ (instancetype)sharedManager {
    static ZFPorpularSearchManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFPorpularSearchManager alloc] init];
//        [[ZFTimerManager shareInstance] startTimer:@"PorpularSearch"];
    });
    
    return manager;
}

- (NSString *)getRandomPorpularSearchKey {
    return [self getRandomPorpularSearchKeyWithArray:self.homePorpularSearchArray];
}

- (NSString *)getRandomPorpularSearchKeyWithArray:(NSArray *)porpularArray {
    NSString *searchKey = @"";
    NSInteger count = porpularArray.count;
    if (count > 0) {
        int index = arc4random() % count;
        if (index < count) {
            searchKey = porpularArray[index];
        }
    }
    return searchKey;
}

@end
