//
//  YXKlineCalculateTool.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/10/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YXKLineData;

NS_ASSUME_NONNULL_BEGIN

@interface YXKlineCalculateTool : NSObject

- (void)calAccessoryValue:(YXKLineData *)kline;

@property (nonatomic, assign) BOOL isHKIndex;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
