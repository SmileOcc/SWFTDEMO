//
//  YXA_HKKLineLongPressView.h
//  uSmartOversea
//
//  Created by youxin on 2020/3/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXA_HKKLineView.h"

@class YXA_HKFundTrendKlineCustomModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXA_HKKLineLongPressView : UIView

@property (nonatomic, assign) NSInteger fundPriceBase;

@property (nonatomic, assign) NSInteger indexPriceBase;

@property (nonatomic, strong) YXA_HKFundTrendKlineCustomModel *model;

@property (nonatomic, assign) BOOL isShowTotalFundTrend;

@property (nonatomic, assign) BOOL isShowSHFundTrend;

@property (nonatomic, assign) BOOL isShowSZFundTrend;

@property (nonatomic, assign) BOOL isShowSHIndexLine;

@property (nonatomic, assign) BOOL isShowSZIndexLine;

//
- (instancetype)initWithFrame:(CGRect)frame andType:(YXA_HKKLineDirection)type;

@end

NS_ASSUME_NONNULL_END
