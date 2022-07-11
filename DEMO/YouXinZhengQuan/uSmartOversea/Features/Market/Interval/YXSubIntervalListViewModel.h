//
//  YXSubIntervalListViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockListViewModel.h"

typedef NS_ENUM(NSUInteger, YXMarketSortType) {
    YXMarketSortTypeRoc     = 1,
    YXMarketSortTypeNow     = 2,
    YXMarketSortTypeClosed  = 3,
    YXMarketSortTypeVolume  = 4,
    YXMarketSortTypeAmount  = 5,
    YXMarketSortTypeOpen    = 6,
    YXMarketSortTypeHigh    = 7,
    YXMarketSortTypeLow     = 8,
    YXMarketSortTypeSymbol  = 9,
    YXMarketSortTypeTurnoverRate  = 10,
    
    
    
    YXMarketSortTypePe      = 11,
    YXMarketSortTypeChange  = 12,
    YXMarketSortTypeAmp     = 14,
    YXMarketSortTypeNetInflow     = 16, // 资金净流入
    YXMarketSortTypeMarketValue   = 20,
    YXMarketSortTypePb            = 21,
    YXMarketSortTypeVolumeRatio   = 40,
    YXMarketSortTypeAccer3        = 60, // 3分钟涨速
    YXMarketSortTypeDividendYield = 61, // 股息率
    YXMarketSortTypeMainInflow    = 62, // 主力净流入
    YXMarketSortTypeMarginRatio   = 65, // 融资抵押率
    YXMarketSortTypeBail          = 66, // 最低保证金
    YXMarketSortTypeGearingRatio  = 74, // 杠杆比例
    YXMarketSortTypeAHSpread      = 9999, // ah股溢价（此值接口提供方说随意，因为AH股只有这一个排序指标，他们只需要知道是升序还是降序即可）
    
    YXMarketSortTypeAccer5  = 15, //5分钟涨速
    YXMarketSortTypePctChg5day = 67, //5日历史涨幅
    YXMarketSortTypePctChg10day  = 68, //10日涨幅
    YXMarketSortTypePctChg30day  = 69, //30日涨幅
    YXMarketSortTypePctChg60day  = 70, //60日涨幅
    YXMarketSortTypePctChg120day  = 71, //120日涨幅
    YXMarketSortTypePctChg250day  = 72, //250日涨幅
    YXMarketSortTypePctChg1year  = 73, //1年涨幅
};


NS_ASSUME_NONNULL_BEGIN

@interface YXSubIntervalListViewModel : YXStockListViewModel

@property (nonatomic, assign) YXMarketSortType sortType;

@property (nonatomic, assign) NSInteger direction;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, assign) NSInteger selectType;


@end

NS_ASSUME_NONNULL_END
