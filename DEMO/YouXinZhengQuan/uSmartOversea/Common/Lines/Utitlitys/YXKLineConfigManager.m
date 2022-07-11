//
//  YXKilneConfigManager.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKLineConfigManager.h"
#import "YXStockDetailUtility.h"
#import <MMKV/MMKV.h>
#import "uSmartOversea-Swift.h"
#import "UIGestureRecognizer+YYAdd.h"

@implementation YXKLineConfigManager

+ (instancetype)shareInstance {

    static YXKLineConfigManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSData *data = [[MMKV defaultMMKV] getDataForKey:@"YXKLineConfigManager"];
        YXKLineConfigManager *model = nil;
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
            if (dic) {
                model = [YXKLineConfigManager yy_modelWithDictionary:dic];
                if (dic[@"fiveDaysTimelineIntra"] == nil)
                {
                    model.fiveDaysTimelineIntra = NO;
                }
                if (dic[@"showCompanyActionPoint"] == nil) {
                    model.showCompanyActionPoint = YES;
                }
            }
        }

        if (model) {
            _shareInstance = model;
        } else {
            _shareInstance = [[YXKLineConfigManager alloc] init];

            _shareInstance.ma = [[YXKlineMAConfigModel alloc] init];
            _shareInstance.ema = [[YXKlineEMAConfigModel alloc] init];
            _shareInstance.boll = [[YXKlineBollConfigModel alloc] init];
            _shareInstance.sar = [[YXKlineSarConfigModel alloc] init];
            _shareInstance.mavol = [[YXKlineMAVOLConfigModel alloc] init];
            _shareInstance.macd = [[YXKlineMACDConfigModel alloc] init];
            _shareInstance.kdj = [[YXKlineKDJConfigModel alloc] init];
            _shareInstance.rsi = [[YXKlineRSIConfigModel alloc] init];
            _shareInstance.arbr = [[YXKlineARBRConfigModel alloc] init];
            _shareInstance.dma = [[YXKlineDMAConfigModel alloc] init];
            _shareInstance.emv = [[YXKlineEMVConfigModel alloc] init];
            _shareInstance.wr = [[YXKlineWRConfigModel alloc] init];
            _shareInstance.cr = [[YXKlineCRConfigModel alloc] init];
            _shareInstance.usmart = [[YXKlineUsmartConfigModel alloc] init];
            _shareInstance->_mainAccessory = [YXStockDetailUtility kLineMainAccessory];
            _shareInstance->_subAccessory = [YXStockDetailUtility kLineSubAccessory];
            _shareInstance->_lineType = [YXStockDetailUtility rtLineType];
            _shareInstance->_adjustType = [YXStockDetailUtility getKLineAdjustType];
            _shareInstance->_styleType = YXKlineStyleTypeSolid;
            _shareInstance->_showNowPrice = YES;
            _shareInstance->_showHoldPrice = YES;
            _shareInstance->_showBuySellPoint = YES;
            _shareInstance->_fiveDaysTimelineIntra = NO;
            _shareInstance->_showCompanyActionPoint = YES;
        }

        NSArray *mainArr = [[MMKV defaultMMKV] getObjectOfClass:[NSArray class] forKey:@"mainAccessoryArr"];
        if (mainArr.count > 0) {
            _shareInstance.mainArr = [NSMutableArray arrayWithArray:mainArr];
        }
        // 兼容老版本没有趋势长盈
//        if (_shareInstance.mainArr.count == 4) {
//            [_shareInstance.mainArr insertObject:@(YXStockMainAcessoryStatusUsmart) atIndex:1];
//        }
        if (_shareInstance.usmart == nil) {
            _shareInstance.usmart = [[YXKlineUsmartConfigModel alloc] init];
        }
        NSArray *subArr = [[MMKV defaultMMKV] getObjectOfClass:[NSArray class] forKey:@"subAccessoryArr"];
        if (subArr.count > 0) {
            _shareInstance.subArr = [NSMutableArray arrayWithArray:subArr];
        }

        NSArray *selectSubArr = [[MMKV defaultMMKV] getObjectOfClass:[NSArray class] forKey:@"selectSubAccessoryArr"];
        if (selectSubArr) {
            _shareInstance.subAccessoryArray = [NSMutableArray arrayWithArray:selectSubArr];
        } else {
            _shareInstance.subAccessoryArray = [NSMutableArray arrayWithArray:@[@(_shareInstance.subAccessory)]];
        }
        // 分时类型默认是盘中
        _shareInstance.timeShareType = YXTimeShareLineTypeIntra;
    });

    return _shareInstance;
}

