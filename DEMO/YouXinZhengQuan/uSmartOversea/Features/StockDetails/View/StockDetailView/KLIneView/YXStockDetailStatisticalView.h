//
//  YXStockDetailStatisticalView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

@class YXAnalysisStatisticData;
@class YXAnalysisStatisticPrice;
NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailStatisticalView : UIView

@property (nonatomic, strong) YXAnalysisStatisticData *statisData;

@property (nonatomic, assign) uint32_t preClose;
//加载成交统计数据
@property (nonatomic, copy, nullable) void (^loadStactisticDataBlock)(void);
//点击响应
@property (nonatomic, copy, nullable) void (^clickCallBack)(void);

@end


@interface YXStockDetailStatisticalCell : UITableViewCell

- (void)refreshWith:(YXAnalysisStatisticPrice *)statisPrice priceBase:(int64_t)priceBase pClose:(NSString *)pClose maxVolume:(int32_t)maxVolume;


@end

NS_ASSUME_NONNULL_END
