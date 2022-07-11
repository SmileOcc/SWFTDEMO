//
//  YXStockDetailMarketFinanicalChartView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXFinancialMarketDetaiModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXStockFinancialMarketType) {
    
    YXStockFinancialMarketTypeROE = 0,
    YXStockFinancialMarketTypeROA = 1,
    YXStockFinancialMarketTypePE = 2,
    YXStockFinancialMarketTypePB = 3,
    YXStockFinancialMarketTypeEPS = 4,
    YXStockFinancialMarketTypeBPS = 5,
    YXStockFinancialMarketTypeOCFPS = 6,
    YXStockFinancialMarketTypeGRPS = 7,
};

@interface YXStockDetailMarketFinanicalChartView : UIView

@property (nonatomic, strong) NSArray <YXFinancialMarketDetaiModel *> *list;

@property (nonatomic, copy) void (^clickItemBlock) (NSInteger selectIndex);

- (instancetype)initWithFrame:(CGRect)frame andMarket: (NSString *)market;

@property (nonatomic, copy) void (^clickTypeBtnCallBack)(NSInteger type);

@property (nonatomic, assign) NSInteger selectIndex;

@end

NS_ASSUME_NONNULL_END
