//
//  YXAccessoryTitleGenerator.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/10/26.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXAccessoryTitleGenerator.h"
#import "YXStockConfig.h"
#import <YYCategories/YYCategories.h>
#import "uSmartOversea-Swift.h"
#import "UILabel+create.h"

@interface YXAccessoryTitleGenerator()
@property (nonatomic, strong) NSMutableAttributedString *attM;

@end

@implementation YXAccessoryTitleGenerator


/**
 set赋值
 */
- (void)setKlineModel:(YXKLine *)klineModel{

    // ma
    if (!self.MALabel.hidden) {
        [self realodMAWithModel:klineModel];
    }
    // ema
    if (!self.EMALabel.hidden) {
        [self realodEMAWithModel:klineModel];
    }
    // boll
    if (!self.BOLLLabel.hidden) {
        [self realodBollWithModel:klineModel];
    }

    if (!self.SARLabel.hidden) {
        // sar
        [self realodSARWithModel:klineModel];
    }
    
    if (!self.usmartLabel.hidden) {
        [self realodUsmartWithModel:klineModel];
    }

    // volume
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_MAVOL)]) {
        [self realodVolumeWithModel:klineModel];
    }
    // macd
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_MACD)]) {
        [self realodMACDWithModel:klineModel];
    }
    // kdj
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_KDJ)]) {
        [self realodKDJWithModel:klineModel];
    }

    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_RSI)]) {
        // rsi
        [self realodRSIWithModel:klineModel];
    }

    // dma
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_DMA)]) {
        [self realodDMAWithModel:klineModel];
    }
    // arbr
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_ARBR)]) {
        [self realodARBRWithModel:klineModel];
    }
    // wr
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_WR)]) {
        [self realodWRWithModel:klineModel];
    }
    // emv
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_EMV)]) {
        [self realodEMVWithModel:klineModel];
    }
    // cr
    if ([[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_CR)]) {
        [self realodCRWithModel:klineModel];
    }
}

#pragma mark - 刷新MA
- (void)realodMAWithModel:(YXKLine *)klineModel {

    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusMA];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:text]; //@"MA"
    if (![YXKLineConfigManager shareInstance].ma.ma_5_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"MA%zd: %@", [YXKLineConfigManager shareInstance].ma.ma_5, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ma5.value]]];
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_20_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"MA%zd: %@", [YXKLineConfigManager shareInstance].ma.ma_20, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ma20.value]]];
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_60_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"MA%zd: %@", [YXKLineConfigManager shareInstance].ma.ma_60, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ma60.value]]];
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_120_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA120_COLOR andTitle:[NSString stringWithFormat:@"MA%zd: %@", [YXKLineConfigManager shareInstance].ma.ma_120, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ma120.value]]];
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_250_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA250_COLOR andTitle:[NSString stringWithFormat:@"MA%zd: %@", [YXKLineConfigManager shareInstance].ma.ma_250, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ma250.value]]];
    }
    self.MALabel.attributedText = self.attM;

}

#pragma mark - 刷新EMA
- (void)realodEMAWithModel:(YXKLine *)klineModel {
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusEMA];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:text]; //@"EMA"
    if (![YXKLineConfigManager shareInstance].ema.ema_5_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"EMA%zd: %@", [YXKLineConfigManager shareInstance].ema.ema_5, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ema5.value]]];
    }
    if (![YXKLineConfigManager shareInstance].ema.ema_20_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"EMA%zd: %@", [YXKLineConfigManager shareInstance].ema.ema_20, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ema20.value]]];
    }
    if (![YXKLineConfigManager shareInstance].ema.ema_60_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"EMA%zd: %@", [YXKLineConfigManager shareInstance].ema.ema_60, [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.ema60.value]]];
    }

    self.EMALabel.attributedText = self.attM;
}


