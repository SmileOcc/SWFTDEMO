//
//  YXStockDetailTickAndStatisticalView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXTickData;
@class YXAnalysisStatisticData;
@class YXStockDetailDealView;
@class YXStockDetailStatisticalView;

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailTickAndStatisticalView : UIView

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSString *market;

//tick
@property (nonatomic, strong) YXTickData *tickModel;

@property (nonatomic, strong) YXAnalysisStatisticData *statisData;

@property (nonatomic, assign) uint32_t preClose;

@property (nonatomic, strong) YXStockDetailDealView *dealView; //逐笔交易明细

@property (nonatomic, strong) YXStockDetailStatisticalView *statisticalView;

//是否是期权
@property (nonatomic, assign) BOOL isOptionStock;

- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market;

@end

NS_ASSUME_NONNULL_END
