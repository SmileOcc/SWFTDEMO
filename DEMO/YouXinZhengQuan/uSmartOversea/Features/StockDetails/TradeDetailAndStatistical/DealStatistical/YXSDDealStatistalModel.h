//
//  YXSDDealStatistalModel.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/7/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXSDDealStatistalModel : NSObject
@property (nonatomic, strong) NSString *market;
@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger bidOrAskType;
///市场时段：0：盘中时段，1：开盘竞价(美股盘前)时段，2：收盘竞价(美股盘后)时段 ，3：全部时段
@property (nonatomic, assign) NSInteger marketTimeType;
@property (nonatomic, strong) NSString *tradeDay;
@property (nonatomic, assign) NSInteger sortType;
@property (nonatomic, assign) NSInteger sortMode;

@end

NS_ASSUME_NONNULL_END
