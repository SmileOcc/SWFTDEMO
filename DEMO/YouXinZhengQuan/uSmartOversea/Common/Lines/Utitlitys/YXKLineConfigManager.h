//
//  YXKilneConfigManager.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXKlineConfigModel.h"
#import "YXKlineCalculateTool.h"
#import "YXStockConfig.h"
#import "YXKlineSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXKLineConfigManager : NSObject

+ (instancetype)shareInstance;

// ma
@property (nonatomic, strong) YXKlineMAConfigModel *ma;
// ema
@property (nonatomic, strong) YXKlineEMAConfigModel *ema;
// boll
@property (nonatomic, strong) YXKlineBollConfigModel *boll;
// sar
@property (nonatomic, strong) YXKlineSarConfigModel *sar;
// mavol
@property (nonatomic, strong) YXKlineMAVOLConfigModel *mavol;
// macd
@property (nonatomic, strong) YXKlineMACDConfigModel *macd;
// kdj
@property (nonatomic, strong) YXKlineKDJConfigModel *kdj;
// rsi
@property (nonatomic, strong) YXKlineRSIConfigModel *rsi;
// arbr
@property (nonatomic, strong) YXKlineARBRConfigModel *arbr;
// dma
@property (nonatomic, strong) YXKlineDMAConfigModel *dma;
// emv
@property (nonatomic, strong) YXKlineEMVConfigModel *emv;
// wr
@property (nonatomic, strong) YXKlineWRConfigModel *wr;
// cr
@property (nonatomic, strong) YXKlineCRConfigModel *cr;
// usmart
@property (nonatomic, strong) YXKlineUsmartConfigModel *usmart;

// 主图参数
@property (nonatomic, strong) NSMutableArray <NSNumber *>*mainArr;
// 主图参数
@property (nonatomic, strong) NSMutableArray <NSString *>*mainTitleArr;
// 主图设置参数
@property (nonatomic, strong) NSMutableArray <NSString *>*mainSettingTitleArr;
// 副图参数
@property (nonatomic, strong) NSMutableArray <NSNumber *>*subArr;
// 副图参数
@property (nonatomic, strong) NSMutableArray <NSString *>*subTitleArr;
// 副图设置参数
@property (nonatomic, strong) NSMutableArray <NSString *>*subSettingTitleArr;

+ (NSString *)getTitleWithType:(NSInteger)type;

// 选中的主图参数
@property (nonatomic, assign) YXStockMainAcessoryStatus mainAccessory;
// 选中的副图参数
@property (nonatomic, assign) YXStockSubAccessoryStatus subAccessory;
// 选中的副图参数列表
@property (nonatomic, strong) NSMutableArray<NSNumber *> *subAccessoryArray;
// k线类型
@property (nonatomic, assign) YXRtLineType lineType;
// 复权类型
@property (nonatomic, assign) YXKlineAdjustType adjustType;
// K线线型类型
@property (nonatomic, assign) YXKlineStyleType styleType;

//是否展示现价线
@property (nonatomic, assign) BOOL showNowPrice;
//是否展示持仓成本线
@property (nonatomic, assign) BOOL showHoldPrice;
//是否展示成交买卖点
@property (nonatomic, assign) BOOL showBuySellPoint;
//是否展示公司行动点
@property (nonatomic, assign) BOOL showCompanyActionPoint;
//是否有趋势长盈的权限
@property (nonatomic, assign) BOOL hasUsmartLimit;
//5日分时盘中
@property (nonatomic, assign) BOOL fiveDaysTimelineIntra;
///一天分时的类型(记录)
@property (nonatomic, assign) YXTimeShareLineType timeShareType;

- (void)clean;

- (void)saveSoreArr;

- (void)saveData;

//保存多选的副图指标
- (void)saveSelectArr;

- (YXKlineSettingModel *)getSettingModelWithType:(NSInteger)type;

- (void)synConfigWithModel:(YXKlineSettingModel *)model;

- (YXKlineConfigModel *)getConfigWithModelWithType:(NSInteger)type;

+ (NSString *)getSettingTitleWithType:(NSInteger)type;

//指标说明展示
- (void)addExplainInfo:(UILabel *)label type:(NSInteger)type;

- (void)showExplainInfo:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
