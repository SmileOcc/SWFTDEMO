//
//  YXKlineConfigModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXKlineSettingModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface YXKlineConfigModel : NSObject

- (void)setDefault;

- (instancetype)init;

- (YXKlineSettingModel *)settingModel;

@end


@interface YXKlineMAConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger ma_5;
@property (nonatomic, assign) NSInteger ma_20;
@property (nonatomic, assign) NSInteger ma_60;
@property (nonatomic, assign) NSInteger ma_120;
@property (nonatomic, assign) NSInteger ma_250;

@property (nonatomic, assign) BOOL ma_5_isHidden;
@property (nonatomic, assign) BOOL ma_20_isHidden;
@property (nonatomic, assign) BOOL ma_60_isHidden;
@property (nonatomic, assign) BOOL ma_120_isHidden;
@property (nonatomic, assign) BOOL ma_250_isHidden;

@end


@interface YXKlineEMAConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger ema_5;
@property (nonatomic, assign) NSInteger ema_20;
@property (nonatomic, assign) NSInteger ema_60;


@property (nonatomic, assign) BOOL ema_5_isHidden;
@property (nonatomic, assign) BOOL ema_20_isHidden;
@property (nonatomic, assign) BOOL ema_60_isHidden;


@end



@interface YXKlineBollConfigModel : YXKlineConfigModel
@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;

@property (nonatomic, assign) BOOL midIsHidden;
@property (nonatomic, assign) BOOL upperIsHidden;
@property (nonatomic, assign) BOOL lowerIsHidden;

@end


@interface YXKlineSarConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;
@property (nonatomic, assign) NSInteger cycle_3;

@property (nonatomic, assign) BOOL bbIsHidden;

@end



@interface YXKlineMAVOLConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger mavol_5;
@property (nonatomic, assign) NSInteger mavol_10;
@property (nonatomic, assign) NSInteger mavol_20;

@property (nonatomic, assign) BOOL mavolIsHidden;
@property (nonatomic, assign) BOOL mavol_5_isHidden;
@property (nonatomic, assign) BOOL mavol_10_isHidden;
@property (nonatomic, assign) BOOL mavol_20_isHidden;

@end

@interface YXKlineMACDConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;
@property (nonatomic, assign) NSInteger cycle_3;

@property (nonatomic, assign) BOOL difIsHidden;
@property (nonatomic, assign) BOOL deaIsHidden;
@property (nonatomic, assign) BOOL macdIsHidden;

@end

@interface YXKlineKDJConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;
@property (nonatomic, assign) NSInteger cycle_3;

@property (nonatomic, assign) BOOL K_IsHidden;
@property (nonatomic, assign) BOOL D_IsHidden;
@property (nonatomic, assign) BOOL J_IsHidden;

@end

@interface YXKlineRSIConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;
@property (nonatomic, assign) NSInteger cycle_3;

@property (nonatomic, assign) BOOL rsi_1_IsHidden;
@property (nonatomic, assign) BOOL rsi_2_IsHidden;
@property (nonatomic, assign) BOOL rsi_3_IsHidden;

@end

@interface YXKlineARBRConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;

@property (nonatomic, assign) BOOL ar_IsHidden;
@property (nonatomic, assign) BOOL br_IsHidden;

@end

@interface YXKlineDMAConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;
@property (nonatomic, assign) NSInteger cycle_3;

@property (nonatomic, assign) BOOL ddd_IsHidden;
@property (nonatomic, assign) BOOL dma_IsHidden;

@end

@interface YXKlineEMVConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;

@property (nonatomic, assign) BOOL em_IsHidden;
@property (nonatomic, assign) BOOL emva_IsHidden;

@end

@interface YXKlineWRConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;

@property (nonatomic, assign) BOOL wr_1_IsHidden;
@property (nonatomic, assign) BOOL wr_2_IsHidden;

@end

@interface YXKlineCRConfigModel : YXKlineConfigModel

@property (nonatomic, assign) NSInteger cycle_1;
@property (nonatomic, assign) NSInteger cycle_2;
@property (nonatomic, assign) NSInteger cycle_3;
@property (nonatomic, assign) NSInteger cycle_4;
@property (nonatomic, assign) NSInteger cycle_5;

@property (nonatomic, assign) BOOL cr_IsHidden;
@property (nonatomic, assign) BOOL ma_1_IsHidden;
@property (nonatomic, assign) BOOL ma_2_IsHidden;
@property (nonatomic, assign) BOOL ma_3_IsHidden;
@property (nonatomic, assign) BOOL ma_4_IsHidden;

@end

@interface YXKlineUsmartConfigModel : YXKlineConfigModel


@end

NS_ASSUME_NONNULL_END
