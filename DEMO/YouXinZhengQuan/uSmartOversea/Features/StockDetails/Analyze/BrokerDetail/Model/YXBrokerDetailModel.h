//
//  YXBrokerDetailModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface YXBrokerDetailSubModel : NSObject

@property (nonatomic, strong) NSString *date;
//持股比例
@property (nonatomic, assign) int64_t holdRatio;
//所持量
@property (nonatomic, assign) int64_t holdVolume;
//变化比例
@property (nonatomic, assign) int64_t changeRatio;
//变化量
@property (nonatomic, assign) int64_t changeVolume;
//开盘价
@property (nonatomic, assign) int64_t open;
//收盘价
@property (nonatomic, assign) int64_t close;
//昨收价
@property (nonatomic, assign) int64_t preClose;

@property (nonatomic, strong) NSNumber *index;

@property (nonatomic, assign) int pctchng;


// 卖空
//沽空成交数量(股)
@property (nonatomic, assign) int64_t shortShares;
//成交数量(股)
@property (nonatomic, assign) int64_t volume;
//沽空成交比例,真实值除以10000
@property (nonatomic, assign) int64_t shortSharesPct;

// 港股通比例
//持股数量(股)
@property (nonatomic, assign) int64_t scmHoldings;
//净买卖股数
@property (nonatomic, assign) int64_t netPurchaseAmount;
//持股占比
//@property (nonatomic, assign) int64_t holdRatio;

@end



@interface YXBrokerDetailModel : NSObject

@property (nonatomic, strong) NSArray <YXBrokerDetailSubModel *> *list;

@property (nonatomic, assign) NSInteger priceBase;
//最近行情时间
@property (nonatomic, strong) NSString *latestTime;
//翻页使用，请求下一页时候，需要带上这个值
@property (nonatomic, strong) NSString *nextPageRef;
//bool值，是否有下一页数据
@property (nonatomic, assign) BOOL hasMore;

@end

NS_ASSUME_NONNULL_END