#pragma mark - 刷新BOLL
- (void)realodBollWithModel:(YXKLine *)klineModel {

    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusBOLL]; //BOLL
    title = [NSString stringWithFormat:@"%@(%zd,%zd)", text, [YXKLineConfigManager shareInstance].boll.cycle_1, [YXKLineConfigManager shareInstance].boll.cycle_2];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];
    if (![YXKLineConfigManager shareInstance].boll.midIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"MID: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.bollMB.value]]];
    }
    if (![YXKLineConfigManager shareInstance].boll.upperIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"UPPER: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.bollUP.value]]];
    }
    if (![YXKLineConfigManager shareInstance].boll.lowerIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"LOWER: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.bollDN.value]]];
    }
    self.BOLLLabel.attributedText = self.attM;
}

#pragma mark - 刷新SAR
- (void)realodSARWithModel:(YXKLine *)klineModel {
    NSInteger square = klineModel.priceBase.value;
    double fullBaseValue = pow(10.0, square);
    self.attM = [[NSMutableAttributedString alloc] init];

    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusSAR]; //SAR
    title = [NSString stringWithFormat:@"%@(%zd,%zd,%zd)", text, [YXKLineConfigManager shareInstance].sar.cycle_1, [YXKLineConfigManager shareInstance].sar.cycle_2, [YXKLineConfigManager shareInstance].sar.cycle_3];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];

    if (![YXKLineConfigManager shareInstance].sar.bbIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"BB: %@", [self getValueStrWith:square andValue:klineModel.sar.value / fullBaseValue]]];
    }
    self.SARLabel.attributedText = self.attM;
}

