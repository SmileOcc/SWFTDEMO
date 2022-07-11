//
//  YXStockDetailBTDealView.h
//  uSmartOversea
//
//  Created by youxin on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXTickData;
@class YXTick;

NS_ASSUME_NONNULL_BEGIN

//逐笔交易
@interface YXStockDetailBTDealHeaderView : UIView

@end


@interface YXStockDetailBTDealView : UIView

@property (nonatomic, strong) YXTickData *tickModel;
@property (nonatomic, assign) double pclose;
@property (nonatomic, assign) uint32_t priceBase;
@property (nonatomic, assign) NSInteger decimalCount;

@property (nonatomic, assign) BOOL isLandScape;
@property (nonatomic, strong) NSString *market;

@property (nonatomic, copy, nullable) void (^tickClickCallBack)(void);


@property (nonatomic, copy, nullable) void (^loadMoreCallBack)(NSString *start, NSString *tradeTime);

- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market isLandScape:(BOOL)isLandScape;

- (void)reloadWithMoreLoad:(BOOL)noMoreData;

- (void)invalidateTimer;

@end

NS_ASSUME_NONNULL_END