- (void)setAdjustType:(YXKlineAdjustType)adjustType {
    _adjustType = adjustType;
    //    [[MMKV defaultMMKV] setObject:[NSString stringWithFormat:@"%ld", adjustType] forKey:@"adjustType"];
    [self saveData];
}

- (void)setStyleType:(YXKlineStyleType)styleType {
    _styleType = styleType;
    [self saveData];
}

- (void)setMainAccessory:(YXStockMainAcessoryStatus)mainAccessory {
    _mainAccessory = mainAccessory;
    [self saveData];
    //    [[MMKV defaultMMKV] setObject:@(mainAccessory) forKey:@"kLineMainAccessory"];
}

- (void)setSubAccessory:(YXStockSubAccessoryStatus)subAccessory {
    _subAccessory = subAccessory;
    [self saveData];
    //    [[MMKV defaultMMKV] setObject:@(subAccessory) forKey:@"kLineSubAccessory"];
}

- (void)setLineType:(YXRtLineType)lineType {
    _lineType = lineType;
    [self saveData];
    //    [[MMKV defaultMMKV] setObject:@(lineType) forKey:@"rtLineType"];
}

- (void)setShowNowPrice:(BOOL)showNowPrice {
    _showNowPrice = showNowPrice;
    [self saveData];
}

- (void)setShowHoldPrice:(BOOL)showHoldPrice {
    _showHoldPrice = showHoldPrice;
    [self saveData];
}

- (void)setShowBuySellPoint:(BOOL)showBuySellPoint {
    _showBuySellPoint = showBuySellPoint;
    [self saveData];
}

- (void)setFiveDaysTimelineIntra:(BOOL)fiveDaysTimelineIntra {
    _fiveDaysTimelineIntra = fiveDaysTimelineIntra;
    [self saveData];
}

- (void)setShowCompanyActionPoint:(BOOL)showCompanyActionPoint {
    _showCompanyActionPoint = showCompanyActionPoint;
    [self saveData];
}


+ (NSString *)getTitleWithType:(NSInteger)type {
    NSString *str = @"";
    switch (type) {
        case YXKlineAdjustTypeNotAdjust:
            str = [YXLanguageUtility kLangWithKey:@"stock_detail_adjusted_none"];
            break;
        case YXKlineAdjustTypePreAdjust:
            str = [YXLanguageUtility kLangWithKey:@"stock_detail_adjusted_forward"];
            break;
        case YXKlineAdjustTypeAfterAdjust:
            str = [YXLanguageUtility kLangWithKey:@"stock_detail_adjusted_backward"];
            break;
        case YXKlineCYQTypeNormal:
            str = [YXLanguageUtility kLangWithKey:@"chips_simple"];
            break;
        case YXStockMainAcessoryStatusMA:
            str = @"MA";
            break;
        case YXStockMainAcessoryStatusEMA:
            str = @"EMA";
            break;
        case YXStockMainAcessoryStatusBOLL:
            str = @"BOLL";
            break;
        case YXStockMainAcessoryStatusSAR:
            str = @"SAR";
            break;
        case YXStockSubAccessoryStatus_MAVOL:
            str = @"MAVOL";
            break;
        case YXStockSubAccessoryStatus_MACD:
            str = @"MACD";
            break;
        case YXStockSubAccessoryStatus_KDJ:
            str = @"KDJ";
            break;
        case YXStockSubAccessoryStatus_RSI:
            str = @"RSI";
            break;
        case YXStockSubAccessoryStatus_ARBR:
            str = @"ARBR";
            break;
        case YXStockSubAccessoryStatus_DMA:
            str = @"DMA";
            break;
        case YXStockSubAccessoryStatus_EMV:
            str = @"EMV";
            break;
        case YXStockSubAccessoryStatus_WR:
            str = @"WR";
            break;
        case YXStockSubAccessoryStatus_CR:
            str = @"CR";
            break;
        case YXStockMainAcessoryStatusUsmart:
            str = @"TREND";
            if ([YXUserManager curLanguage] == YXLanguageTypeCN) {
                str = @"趋势长盈";
            }
            break;
        default:
            break;
    }

    return str;
}