#pragma mark - 刷新VOLUMNE
- (void)realodVolumeWithModel:(YXKLine *)klineModel {
    double fullBaseValue = 10000;
    if ([self.market isEqualToString:kYXMarketCryptos]) {
        fullBaseValue = 1.0;
    }
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_MAVOL]; //@"MAVOL"
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:text];
    if (self.isHKIndex) {
        NSInteger square = klineModel.priceBase.value;
        double priceFullBaseValue = pow(10.0, square);
        fullBaseValue = 100000000 * priceFullBaseValue;
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"VOL1: %@", [self getValueStrWith:2 andValue:klineModel.amount.value / fullBaseValue]]];
    } else {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"VOL1: %@", [self getValueStrWith:2 andValue:klineModel.volume.value / fullBaseValue]]];
    }

    if (![YXKLineConfigManager shareInstance].mavol.mavol_5_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"VOL%zd: %@", [YXKLineConfigManager shareInstance].mavol.mavol_5, [self getValueStrWith:2 andValue:klineModel.MVOL5.value / fullBaseValue]]];
    }
    if (![YXKLineConfigManager shareInstance].mavol.mavol_10_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"VOL%zd: %@", [YXKLineConfigManager shareInstance].mavol.mavol_10, [self getValueStrWith:2 andValue:klineModel.MVOL10.value / fullBaseValue]]];
    }
    if (![YXKLineConfigManager shareInstance].mavol.mavol_20_isHidden) {
        [self appendStrWithColor:YX_KLINE_MA120_COLOR andTitle:[NSString stringWithFormat:@"VOL%zd: %@", [YXKLineConfigManager shareInstance].mavol.mavol_20, [self getValueStrWith:2 andValue:klineModel.MVOL20.value / fullBaseValue]]];
    }
    self.MACD_VOL_Label.attributedText = self.attM;

}
#pragma mark - 刷新MACD
- (void)realodMACDWithModel:(YXKLine *)klineModel {
    self.attM = [[NSMutableAttributedString alloc] init];

    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_MACD]; //MACD
    title = [NSString stringWithFormat:@"%@(%zd,%zd,%zd)", text, [YXKLineConfigManager shareInstance].macd.cycle_1, [YXKLineConfigManager shareInstance].macd.cycle_2, [YXKLineConfigManager shareInstance].macd.cycle_3];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];

    if (![YXKLineConfigManager shareInstance].macd.difIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"DIF: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.DIF.value]]];
    }
    if (![YXKLineConfigManager shareInstance].macd.deaIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"DEA: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.DEA.value]]];
    }
    if (![YXKLineConfigManager shareInstance].macd.macdIsHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"MACD :%@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.MACD.value]]];
    }
    self.MACDTitleLabel.attributedText = self.attM;
}
#pragma mark - 刷新KDJ
- (void)realodKDJWithModel:(YXKLine *)klineModel {
    //KDJ
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_KDJ]; //KDJ
    title = [NSString stringWithFormat:@"%@(%zd,%zd,%zd)", text, [YXKLineConfigManager shareInstance].kdj.cycle_1, [YXKLineConfigManager shareInstance].kdj.cycle_2, [YXKLineConfigManager shareInstance].kdj.cycle_3];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];

    if (![YXKLineConfigManager shareInstance].kdj.K_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"K: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.KDJ_K.value]]];
    }
    if (![YXKLineConfigManager shareInstance].kdj.D_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"D: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.KDJ_D.value]]];
    }
    if (![YXKLineConfigManager shareInstance].kdj.J_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"J: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.KDJ_J.value]]];
    }
    self.KDJLabel.attributedText = self.attM;
}
#pragma mark - 刷新RSI
- (void)realodRSIWithModel:(YXKLine *)klineModel {
    //rsi
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_RSI]; //RSI
    title = [NSString stringWithFormat:@"%@(%zd,%zd,%zd)", text, [YXKLineConfigManager shareInstance].rsi.cycle_1, [YXKLineConfigManager shareInstance].rsi.cycle_2, [YXKLineConfigManager shareInstance].rsi.cycle_3];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];

    if (![YXKLineConfigManager shareInstance].rsi.rsi_1_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"RSI1: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.RSI_6.value]]];
    }
    if (![YXKLineConfigManager shareInstance].rsi.rsi_2_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"RSI2: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.RSI_12.value]]];
    }
    if (![YXKLineConfigManager shareInstance].rsi.rsi_3_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"RSI3: %@", [self getValueStrWith:klineModel.priceBase.value andValue:klineModel.RSI_24.value]]];
    }
    self.RSILabel.attributedText = self.attM;
}
#pragma mark - 刷新DMA
- (void)realodDMAWithModel:(YXKLine *)klineModel {
    //dma
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_DMA]; //DMA
    title = [NSString stringWithFormat:@"%@(%zd,%zd,%zd)", text, [YXKLineConfigManager shareInstance].dma.cycle_1, [YXKLineConfigManager shareInstance].dma.cycle_2, [YXKLineConfigManager shareInstance].dma.cycle_3];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];

    if (![YXKLineConfigManager shareInstance].dma.ddd_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"DDD: %@", [self getValueStrWith:3 andValue:klineModel.mDIF.value]]];
    }
    if (![YXKLineConfigManager shareInstance].dma.dma_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"DDDMA: %@", [self getValueStrWith:3 andValue:klineModel.mAMA.value]]];
    }
    self.DMALabel.attributedText = self.attM;

}
#pragma mark - 刷新ABBR
- (void)realodARBRWithModel:(YXKLine *)klineModel {
    //arbr
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_ARBR]; //ARBR
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:[NSString stringWithFormat:@"%@(%zd)", text, [YXKLineConfigManager shareInstance].arbr.cycle_1]];
    if (![YXKLineConfigManager shareInstance].arbr.ar_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"AR: %@", [self getValueStrWith:3 andValue:klineModel.AR.value]]];
    }
    if (![YXKLineConfigManager shareInstance].arbr.br_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"BR: %@",[self getValueStrWith:3 andValue:klineModel.BR.value]]];
    }
    self.ARBRLabel.attributedText = self.attM;
}
#pragma mark - 刷新WR
- (void)realodWRWithModel:(YXKLine *)klineModel {
    //wr
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_WR]; //WR
    title = [NSString stringWithFormat:@"%@(%zd,%zd)", text, [YXKLineConfigManager shareInstance].wr.cycle_1, [YXKLineConfigManager shareInstance].wr.cycle_2];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];
    if (![YXKLineConfigManager shareInstance].wr.wr_1_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"WR1: %@", [self getValueStrWith:3 andValue:klineModel.WR1.value]]];
    }
    if (![YXKLineConfigManager shareInstance].wr.wr_2_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"WR2: %@",[self getValueStrWith:3 andValue:klineModel.WR2.value]]];
    }
    self.WRLabel.attributedText = self.attM;
}
#pragma mark - 刷新EMV
- (void)realodEMVWithModel:(YXKLine *)klineModel {
    //emv
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_EMV]; //EMV
    title = [NSString stringWithFormat:@"%@(%zd,%zd)", text, [YXKLineConfigManager shareInstance].emv.cycle_1, [YXKLineConfigManager shareInstance].emv.cycle_2];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];
    if (![YXKLineConfigManager shareInstance].emv.em_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"EMV: %@", [self getValueStrWith:3 andValue:klineModel.EMV.value]]];
    }
    if (![YXKLineConfigManager shareInstance].emv.emva_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"EMVA: %@",[self getValueStrWith:3 andValue:klineModel.AEMV.value]]];
    }
    self.EMVLabel.attributedText = self.attM;
}
#pragma mark - 刷新CR
- (void)realodCRWithModel:(YXKLine *)klineModel {
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = @"";
    NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_CR]; //CR
    title = [NSString stringWithFormat:@"%@(%zd,%zd,%zd,%zd,%zd)", text,  [YXKLineConfigManager shareInstance].cr.cycle_1, [YXKLineConfigManager shareInstance].cr.cycle_2, [YXKLineConfigManager shareInstance].cr.cycle_3, [YXKLineConfigManager shareInstance].cr.cycle_4, [YXKLineConfigManager shareInstance].cr.cycle_5];
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];

    if (![YXKLineConfigManager shareInstance].cr.cr_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA5_COLOR andTitle:[NSString stringWithFormat:@"CR: %@", [self getValueStrWith:3 andValue:klineModel.CR.value]]];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_1_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA20_COLOR andTitle:[NSString stringWithFormat:@"MA1: %@", [self getValueStrWith:3 andValue:klineModel.CR1.value]]];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_2_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA60_COLOR andTitle:[NSString stringWithFormat:@"MA2: %@", [self getValueStrWith:3 andValue:klineModel.CR2.value]]];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_3_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA120_COLOR andTitle:[NSString stringWithFormat:@"MA3: %@", [self getValueStrWith:3 andValue:klineModel.CR3.value]]];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_4_IsHidden) {
        [self appendStrWithColor:YX_KLINE_MA250_COLOR andTitle:[NSString stringWithFormat:@"MA4: %@", [self getValueStrWith:3 andValue:klineModel.CR4.value]]];
    }
    self.CRLabel.attributedText = self.attM;
}

