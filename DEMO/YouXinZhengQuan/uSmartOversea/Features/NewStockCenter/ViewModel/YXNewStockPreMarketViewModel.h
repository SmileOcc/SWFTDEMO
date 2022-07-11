//
//  YXNewStockPreMarketViewModel.h
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/19.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXTableViewModel.h"
//#import "uSmartOversea-Swift.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXNewStockStatus) {
    
    YXNewStockStatusPurchase = 0,
    YXNewStockStatusPreMarket = 1,
    YXNewStockStatusMarketed = 2
    
};

typedef void(^AllNewStockBlock)(NSInteger total);
typedef void(^HasGrayBlock)(BOOL has);

@interface YXNewStockPreMarketViewModel : YXTableViewModel

@property (nonatomic, assign) YXNewStockStatus stockStatus; //Tab页类别(0-认购中，1-待上市)

@property (nonatomic, copy) NSString *orderBy;//排序字段名(least_amount-起购资金,end_time-认购截止日期,listing_time-上市交易日,)
@property (nonatomic, assign) NSInteger orderDirection; //排序方式(0-降序,1-升序，默认1)
@property (nonatomic, assign) NSInteger total;

@property (nonatomic, assign) BOOL financingAccountDiff; //是否区分高级账户

@property (nonatomic, assign) int exchangeType;

@property (nonatomic, copy) AllNewStockBlock totalNewStockAmount;
@property (nonatomic, copy) HasGrayBlock hasGrayBlock;




@end

NS_ASSUME_NONNULL_END