+ (NSString *)getSettingTitleWithType:(NSInteger)type {
    NSString *str = @"";
    switch (type) {
        case YXStockMainAcessoryStatusMA:
            str = [YXLanguageUtility kLangWithKey:@"ma_tech"];
            break;
        case YXStockMainAcessoryStatusEMA:
            str = [YXLanguageUtility kLangWithKey:@"ema_tech"];
            break;
        case YXStockMainAcessoryStatusBOLL:
            str = [YXLanguageUtility kLangWithKey:@"boll_tech"];
            break;
        case YXStockMainAcessoryStatusSAR:
            str = [YXLanguageUtility kLangWithKey:@"sar_tech"];
            break;
        case YXStockSubAccessoryStatus_MAVOL:
            str = [YXLanguageUtility kLangWithKey:@"mavol_tech"];
            break;
        case YXStockSubAccessoryStatus_MACD:
            str = [YXLanguageUtility kLangWithKey:@"macd_tech"];
            break;
        case YXStockSubAccessoryStatus_KDJ:
            str = [YXLanguageUtility kLangWithKey:@"kdj_tech"];
            break;
        case YXStockSubAccessoryStatus_RSI:
            str = [YXLanguageUtility kLangWithKey:@"rsi_tech"];
            break;
        case YXStockSubAccessoryStatus_ARBR:
            str = [YXLanguageUtility kLangWithKey:@"arbr_tech"];
            break;
        case YXStockSubAccessoryStatus_DMA:
            str = [YXLanguageUtility kLangWithKey:@"dma_tech"];
            break;
        case YXStockSubAccessoryStatus_EMV:
            str = [YXLanguageUtility kLangWithKey:@"emv_tech"];
            break;
        case YXStockSubAccessoryStatus_WR:
            str = [YXLanguageUtility kLangWithKey:@"wr_tech"];
            break;
        case YXStockSubAccessoryStatus_CR:
            str = [YXLanguageUtility kLangWithKey:@"cr_tech"];
            break;
        case YXStockMainAcessoryStatusUsmart:
            str = [YXLanguageUtility kLangWithKey:@"trend_signal_tech"];
            break;
        default:
            break;
    }

    return str;
}

- (NSMutableArray<NSNumber *> *)mainArr {
    if (_mainArr == nil) {
        NSArray *arr = @[@(YXStockMainAcessoryStatusMA), @(YXStockMainAcessoryStatusEMA), @(YXStockMainAcessoryStatusBOLL), @(YXStockMainAcessoryStatusSAR)]; //@(YXStockMainAcessoryStatusUsmart),
        _mainArr = [NSMutableArray arrayWithArray:arr];
    }
    return _mainArr;
}

- (NSMutableArray<NSNumber *> *)subArr {
    if (_subArr == nil) {
        NSArray *arr = @[@(YXStockSubAccessoryStatus_ARBR), @(YXStockSubAccessoryStatus_DMA), @(YXStockSubAccessoryStatus_MACD), @(YXStockSubAccessoryStatus_KDJ), @(YXStockSubAccessoryStatus_MAVOL), @(YXStockSubAccessoryStatus_RSI), @(YXStockSubAccessoryStatus_EMV), @(YXStockSubAccessoryStatus_WR), @(YXStockSubAccessoryStatus_CR)];
        _subArr = [NSMutableArray arrayWithArray:arr];
    }
    return _subArr;
}