#pragma mark - 刷新usmartLabel
- (void)realodUsmartWithModel:(YXKLine *)klineModel {
    
    self.attM = [[NSMutableAttributedString alloc] init];
    NSString *title = [YXLanguageUtility kLangWithKey:@"trend_signal"];
    
    [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:title];
    
    [self appendStrWithColor:QMUITheme.stockRedColor andTitle:[NSString stringWithFormat:@"%@: %@",[YXLanguageUtility kLangWithKey:@"trend_signal_upper"], [self getValueStrWith:3 andValue:klineModel.usmartUp.value]]];
    [self appendStrWithColor:QMUITheme.stockGreenColor andTitle:[NSString stringWithFormat:@"%@: %@",[YXLanguageUtility kLangWithKey:@"trend_signal_lower"], [self getValueStrWith:3 andValue:klineModel.usmartDown.value]]];
        
    if (klineModel.usmartSignalChg) {
        NSInteger tag = klineModel.usmartSignalChg.value;
        NSString *title = @"";
        UIColor *color = QMUITheme.stockRedColor;
        if (tag == 1) {
            title = @"0%->50%";
        } else if (tag == 2) {
            title = @"0%->100%";
        } else if (tag == 3) {
            title = @"50%->100%";
        } else if (tag == 4) {
            title = @"100%->50%";
            color = QMUITheme.stockGreenColor;
        } else if (tag == 5) {
            title = @"100%->0%";
            color = QMUITheme.stockGreenColor;
        } else if (tag == 6) {
            title = @"50%->0%";
            color = QMUITheme.stockGreenColor;
        }
        [self appendStrWithColor:color andTitle:[NSString stringWithFormat:@"%@: %@", [YXLanguageUtility kLangWithKey:@"trend_signal_operate_singal"], title]];
    } else {
        [self appendStrWithColor:[QMUITheme textColorLevel2] andTitle:[NSString stringWithFormat:@"%@: %lld%%", [YXLanguageUtility kLangWithKey:@"hold_holds"], klineModel.usmartSignalHold.value]];
    }
    
    [self appendStrWithColor:QMUITheme.stockRedColor andTitle:@"○"];
    NSAttributedString *attentionStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", [YXLanguageUtility kLangWithKey:@"trend_signal_buy_singal"]] attributes:@{NSForegroundColorAttributeName: QMUITheme.textColorLevel3, NSFontAttributeName: [UIFont systemFontOfSize:8 weight:UIFontWeightMedium]}];
    [self.attM appendAttributedString:attentionStr];
    
    [self appendStrWithColor:QMUITheme.stockGreenColor andTitle:@"○"];
    NSAttributedString *obStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", [YXLanguageUtility kLangWithKey:@"trend_signal_sell_singal"]] attributes:@{NSForegroundColorAttributeName: QMUITheme.textColorLevel3, NSFontAttributeName:[UIFont systemFontOfSize:8 weight:UIFontWeightMedium]}];
    [self.attM appendAttributedString:obStr];
    
    self.usmartLabel.attributedText = self.attM;
}

