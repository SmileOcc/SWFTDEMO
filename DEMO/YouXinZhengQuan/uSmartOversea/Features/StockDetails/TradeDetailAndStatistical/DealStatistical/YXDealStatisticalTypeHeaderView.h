//
//  YXDealStatisticalTypeHeaderView.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/7/15.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStockDetailUtility.h"
NS_ASSUME_NONNULL_BEGIN

@class YXTapButtonView;
@interface YXDealStatisticalTypeHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMarket:(NSString *)market;

@property (nonatomic, copy) void (^refreshDataCallBack)(NSInteger bidOrAskType, NSInteger marketTimeType, NSString *tradeDay);

@property (nonatomic, strong) NSArray *tradeDateList;

//// 美股盘前盘后数据专用, 更改默认的市场类型, 只改UI, 不回调刷新
- (void)updateMarketType:(YXTimeShareLineType)timeLineType;

@property (nonatomic, strong) YXTapButtonView *tapButtonView;


@end


@interface YXDealStatisticalTypeBtn: QMUIButton

@end

NS_ASSUME_NONNULL_END