- (NSMutableArray<NSString *> *)mainTitleArr {
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NSNumber *number in self.mainArr) {
        [titleArr addObject:[YXKLineConfigManager getTitleWithType:number.integerValue]];
    }
    return titleArr;
}

- (NSMutableArray<NSString *> *)subTitleArr {
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NSNumber *number in self.subArr) {
        [titleArr addObject:[YXKLineConfigManager getTitleWithType:number.integerValue]];
    }
    return titleArr;
}

- (NSMutableArray<NSString *> *)mainSettingTitleArr {
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NSNumber *number in self.mainArr) {
        [titleArr addObject:[YXKLineConfigManager getSettingTitleWithType:number.integerValue]];
    }
    return titleArr;
}

- (NSMutableArray<NSString *> *)subSettingTitleArr {
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NSNumber *number in self.subArr) {
        [titleArr addObject:[YXKLineConfigManager getSettingTitleWithType:number.integerValue]];
    }
    return titleArr;
}

- (void)clean {

    self.adjustType = YXKlineAdjustTypePreAdjust;
    self.styleType = YXKlineStyleTypeSolid;
    NSArray *arr1 = @[@(YXStockMainAcessoryStatusMA),  @(YXStockMainAcessoryStatusEMA), @(YXStockMainAcessoryStatusBOLL), @(YXStockMainAcessoryStatusSAR)]; //@(YXStockMainAcessoryStatusUsmart),
    _mainArr = [NSMutableArray arrayWithArray:arr1];

    NSArray *arr2 = @[@(YXStockSubAccessoryStatus_ARBR), @(YXStockSubAccessoryStatus_DMA), @(YXStockSubAccessoryStatus_MACD), @(YXStockSubAccessoryStatus_KDJ), @(YXStockSubAccessoryStatus_MAVOL), @(YXStockSubAccessoryStatus_RSI), @(YXStockSubAccessoryStatus_EMV), @(YXStockSubAccessoryStatus_WR), @(YXStockSubAccessoryStatus_CR)];
    _subArr = [NSMutableArray arrayWithArray:arr2];

    // 清除子指标
//    for (NSNumber *number in arr1) {
//        [[self getConfigWithModelWithType:number.integerValue] setDefault];
//    }
//
//    for (NSNumber *number in arr2) {
//        [[self getConfigWithModelWithType:number.integerValue] setDefault];
//    }
}

- (void)saveSoreArr {
    if (self.mainArr) {
        [[MMKV defaultMMKV] setObject:self.mainArr forKey:@"mainAccessoryArr"];
    }
    if (self.subArr) {
        [[MMKV defaultMMKV] setObject:self.subArr forKey:@"subAccessoryArr"];
    }
}

- (void)saveSelectArr {
    [[MMKV defaultMMKV] setObject:self.subAccessoryArray forKey:@"selectSubAccessoryArr"];
}

- (YXKlineSettingModel *)getSettingModelWithType:(NSInteger)type {

    YXKlineSettingModel *model = nil;
    switch (type) {
        case YXStockMainAcessoryStatusMA:
            model = self.ma.settingModel;
            break;
        case YXStockMainAcessoryStatusEMA:
            model = self.ema.settingModel;
            break;
        case YXStockMainAcessoryStatusBOLL:
            model = self.boll.settingModel;
            break;
        case YXStockMainAcessoryStatusSAR:
            model = self.sar.settingModel;
            break;
        case YXStockSubAccessoryStatus_MAVOL:
            model = self.mavol.settingModel;
            break;
        case YXStockSubAccessoryStatus_MACD:
            model = self.macd.settingModel;
            break;
        case YXStockSubAccessoryStatus_KDJ:
            model = self.kdj.settingModel;
            break;
        case YXStockSubAccessoryStatus_RSI:
            model = self.rsi.settingModel;
            break;
        case YXStockSubAccessoryStatus_ARBR:
            model = self.arbr.settingModel;
            break;
        case YXStockSubAccessoryStatus_DMA:
            model = self.dma.settingModel;
            break;
        case YXStockSubAccessoryStatus_EMV:
            model = self.emv.settingModel;
            break;
        case YXStockSubAccessoryStatus_WR:
            model = self.wr.settingModel;
            break;
        case YXStockSubAccessoryStatus_CR:
            model = self.cr.settingModel;
            break;
        default:
            break;
    }

    return model;
}