- (void)appendStrWithColor:(UIColor *)color andTitle:(NSString *)title {

    NSAttributedString *str = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: [UIFont systemFontOfSize:8 weight:UIFontWeightMedium]}];
    if (self.attM.length > 0) {

        [self.attM appendString:@"    "];
        [self.attM appendAttributedString:str];
    } else {

        [self.attM appendAttributedString:str];
        if (!self.isLandscape) {
            [self.attM appendAttributedString:[self appendExplainAttributeString]];
        }
    }
}

- (NSAttributedString *)appendExplainAttributeString {

    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"explain_info"];
    NSAttributedString *attrM = [NSAttributedString attributedStringWithAttachment:attachment];
    attachment.bounds = CGRectMake(2, -1.5, 10, 10);
    return attrM;
}

#pragma mark - lazy load
- (UILabel *)EMALabel{
    if (!_EMALabel) {
        _EMALabel = [self accessoryLabel:[YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusEMA]]; //@"EMA"
    }
    return _EMALabel;
}

- (UILabel *)MALabel{
    if (!_MALabel) {
        _MALabel = [self accessoryLabel:[YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusMA]]; //@"MA"
    }
    return _MALabel;
}

- (UILabel *)BOLLLabel{
    if (!_BOLLLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusBOLL];
        text = [NSString stringWithFormat:@"%@(20, 2)", text];
        _BOLLLabel = [self accessoryLabel:text]; //@"BOLL(20, 2)"
    }
    return _BOLLLabel;
}

- (UILabel *)SARLabel{
    if (!_SARLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockMainAcessoryStatusSAR];
        text = [NSString stringWithFormat:@"%@(4, 2, 20)", text];
        _SARLabel = [self accessoryLabel:text]; //@"SAR(4, 2, 20)"
    }
    return _SARLabel;
}

- (UILabel *)MACDTitleLabel{
    if (!_MACDTitleLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_MACD];
        text = [NSString stringWithFormat:@"%@(12, 26, 9)", text];
        _MACDTitleLabel = [self accessoryLabel:text]; //@"MACD(12, 26, 9)"
    }
    return _MACDTitleLabel;
}

- (UILabel *)MACD_VOL_Label{
    if (!_MACD_VOL_Label) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_MAVOL];
        _MACD_VOL_Label = [self accessoryLabel: text]; //@"MAVOL"
    }
    return _MACD_VOL_Label;
}

- (UILabel *)RSILabel{
    if (!_RSILabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_RSI];
        text = [NSString stringWithFormat:@"%@(6, 12, 24)", text];
        _RSILabel = [self accessoryLabel:text]; //@"RSI(6, 12, 24)"
    }
    return _RSILabel;
}

