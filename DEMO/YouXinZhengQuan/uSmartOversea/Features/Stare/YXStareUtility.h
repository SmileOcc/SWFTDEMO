//
//  YXStareUtility.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXStareType) {
    YXStareTypeAll = 0, // 全部
    YXStareTypeNewStock = 1,  // 新股
    YXStareTypeIndustry = 2,  // 行业
    YXStareTypeIndex = 3,  // 指数
    YXStareTypeOptional = 4,  // 自选
    YXStareTypeHold = 5,  // 持仓
};

@interface YXStareUtility : NSObject

+ (NSInteger)getMarketSubType;

+ (void)resetMarketSubType:(NSInteger)subType;

+ (NSInteger)getHoldSubType;

+ (void)resetHoldSubType:(NSInteger)subType;

+ (YXStareType)getStareTypeWithType: (NSInteger)type andSubType: (NSInteger)subType;


@end

NS_ASSUME_NONNULL_END
