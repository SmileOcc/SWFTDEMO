//
//  YXKlineConfigModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKlineConfigModel.h"
#import <YYModel/YYModel.h>
#import "YXStockConfig.h"
#import "uSmartOversea-Swift.h"

@implementation YXKlineConfigModel

- (void)setDefault {

}

- (instancetype)init {
    if (self = [super init]) {
        [self setDefault];
    }

    return self;
}

- (YXKlineSettingModel *)settingModel {

    return [[YXKlineSettingModel alloc] init];
}


#pragma mark - 设置UI
- (void)setUI {

}

@end


@implementation YXKlineMAConfigModel

- (void)setDefault {
    self.ma_5 = 5;
    self.ma_20 = 20;
    self.ma_60 = 60;
    self.ma_120 = 120;
    self.ma_250 = 250;

    self.ma_5_isHidden = NO;
    self.ma_20_isHidden = NO;
    self.ma_60_isHidden = NO;
    self.ma_120_isHidden = NO;
    self.ma_250_isHidden = YES;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"ma_description"];

    NSArray *arr = @[
        @{
            @"isHidden": @(self.ma_5_isHidden),
            @"type": @(1),
            @"cycle": @(self.ma_5),
            @"title": @"MA1",
            @"placeholder": @"1～250"
        },
        @{
            @"isHidden": @(self.ma_20_isHidden),
            @"type": @(1),
            @"cycle": @(self.ma_20),
            @"title": @"MA2",
            @"placeholder": @"1～250"
        },
        @{
            @"isHidden": @(self.ma_60_isHidden),
            @"type": @(1),
            @"cycle": @(self.ma_60),
            @"title": @"MA3",
            @"placeholder": @"1～250"
        },
        @{
            @"isHidden": @(self.ma_120_isHidden),
            @"type": @(1),
            @"cycle": @(self.ma_120),
            @"title": @"MA4",
            @"placeholder": @"1～250"
        },
        @{
            @"isHidden": @(self.ma_250_isHidden),
            @"type": @(1),
            @"cycle": @(self.ma_250),
            @"title": @"MA5",
            @"placeholder": @"1～250"
        },
    ];

    NSArray *modelArr = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr];
    model.explain = title;
    model.firstArr = modelArr;
    model.indexType = YXStockMainAcessoryStatusMA;
    return model;
}

@end

@implementation YXKlineEMAConfigModel

- (void)setDefault {
    self.ema_5 = 5;
    self.ema_20 = 10;
    self.ema_60 = 20;

    self.ema_5_isHidden = NO;
    self.ema_20_isHidden = NO;
    self.ema_60_isHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"ema_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.ema_5),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"1"],
            @"placeholder": @"1～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.ema_20),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"2"],
            @"placeholder": @"1～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.ema_60),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"3"],
            @"placeholder": @"1～250"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.ema_5_isHidden),
            @"type": @(2),
            @"title": @"EMA1",
        },
        @{
            @"isHidden": @(self.ema_20_isHidden),
            @"type": @(2),
            @"title": @"EMA2",
        },
        @{
            @"isHidden": @(self.ema_60_isHidden),
            @"type": @(2),
            @"title": @"EMA3",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockMainAcessoryStatusEMA;
    return model;
}


@end

@implementation YXKlineBollConfigModel

- (void)setDefault {
    self.cycle_1 = 20;
    self.cycle_2 = 2;
    self.midIsHidden = NO;
    self.upperIsHidden = NO;
    self.lowerIsHidden = NO;
}


- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"boll_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"calculation_cycle"],
            @"placeholder": @"2～120"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [YXLanguageUtility kLangWithKey:@"multiple_of_standard_deviation"],
            @"placeholder": @"1～100"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.midIsHidden),
            @"type": @(2),
            @"title": @"MID",
        },
        @{
            @"isHidden": @(self.upperIsHidden),
            @"type": @(2),
            @"title": @"UPPER",
        },
        @{
            @"isHidden": @(self.lowerIsHidden),
            @"type": @(2),
            @"title": @"LOWER",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockMainAcessoryStatusBOLL;
    return model;
}


@end

@implementation YXKlineSarConfigModel

- (void)setDefault {
    self.cycle_1 = 4;
    self.cycle_2 = 2;
    self.cycle_3 = 20;

    self.bbIsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"sar_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"calculation_cycle"],
            @"placeholder": @"1～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [YXLanguageUtility kLangWithKey:@"stride_length"],
            @"placeholder": @"1～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_3),
            @"title": [YXLanguageUtility kLangWithKey:@"limit_value"],
            @"placeholder": @"1～100"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.bbIsHidden),
            @"type": @(2),
            @"title": @"BB",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockMainAcessoryStatusSAR;
    return model;
}