- (UILabel *)KDJLabel{
    if (!_KDJLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_KDJ];
        text = [NSString stringWithFormat:@"%@(9, 3, 3)", text];
        _KDJLabel = [self accessoryLabel: text]; //@"KDJ(9, 3, 3)"
    }
    return _KDJLabel;
}

- (UILabel *)DMALabel{
    if (!_DMALabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_DMA];
        text = [NSString stringWithFormat:@"%@(10, 50, 10)", text];
        _DMALabel = [self accessoryLabel: text]; //@"DMA(10, 50, 10)"
    }
    return _DMALabel;
}

- (UILabel *)ARBRLabel{
    if (!_ARBRLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_ARBR];
        text = [NSString stringWithFormat:@"%@(26)", text];
        _ARBRLabel = [self accessoryLabel: text]; //@"ARBR(26)"
    }
    return _ARBRLabel;
}

- (UILabel *)WRLabel{
    if (!_WRLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_WR];
        text = [NSString stringWithFormat:@"%@(10, 6)", text];
        _WRLabel = [self accessoryLabel: text]; //@"WR(10, 6)"
    }
    return _WRLabel;
}

- (UILabel *)EMVLabel{
    if (!_EMVLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_EMV];
        text = [NSString stringWithFormat:@"%@(14, 9)", text];
        _EMVLabel = [self accessoryLabel: text]; //@"EMV(14, 9)"
    }
    return _EMVLabel;
}

- (UILabel *)CRLabel{
    if (!_CRLabel) {
        NSString *text = [YXKLineConfigManager getSettingTitleWithType:YXStockSubAccessoryStatus_CR];
        text = [NSString stringWithFormat:@"%@(26, 5, 10, 20, 60)", text];
        _CRLabel = [self accessoryLabel: text]; //@"CR(26, 5, 10, 20, 60)"
    }
    return _CRLabel;
}


- (UILabel *)usmartLabel{
    if (!_usmartLabel) {
        _usmartLabel = [self accessoryLabel: @"--"];
        _usmartLabel.adjustsFontSizeToFitWidth = YES;
        _usmartLabel.minimumScaleFactor = 0.3;
    }
    return _usmartLabel;
}

- (UILabel *)accessoryLabel:(NSString *)text  {

    UILabel *label = [UILabel labelWithText:text textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightMedium]];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.7;

    return label;
}

- (QMUILabel *)crossingLinePriceLabel{
    if (!_crossingLinePriceLabel) {

        _crossingLinePriceLabel = [QMUILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
        _crossingLinePriceLabel.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.8];
        _crossingLinePriceLabel.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        _crossingLinePriceLabel.layer.cornerRadius = 2.0;
        _crossingLinePriceLabel.layer.masksToBounds = YES;
    }
    return _crossingLinePriceLabel;
}

- (UILabel *)startDateLabel{
    if (!_startDateLabel) {
        _startDateLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _startDateLabel;
}

- (UILabel *)endDateLabel{
    if (!_endDateLabel) {
        _endDateLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _endDateLabel;
}

- (UILabel *)currentDateLabel {
    if (!_currentDateLabel) {
        _currentDateLabel = [UILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
        _currentDateLabel.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.8];
        _currentDateLabel.textAlignment = NSTextAlignmentCenter;
        _currentDateLabel.adjustsFontSizeToFitWidth = YES;
        _currentDateLabel.minimumScaleFactor = 0.7;
        _currentDateLabel.layer.cornerRadius = 2.0;
        _currentDateLabel.layer.masksToBounds = YES;
    }
    return _currentDateLabel;
}

- (QMUILabel *)timeLineCrossingPriceLabel {
    if (!_timeLineCrossingPriceLabel) {
        _timeLineCrossingPriceLabel = [QMUILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular] textAlignment:NSTextAlignmentLeft];
        _timeLineCrossingPriceLabel.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        _timeLineCrossingPriceLabel.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.8];
        _timeLineCrossingPriceLabel.layer.cornerRadius = 2.0;
        _timeLineCrossingPriceLabel.layer.masksToBounds = YES;
    }
    return _timeLineCrossingPriceLabel;
}

