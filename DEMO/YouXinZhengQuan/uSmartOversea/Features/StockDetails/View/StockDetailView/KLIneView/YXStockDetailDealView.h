//
//  YXStockDetailDealView.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/12/18.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXTickData;
@class YXTick;

NS_ASSUME_NONNULL_BEGIN

//逐笔交易
@interface YXStockDetailDealHeaderView : UIView

@end


@interface YXStockDetailDealView : UIView

@property (nonatomic, strong) YXTickData *tickModel;
@property (nonatomic, strong) YXTick *tickSingleModel;
@property (nonatomic, assign) double pclose;
@property (nonatomic, assign) uint32_t lastPrice;
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