@end

@implementation YXKlineMAVOLConfigModel

- (void)setDefault {
    self.mavol_5 = 5;
    self.mavol_10 = 10;
    self.mavol_20 = 20;

    self.mavolIsHidden = NO;
    self.mavol_5_isHidden = NO;
    self.mavol_10_isHidden = NO;
    self.mavol_20_isHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"mavol_description"];

    NSArray *arr = @[
        @{
            @"isHidden": @(self.mavol_5_isHidden),
            @"type": @(1),
            @"cycle": @(self.mavol_5),
            @"title": @"MAVOL 1",
            @"placeholder": @"1～250"
        },
        @{
            @"isHidden": @(self.mavol_10_isHidden),
            @"type": @(1),
            @"cycle": @(self.mavol_10),
            @"title": @"MAVOL 2",
            @"placeholder": @"1～250"
        },
        @{
            @"isHidden": @(self.mavol_20_isHidden),
            @"type": @(1),
            @"cycle": @(self.mavol_20),
            @"title": @"MAVOL 3",
            @"placeholder": @"1～250"
        },
    ];

    NSArray *modelArr = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr];
    model.explain = title;
    model.firstArr = modelArr;
    model.indexType = YXStockSubAccessoryStatus_MAVOL;
    return model;
}

@end

@implementation YXKlineMACDConfigModel

- (void)setDefault {
    self.cycle_1 = 12;
    self.cycle_2 = 26;
    self.cycle_3 = 9;

    self.difIsHidden = NO;
    self.deaIsHidden = NO;
    self.macdIsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"macd_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"short_cycle"],
            @"placeholder": @"2～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [YXLanguageUtility kLangWithKey:@"long_cycle"],
            @"placeholder": @"2～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_3),
            @"title": [YXLanguageUtility kLangWithKey:@"moving_average_period"],
            @"placeholder": @"2～250"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.difIsHidden),
            @"type": @(2),
            @"title": @"DIF",
        },
        @{
            @"isHidden": @(self.deaIsHidden),
            @"type": @(2),
            @"title": @"DEA",
        },
        @{
            @"isHidden": @(self.macdIsHidden),
            @"type": @(2),
            @"title": @"MACD",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_MACD;
    return model;
}



@end

@implementation YXKlineKDJConfigModel

- (void)setDefault {
    self.cycle_1 = 9;
    self.cycle_2 = 3;
    self.cycle_3 = 3;

    self.K_IsHidden = NO;
    self.D_IsHidden = NO;
    self.J_IsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"kdj_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"calculation_cycle"],
            @"placeholder": @"2～90"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"1"],
            @"placeholder": @"2～30"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_3),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"2"],
            @"placeholder": @"2～30"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.K_IsHidden),
            @"type": @(2),
            @"title": @"K",
        },
        @{
            @"isHidden": @(self.D_IsHidden),
            @"type": @(2),
            @"title": @"D",
        },
        @{
            @"isHidden": @(self.J_IsHidden),
            @"type": @(2),
            @"title": @"J",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_KDJ;
    return model;
}

@end

@implementation YXKlineRSIConfigModel

- (void)setDefault {
    self.cycle_1 = 6;
    self.cycle_2 = 12;
    self.cycle_3 = 24;
    self.rsi_1_IsHidden = NO;
    self.rsi_2_IsHidden = NO;
    self.rsi_3_IsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"rsi_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"1"],
            @"placeholder": @"2～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"2"],
            @"placeholder": @"2～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_3),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"3"],
            @"placeholder": @"2～250"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.rsi_1_IsHidden),
            @"type": @(2),
            @"title": @"RSI1",
        },
        @{
            @"isHidden": @(self.rsi_2_IsHidden),
            @"type": @(2),
            @"title": @"RSI2",
        },
        @{
            @"isHidden": @(self.rsi_3_IsHidden),
            @"type": @(2),
            @"title": @"RSI3",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_RSI;
    return model;
}

@end

@implementation YXKlineARBRConfigModel

- (void)setDefault {
    self.cycle_1 = 26;
    self.ar_IsHidden = NO;
    self.br_IsHidden = NO;
}


- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"arbr_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"calculation_cycle"],
            @"placeholder": @"2～120"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.ar_IsHidden),
            @"type": @(2),
            @"title": @"AR",
        },
        @{
            @"isHidden": @(self.br_IsHidden),
            @"type": @(2),
            @"title": @"BR",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_ARBR;
    return model;
}


@end

@implementation YXKlineDMAConfigModel