- (QMUILabel *)timeLineCrossingRocLabel {
    if (!_timeLineCrossingRocLabel) {
        _timeLineCrossingRocLabel = [QMUILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular] textAlignment:NSTextAlignmentLeft];
        _timeLineCrossingRocLabel.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        _timeLineCrossingRocLabel.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.8];
        _timeLineCrossingRocLabel.layer.cornerRadius = 2.0;
        _timeLineCrossingRocLabel.layer.masksToBounds = YES;
    }
    return _timeLineCrossingRocLabel;
}

- (UILabel *)kLineMaxPriceLabel {
    if (!_kLineMaxPriceLabel) {
        _kLineMaxPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineMaxPriceLabel;
}

- (UILabel *)kLineSecondMaxPriceLabel {
    if (!_kLineSecondMaxPriceLabel) {
        _kLineSecondMaxPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineSecondMaxPriceLabel;
}

- (UILabel *)kLineSecondMinPriceLabel {
    if (!_kLineSecondMinPriceLabel) {
        _kLineSecondMinPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineSecondMinPriceLabel;
}

- (UILabel *)kLineThirdMaxPriceLabel {
    if (!_kLineThirdMaxPriceLabel) {
        _kLineThirdMaxPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineThirdMaxPriceLabel;
}

- (UILabel *)kLineThirdMinPriceLabel {
    if (!_kLineThirdMinPriceLabel) {
        _kLineThirdMinPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineThirdMinPriceLabel;
}

- (UILabel *)kLineMinPriceLabel {
    if (!_kLineMinPriceLabel) {
        _kLineMinPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineMinPriceLabel;
}

- (UILabel *)pclosePriceLabel {
    if (!_pclosePriceLabel) {
        _pclosePriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _pclosePriceLabel;
}

- (UILabel *)kLineMaxRatoLabel {
    if (!_kLineMaxRatoLabel) {
        _kLineMaxRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineMaxRatoLabel;
}

- (UILabel *)kLineSecondMaxRatoLabel {
    if (!_kLineSecondMaxRatoLabel) {
        _kLineSecondMaxRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineSecondMaxRatoLabel;
}

- (UILabel *)kLineSecondMinRatoLabel {
    if (!_kLineSecondMinRatoLabel) {
        _kLineSecondMinRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineSecondMinRatoLabel;
}

- (UILabel *)kLineThirdMaxRatoLabel {
    if (!_kLineThirdMaxRatoLabel) {
        _kLineThirdMaxRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineThirdMaxRatoLabel;
}

- (UILabel *)kLineThirdMinRatoLabel {
    if (!_kLineThirdMinRatoLabel) {
        _kLineThirdMinRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineThirdMinRatoLabel;
}

- (UILabel *)kLineMinRatoLabel {
    if (!_kLineMinRatoLabel) {
        _kLineMinRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _kLineMinRatoLabel;
}

- (UILabel *)pcloseRatoLabel {
    if (!_pcloseRatoLabel) {
        _pcloseRatoLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _pcloseRatoLabel;
}


- (UILabel *)subMaxPriceLabel {
    if (!_subMaxPriceLabel) {
        _subMaxPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _subMaxPriceLabel;
}
- (UILabel *)subMidPriceLabel {
    if (!_subMidPriceLabel) {
        _subMidPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _subMidPriceLabel;
}
- (UILabel *)subMinPriceLabel {
    if (!_subMinPriceLabel) {
        _subMinPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentLeft];
    }
    return _subMinPriceLabel;
}


- (NSString *)getValueStrWith:(NSInteger)decimal andValue:(double)value {

    if (decimal == 2) {
        return [NSString stringWithFormat:@"%.2f", value];
    } else {
        return [NSString stringWithFormat:@"%.3f", value];
    }
}

- (NSMutableAttributedString *)attM {
    if (_attM == nil) {
        _attM = [[NSMutableAttributedString alloc] init];
    }
    return _attM;
}

@end