- (void)synConfigWithModel:(YXKlineSettingModel *)model {

    switch (model.indexType) {
        case YXStockMainAcessoryStatusMA:
            if (model.firstArr.count == 5) {
                self.ma.ma_5_isHidden = model.firstArr[0].isHidden;
                self.ma.ma_20_isHidden = model.firstArr[1].isHidden;
                self.ma.ma_60_isHidden = model.firstArr[2].isHidden;
                self.ma.ma_120_isHidden = model.firstArr[3].isHidden;
                self.ma.ma_250_isHidden = model.firstArr[4].isHidden;

                self.ma.ma_5 = model.firstArr[0].cycle;
                self.ma.ma_20 = model.firstArr[1].cycle;
                self.ma.ma_60 = model.firstArr[2].cycle;
                self.ma.ma_120 = model.firstArr[3].cycle;
                self.ma.ma_250 = model.firstArr[4].cycle;
            }
            break;
        case YXStockMainAcessoryStatusEMA:
            if (model.firstArr.count == 3 && model.secondArr.count == 3) {
                self.ema.ema_5 = model.firstArr[0].cycle;
                self.ema.ema_20 = model.firstArr[1].cycle;
                self.ema.ema_60 = model.firstArr[2].cycle;

                self.ema.ema_5_isHidden = model.secondArr[0].isHidden;
                self.ema.ema_20_isHidden = model.secondArr[1].isHidden;
                self.ema.ema_60_isHidden = model.secondArr[2].isHidden;
            }
            break;
        case YXStockMainAcessoryStatusBOLL:
            if (model.firstArr.count == 2 && model.secondArr.count == 3) {
                self.boll.cycle_1 = model.firstArr[0].cycle;
                self.boll.cycle_2 = model.firstArr[1].cycle;

                self.boll.midIsHidden = model.secondArr[0].isHidden;
                self.boll.upperIsHidden = model.secondArr[1].isHidden;
                self.boll.lowerIsHidden = model.secondArr[2].isHidden;
            }
            break;
        case YXStockMainAcessoryStatusSAR:
            if (model.firstArr.count == 3 && model.secondArr.count == 1) {
                self.sar.cycle_1 = model.firstArr[0].cycle;
                self.sar.cycle_2 = model.firstArr[1].cycle;
                self.sar.cycle_3 = model.firstArr[2].cycle;

                self.sar.bbIsHidden = model.secondArr[0].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_MAVOL:
            if (model.firstArr.count == 3) {
                self.mavol.mavol_5_isHidden = model.firstArr[0].isHidden;
                self.mavol.mavol_10_isHidden = model.firstArr[1].isHidden;
                self.mavol.mavol_20_isHidden = model.firstArr[2].isHidden;

                self.mavol.mavol_5 = model.firstArr[0].cycle;
                self.mavol.mavol_10 = model.firstArr[1].cycle;
                self.mavol.mavol_20 = model.firstArr[2].cycle;
            }
            break;
        case YXStockSubAccessoryStatus_MACD:
            if (model.firstArr.count == 3 && model.secondArr.count == 3) {
                self.macd.cycle_1 = model.firstArr[0].cycle;
                self.macd.cycle_2 = model.firstArr[1].cycle;
                self.macd.cycle_3 = model.firstArr[2].cycle;

                self.macd.difIsHidden = model.secondArr[0].isHidden;
                self.macd.deaIsHidden = model.secondArr[1].isHidden;
                self.macd.macdIsHidden = model.secondArr[2].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_KDJ:
            if (model.firstArr.count == 3 && model.secondArr.count == 3) {
                self.kdj.cycle_1 = model.firstArr[0].cycle;
                self.kdj.cycle_2 = model.firstArr[1].cycle;
                self.kdj.cycle_3 = model.firstArr[2].cycle;

                self.kdj.K_IsHidden = model.secondArr[0].isHidden;
                self.kdj.D_IsHidden = model.secondArr[1].isHidden;
                self.kdj.J_IsHidden = model.secondArr[2].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_RSI:
            if (model.firstArr.count == 3 && model.secondArr.count == 3) {
                self.rsi.cycle_1 = model.firstArr[0].cycle;
                self.rsi.cycle_2 = model.firstArr[1].cycle;
                self.rsi.cycle_3 = model.firstArr[2].cycle;

                self.rsi.rsi_1_IsHidden = model.secondArr[0].isHidden;
                self.rsi.rsi_2_IsHidden = model.secondArr[1].isHidden;
                self.rsi.rsi_3_IsHidden = model.secondArr[2].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_ARBR:
            if (model.firstArr.count == 1 && model.secondArr.count == 2) {
                self.arbr.cycle_1 = model.firstArr[0].cycle;

                self.arbr.ar_IsHidden = model.secondArr[0].isHidden;
                self.arbr.br_IsHidden = model.secondArr[1].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_DMA:
            if (model.firstArr.count == 3 && model.secondArr.count == 2) {
                self.dma.cycle_1 = model.firstArr[0].cycle;
                self.dma.cycle_2 = model.firstArr[1].cycle;
                self.dma.cycle_3 = model.firstArr[2].cycle;

                self.dma.ddd_IsHidden = model.secondArr[0].isHidden;
                self.dma.dma_IsHidden = model.secondArr[1].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_EMV:
            if (model.firstArr.count == 2 && model.secondArr.count == 2) {
                self.emv.cycle_1 = model.firstArr[0].cycle;
                self.emv.cycle_2 = model.firstArr[1].cycle;

                self.emv.em_IsHidden = model.secondArr[0].isHidden;
                self.emv.emva_IsHidden = model.secondArr[1].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_WR:
            if (model.firstArr.count == 2 && model.secondArr.count == 2) {
                self.wr.cycle_1 = model.firstArr[0].cycle;
                self.wr.cycle_2 = model.firstArr[1].cycle;

                self.wr.wr_1_IsHidden = model.secondArr[0].isHidden;
                self.wr.wr_2_IsHidden = model.secondArr[1].isHidden;
            }
            break;
        case YXStockSubAccessoryStatus_CR:
            if (model.firstArr.count == 5 && model.secondArr.count == 5) {
                self.cr.cycle_1 = model.firstArr[0].cycle;
                self.cr.cycle_2 = model.firstArr[1].cycle;
                self.cr.cycle_3 = model.firstArr[2].cycle;
                self.cr.cycle_4 = model.firstArr[3].cycle;
                self.cr.cycle_5 = model.firstArr[4].cycle;

                self.cr.cr_IsHidden = model.secondArr[0].isHidden;
                self.cr.ma_1_IsHidden = model.secondArr[1].isHidden;
                self.cr.ma_2_IsHidden = model.secondArr[2].isHidden;
                self.cr.ma_3_IsHidden = model.secondArr[3].isHidden;
                self.cr.ma_4_IsHidden = model.secondArr[4].isHidden;
            }
            break;
        default:
            break;
    }

}

- (YXKlineConfigModel *)getConfigWithModelWithType:(NSInteger)type {

    YXKlineConfigModel *model = nil;
    switch (type) {
        case YXStockMainAcessoryStatusMA:
            model = self.ma;
            break;
        case YXStockMainAcessoryStatusEMA:
            model = self.ema;
            break;
        case YXStockMainAcessoryStatusBOLL:
            model = self.boll;
            break;
        case YXStockMainAcessoryStatusSAR:
            model = self.sar;
            break;
        case YXStockMainAcessoryStatusUsmart:
            model = self.usmart;
            break;
        case YXStockSubAccessoryStatus_MAVOL:
            model = self.mavol;
            break;
        case YXStockSubAccessoryStatus_MACD:
            model = self.macd;
            break;
        case YXStockSubAccessoryStatus_KDJ:
            model = self.kdj;
            break;
        case YXStockSubAccessoryStatus_RSI:
            model = self.rsi;
            break;
        case YXStockSubAccessoryStatus_ARBR:
            model = self.arbr;
            break;
        case YXStockSubAccessoryStatus_DMA:
            model = self.dma;
            break;
        case YXStockSubAccessoryStatus_EMV:
            model = self.emv;
            break;
        case YXStockSubAccessoryStatus_WR:
            model = self.wr;
            break;
        case YXStockSubAccessoryStatus_CR:
            model = self.cr;
            break;
        default:
            break;
    }

    return model;
}

- (void)saveData {

    NSData *data = [self yy_modelToJSONData];

    if (data) {
        [[MMKV defaultMMKV] setData:data forKey:@"YXKLineConfigManager"];
    }
}

- (void)addExplainInfo:(UILabel *)label type:(NSInteger)type {

    label.userInteractionEnabled = YES;
    @weakify(self);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self);
        [self showExplainInfo:type];
    }];
    [label addGestureRecognizer:tap];

}

- (void)showExplainInfo:(NSInteger)type {

    YXKlineConfigModel *config = [self getConfigWithModelWithType:type];
    NSString *message = config.settingModel.explain;

    CGFloat margin = 16;
    CGFloat width = 285 - 2 * margin;
    CGFloat height = [message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
    CGFloat maxHeight = 270;
    if (height > maxHeight) {

        YXAlertView *alert = [YXAlertView alertViewWithTitle:[YXLanguageUtility kLangWithKey:@"indicator_description"] message:nil];
        alert.messageLabel.font = [UIFont systemFontOfSize:16];
        alert.messageLabel.textAlignment = NSTextAlignmentLeft;
        [alert addAction:[[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_iknow"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {

        }]];

        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, maxHeight - 15)];

        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsVerticalScrollIndicator = NO;
        [customView addSubview:scrollView];
        scrollView.frame = CGRectMake(0, 0, width, maxHeight);

        UILabel *label = [UILabel labelWithText:message textColor: QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        [scrollView addSubview:label];

        label.frame = CGRectMake(0, 0, width, height + 16);
        scrollView.contentSize = CGSizeMake(width, height + 16);

        CGFloat scrollIndicatorHeight = (maxHeight / height) * maxHeight;
        UIView *vertialScrollIndicator = [[UIView alloc] initWithFrame:CGRectMake(width + 2, -15, 4, scrollIndicatorHeight)];
        vertialScrollIndicator.layer.cornerRadius = 2.0;
        vertialScrollIndicator.backgroundColor = QMUITheme.separatorLineColor;
        [customView addSubview:vertialScrollIndicator];


        @weakify(scrollView, vertialScrollIndicator);
        [RACObserve(scrollView, contentOffset) subscribeNext:^(id  _Nullable x) {
            @strongify(scrollView, vertialScrollIndicator);
            CGFloat y = (fabs(scrollView.contentOffset.y) / height) * maxHeight - 15;
            if (y > maxHeight - vertialScrollIndicator.frame.size.height) {
                y = maxHeight - vertialScrollIndicator.frame.size.height;
            }
            vertialScrollIndicator.mj_y = y;
        }];

        [alert addCustomView: customView];

        [alert showInWindow];
    } else {
        YXAlertView *alert = [[YXAlertView alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"indicator_description"] message:message prompt:nil style:YXAlertStyleDefault messageAlignment:NSTextAlignmentLeft];
        alert.messageLabel.font = [UIFont systemFontOfSize:16];
        alert.messageLabel.textAlignment = NSTextAlignmentLeft;
        [alert addAction:[[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_iknow"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {

        }]];

        [alert showInWindow];
    }
}

@end