- (void)setDefault {
    self.cycle_1 = 10;
    self.cycle_2 = 50;
    self.cycle_3 = 10;

    self.ddd_IsHidden = NO;
    self.dma_IsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"dma_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"short_cycle"],
            @"placeholder": @"2～60"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [YXLanguageUtility kLangWithKey:@"long_cycle"],
            @"placeholder": @"2～250"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_3),
            @"title": [YXLanguageUtility kLangWithKey:@"moving_average_period"],
            @"placeholder": @"2～100"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.ddd_IsHidden),
            @"type": @(2),
            @"title": @"DDD",
        },
        @{
            @"isHidden": @(self.dma_IsHidden),
            @"type": @(2),
            @"title": @"DDDMA",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_DMA;
    return model;
}


@end

@implementation YXKlineEMVConfigModel

- (void)setDefault {
    self.cycle_1 = 14;
    self.cycle_2 = 9;
    self.em_IsHidden = NO;
    self.emva_IsHidden = NO;
}


- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"emv_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"1"],
            @"placeholder": @"2～90"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"2"],
            @"placeholder": @"2～90"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.em_IsHidden),
            @"type": @(2),
            @"title": @"EMV",
        },
        @{
            @"isHidden": @(self.emva_IsHidden),
            @"type": @(2),
            @"title": @"EMVA",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_EMV;
    return model;
}


@end

@implementation YXKlineWRConfigModel

- (void)setDefault {
    self.cycle_1 = 10;
    self.cycle_2 = 6;

    self.wr_1_IsHidden = NO;
    self.wr_2_IsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"wr_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"calculation_cycle"],
            @"placeholder": @"2～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [YXLanguageUtility kLangWithKey:@"moving_average_period"],
            @"placeholder": @"2～100"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.wr_1_IsHidden),
            @"type": @(2),
            @"title": @"WR1",
        },
        @{
            @"isHidden": @(self.wr_2_IsHidden),
            @"type": @(2),
            @"title": @"WR2",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_WR;
    return model;
}


@end


@implementation YXKlineCRConfigModel

- (void)setDefault {
    self.cycle_1 = 26;
    self.cycle_2 = 6;
    self.cycle_3 = 10;
    self.cycle_4 = 20;
    self.cycle_5 = 60;

    self.cr_IsHidden = NO;
    self.ma_1_IsHidden = NO;
    self.ma_2_IsHidden = NO;
    self.ma_3_IsHidden = NO;
    self.ma_4_IsHidden = NO;
}

- (YXKlineSettingModel *)settingModel {

    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"cr_description"];

    NSArray *arr1 = @[
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_1),
            @"title": [YXLanguageUtility kLangWithKey:@"calculation_cycle"],
            @"placeholder": @"2～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_2),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"1"],
            @"placeholder": @"1～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_3),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"2"],
            @"placeholder": @"1～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_4),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"3"],
            @"placeholder": @"1～100"
        },
        @{
            @"type": @(0),
            @"cycle": @(self.cycle_5),
            @"title": [NSString stringWithFormat:@"%@ %@", [YXLanguageUtility kLangWithKey:@"moving_average_period"], @"4"],
            @"placeholder": @"1～100"
        },
    ];

    NSArray *modelArr1 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr1];

    NSArray *arr2 = @[
        @{
            @"isHidden": @(self.cr_IsHidden),
            @"type": @(2),
            @"title": @"CR",
        },
        @{
            @"isHidden": @(self.ma_1_IsHidden),
            @"type": @(2),
            @"title": @"MA1",
        },
        @{
            @"isHidden": @(self.ma_2_IsHidden),
            @"type": @(2),
            @"title": @"MA2",
        },
        @{
            @"isHidden": @(self.ma_3_IsHidden),
            @"type": @(2),
            @"title": @"MA3",
        },
        @{
            @"isHidden": @(self.ma_4_IsHidden),
            @"type": @(2),
            @"title": @"MA4",
        },
    ];

    NSArray *modelArr2 = [NSArray yy_modelArrayWithClass:[YXKlineSubConfigModel class] json:arr2];

    model.explain = title;
    model.firstArr = modelArr1;
    model.secondArr = modelArr2;
    model.indexType = YXStockSubAccessoryStatus_CR;
    return model;
}

@end


@implementation YXKlineUsmartConfigModel

- (YXKlineSettingModel *)settingModel {
    
    YXKlineSettingModel *model = [[YXKlineSettingModel alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"trend_signal_desc_tip"];    
    model.explain = title;
    model.indexType = YXStockMainAcessoryStatusUsmart;
    return model;
}

@end
