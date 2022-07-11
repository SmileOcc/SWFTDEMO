//
//  YXStareUtility.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareUtility.h"
#import <MMKV/MMKV.h>

@implementation YXStareUtility

+ (NSInteger)getMarketSubType {
    NSNumber *tickType = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"stareMarketSubType"];
    
    if (tickType == nil) {
        return 0;
    } else {
        return tickType.integerValue;
    }
}

+ (void)resetMarketSubType:(NSInteger)subType {
    [[MMKV defaultMMKV] setObject:@(subType) forKey:@"stareMarketSubType"];
}

+ (NSInteger)getHoldSubType {
    NSNumber *tickType = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"stareHoldSubType"];
    
    if (tickType == nil) {
        return 0;
    } else {
        return tickType.integerValue;
    }
}

+ (void)resetHoldSubType:(NSInteger)subType {
    [[MMKV defaultMMKV] setObject:@(subType) forKey:@"stareHoldSubType"];
    [[MMKV defaultMMKV] sync];
}

+ (YXStareType)getStareTypeWithType: (NSInteger)type andSubType: (NSInteger)subType {
    
    YXStareType value = YXStareTypeAll;
    if (type == 0 || type == 1 || type == 2) {
        if (subType == 0) {
            return YXStareTypeAll;
        } else {
//            if (type == 1) {
//                if (subType == 1) {
//                    return YXStareTypeIndustry;
//                } else {
//                    return YXStareTypeIndex;
//                }
//            } else {
//            }
            if (subType == 1) {
                return YXStareTypeNewStock;
            } else if (subType == 2) {
                return YXStareTypeIndustry;
            } else if (subType == 3) {
                return YXStareTypeIndex;
            }
        }
    } else {
        
        if (subType == 0) {
            return YXStareTypeOptional;
        } else {
            return YXStareTypeHold;
        }
        
    }
    
    return value;
}

@end
