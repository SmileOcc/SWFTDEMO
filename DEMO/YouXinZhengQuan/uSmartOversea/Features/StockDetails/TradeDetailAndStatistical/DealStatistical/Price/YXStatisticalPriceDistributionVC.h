//
//  YXStatisticalPriceDistributionVC.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface YXStatisticalPriceDistributionVC : YXViewController

- (void)loadStatisticalData;

- (void)refreshWithBidOrAskType: (NSInteger)bidOrAskType andMarketTimeType: (NSInteger)marketTimeType andTradeDay:(NSString *)tradeDay;


@end

NS_ASSUME_NONNULL_END
