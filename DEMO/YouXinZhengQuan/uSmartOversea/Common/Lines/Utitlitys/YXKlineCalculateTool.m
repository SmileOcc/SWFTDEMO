//
//  YXKlineCalculateTool.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/10/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKlineCalculateTool.h"
#import "MMKV.h"
#import "uSmartOversea-Swift.h"
#import "YXKLineConfigManager.h"

@interface YXKlineCalculateTool ()

@property (nonatomic, strong) YXKLineData *kline;

// 除数位换算后的值
@property (nonatomic, assign) double fullBaseValue;
// cr周期N数组
@property (nonatomic, strong) NSMutableArray <NSNumber *> *nMCycle;
// cr周期M数组
@property (nonatomic, strong) NSMutableArray <NSNumber *> *nMaRefumnCycle;


@end

@implementation YXKlineCalculateTool

+ (instancetype)shareInstance {

    static YXKlineCalculateTool *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[YXKlineCalculateTool alloc] init];

    });

    return _shareInstance;
}

- (void)calAccessoryValue:(YXKLineData *)kline {
    if (kline.list.count == 0) {
        return;
    }

    self.kline = kline;
    NSInteger square = kline.priceBase.value;
    self.fullBaseValue = pow(10.0, square);

    // 获取配置
    YXStockMainAcessoryStatus mainAccessoryStatus = [YXKLineConfigManager shareInstance].mainAccessory;
    NSArray *subAccessoryArray = [YXKLineConfigManager shareInstance].subAccessoryArray;

    for (int index = 0; index < kline.list.count; ++index) {
        YXKLine *obj = kline.list[index];
        obj.priceBase = self.kline.priceBase;
        if (index == 0) {
            [self initFirstModel:obj];
        }
        if (mainAccessoryStatus == YXStockMainAcessoryStatusMA) {
            // ma
            [self calMAValueWithIndex:index andObj:obj];
        } else if (mainAccessoryStatus == YXStockMainAcessoryStatusEMA) {
            // ema
            [self calEMAWithIndex:index andObj:obj];
        } else if (mainAccessoryStatus == YXStockMainAcessoryStatusBOLL) {
            // boll
            if (obj.bollMB.value == 0 || obj.bollUP.value == 0 || obj.bollDN.value == 0) {
                [self calBollValueWithIndex:index andObj:obj];
            }
        } else if (mainAccessoryStatus == YXStockMainAcessoryStatusUsmart) {
            [self calUsmartWithIndex:index andObj:obj];
        }

        if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_MACD)]) {
            // macd
            if (obj.MACD.value == 0 || obj.DIF.value == 0  || obj.DEA.value == 0) {
                [self calMACDValueWithIndex:index andObj:obj];
            }
        }

        if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_KDJ)]) {
            // kdj
            if (obj.KDJ_K.value == 0 || obj.KDJ_D.value == 0 || obj.KDJ_J.value == 0) {

                [self calKDJWithIndex:index andObj:obj];
            }
        }

        if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_RSI)]) {
            // 计算rsi
            if (obj.RSI_6_flag.value == 0) {
                [self calRsi6WithIndex:index andObj:obj andDay:[YXKLineConfigManager shareInstance].rsi.cycle_1 andRSIIndex:1];
            }

            if (obj.RSI_12_flag.value == 0) {
                [self calRsi6WithIndex:index andObj:obj andDay:[YXKLineConfigManager shareInstance].rsi.cycle_2 andRSIIndex:2];
            }

            if (obj.RSI_24_flag.value == 0) {
                [self calRsi6WithIndex:index andObj:obj andDay:[YXKLineConfigManager shareInstance].rsi.cycle_3 andRSIIndex:3];
            }

        }

        if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_MAVOL)]) {
            [self calVolumnValueWithIndex:index andObj:obj];
        }
    }

    if (mainAccessoryStatus == YXStockMainAcessoryStatusSAR) {
        // 计算sar
        [self calSARValue];
    }

    if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_DMA)]) {
        // 计算dma
        [self calDMAValue];
    }

    if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_ARBR)]) {
        // 计算arbr
        [self calARBRValue];
    }

    if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_WR)]) {
        // 计算wr
        [self calWRValue];
    }

    if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_EMV)]) {
        // 计算emv
        [self calEMVValue];
    }

    if ([subAccessoryArray containsObject:@(YXStockSubAccessoryStatus_CR)]) {
        // 计算cr
        // 更新cr的周期
        self.nMCycle = nil;
        self.nMaRefumnCycle = nil;

        [self calCRValue];
    }


}

#pragma mark - RSI
- (void)calRsi6WithIndex:(NSInteger)index andObj:(YXKLine *)model andDay:(NSInteger)day andRSIIndex:(NSInteger)rsiIndex {

    double rsi_up_sma6 = 0;
    double rsi_sum_sma6  = 0;
    
    if (index == 0) {
        return ;
    }

    double different = model.close.value - model.preClose.value;
    if (rsiIndex == 1) {
        if (different > 0) {
            rsi_up_sma6 = ((different / self.fullBaseValue) + self.kline.list[index - 1].rsi_up_sma6.value * (day - 1)) / day;
        }else{
            rsi_up_sma6 = (self.kline.list[index-1].rsi_up_sma6.value * (day - 1)) / day;
        }
        rsi_sum_sma6 = (fabs(different / self.fullBaseValue) + (day - 1) * self.kline.list[index-1].rsi_sum_sma6.value) / day;
    } else if (rsiIndex == 2) {
        if (different > 0) {
            rsi_up_sma6 = ((different / self.fullBaseValue) + self.kline.list[index - 1].rsi_up_sma12.value * (day - 1)) / day;
        }else{
            rsi_up_sma6 = (self.kline.list[index-1].rsi_up_sma12.value * (day - 1)) / day;
        }
        rsi_sum_sma6 = (fabs(different / self.fullBaseValue) + (day - 1) * self.kline.list[index-1].rsi_sum_sma12.value) / day;
    } else if (rsiIndex == 3) {
        if (different > 0) {
            rsi_up_sma6 = ((different / self.fullBaseValue) + self.kline.list[index - 1].rsi_up_sma24.value * (day - 1)) / day;
        }else{
            rsi_up_sma6 = (self.kline.list[index-1].rsi_up_sma24.value * (day - 1)) / day;
        }
        rsi_sum_sma6 = (fabs(different / self.fullBaseValue) + (day - 1) * self.kline.list[index-1].rsi_sum_sma24.value) / day;
    }

    if (rsiIndex == 1) {
        model.rsi_up_sma6 = [[NumberDouble alloc] init:rsi_up_sma6] ;
        model.rsi_sum_sma6 =  [[NumberDouble alloc] init:rsi_sum_sma6];
        if (rsi_sum_sma6 == 0) {
            model.RSI_6 = [[NumberDouble alloc] init:0];
        } else {
            model.RSI_6 = [[NumberDouble alloc] init:rsi_up_sma6 / rsi_sum_sma6 * 100.0];
        }

        if (index >= day - 1) {
            model.RSI_6_flag = [[NumberInt32 alloc] init:1];
        } else {
            model.RSI_6_flag = [[NumberInt32 alloc] init:0];
        }

    } else if (rsiIndex == 2) {
        model.rsi_up_sma12 = [[NumberDouble alloc] init:rsi_up_sma6];
        model.rsi_sum_sma12 = [[NumberDouble alloc] init:rsi_sum_sma6];
        if (rsi_sum_sma6 == 0) {
            model.RSI_12 = [[NumberDouble alloc] init:0];
        } else {
            model.RSI_12 = [[NumberDouble alloc] init:rsi_up_sma6 / rsi_sum_sma6 * 100.0];
        }

        if (index >= day - 1) {
            model.RSI_12_flag = [[NumberInt32 alloc] init:1];
        } else {
            model.RSI_12_flag = [[NumberInt32 alloc] init:0];
        }

    } else if (rsiIndex == 3) {
        model.rsi_up_sma24 = [[NumberDouble alloc] init:rsi_up_sma6];
        model.rsi_sum_sma24 = [[NumberDouble alloc] init:rsi_sum_sma6];
        if (rsi_sum_sma6 == 0) {
            model.RSI_24 = [[NumberDouble alloc] init:0];
        } else {
            model.RSI_24 = [[NumberDouble alloc] init:rsi_up_sma6 / rsi_sum_sma6 * 100.0];
        }

        if (index >= day - 1) {
            model.RSI_24_flag = [[NumberInt32 alloc] init:1];
        } else {
            model.RSI_24_flag = [[NumberInt32 alloc] init:0];
        }
    }
}

#pragma mark - KDJ
- (void)calKDJWithIndex:(NSInteger)index andObj:(YXKLine *)model {

    if (model.NineClocksMinPrice.value == 0) {
        if (index >= ([YXKLineConfigManager shareInstance].kdj.cycle_1 - 1) && self.kline.list.count >= 9) {
            [self rangeLastNinePriceByArray:self.kline.list condition:NSOrderedDescending];

            [self rangeLastNinePriceByArray:self.kline.list condition:NSOrderedAscending];
        } else {
            NSArray *subArr = [self.kline.list subarrayWithRange:NSMakeRange(0, index + 1)];

            double min = [[subArr valueForKeyPath:@"@min.low.value"] doubleValue];
            model.NineClocksMinPrice = [[NumberDouble alloc] init:min / self.fullBaseValue] ;

            double max = [[subArr valueForKeyPath:@"@max.high.value"] doubleValue];
            model.NineClocksMaxPrice = [[NumberDouble alloc] init:max / self.fullBaseValue];
        }
    }


    if(model.NineClocksMinPrice.value ==  model.NineClocksMaxPrice.value) {
        model.RSV_9 = [[NumberDouble alloc] init:80];
    } else if (index > 0) {
        model.RSV_9 = [[NumberDouble alloc] init:(model.close.value / self.fullBaseValue - model.NineClocksMinPrice.value) * 100.0 / (model.NineClocksMaxPrice.value - model.NineClocksMinPrice.value)];
    } else {
        model.RSV_9 = [[NumberDouble alloc] init:80];
    }

    double KDJ_K = 0;
    double KDJ_D = 0;
    if (index > 0) {
        KDJ_K = self.kline.list[index - 1].KDJ_K.value;
        KDJ_D = self.kline.list[index - 1].KDJ_D.value;
    }
    model.KDJ_K = [[NumberDouble alloc] init:(model.RSV_9.value + ([YXKLineConfigManager shareInstance].kdj.cycle_2 - 1) * (KDJ_K  > 0 ? KDJ_K : 80)) / (float)([YXKLineConfigManager shareInstance].kdj.cycle_2)];
    model.KDJ_D = [[NumberDouble alloc] init:(model.KDJ_K.value + (float)([YXKLineConfigManager shareInstance].kdj.cycle_3 - 1) * (KDJ_D > 0 ? KDJ_D : 80)) / (float)([YXKLineConfigManager shareInstance].kdj.cycle_3)];
    model.KDJ_J = [[NumberDouble alloc] init: (3 * model.KDJ_K.value - 2 * model.KDJ_D.value)];

}

#pragma mark - EMA
- (void)calEMAWithIndex:(NSInteger)index andObj:(YXKLine *)model {

    if (index > 0) {
        if (model.ema5.value == 0) {
            model.ema5 = [[NumberDouble alloc] init:(2 * model.close.value / self.fullBaseValue + ([YXKLineConfigManager shareInstance].ema.ema_5 - 1) * self.kline.list[index - 1].ema5.value) / ([YXKLineConfigManager shareInstance].ema.ema_5 + 1)];
        }
        if (model.ema20.value == 0) {
            model.ema20 = [[NumberDouble alloc] init:(2 * model.close.value / self.fullBaseValue + ([YXKLineConfigManager shareInstance].ema.ema_20 - 1) * self.kline.list[index - 1].ema20.value) / ([YXKLineConfigManager shareInstance].ema.ema_20 + 1)];
        }
        if (model.ema60.value == 0) {
            model.ema60 = [[NumberDouble alloc] init:(2 * model.close.value / self.fullBaseValue + ([YXKLineConfigManager shareInstance].ema.ema_60 - 1) * self.kline.list[index - 1].ema60.value) / ([YXKLineConfigManager shareInstance].ema.ema_60 + 1)];
        }
    }
}

#pragma mark - MA
- (void)calMAValueWithIndex:(NSInteger)index andObj:(YXKLine *)model {
    if (model.ma5.value == 0 && ![YXKLineConfigManager shareInstance].ma.ma_5_isHidden) {
        NSInteger ma5Num = [YXKLineConfigManager shareInstance].ma.ma_5;
        model.ma5 = [self getCloseAvgWithMANumWithCount:ma5Num andList:self.kline.list andIndex:index];
    }
    if (model.ma20.value == 0 && ![YXKLineConfigManager shareInstance].ma.ma_20_isHidden) {
        NSInteger ma20Num = [YXKLineConfigManager shareInstance].ma.ma_20;
        model.ma20 = [self getCloseAvgWithMANumWithCount:ma20Num andList:self.kline.list andIndex:index];
    }
    if (model.ma60.value == 0 && ![YXKLineConfigManager shareInstance].ma.ma_60_isHidden) {
        NSInteger ma60Num = [YXKLineConfigManager shareInstance].ma.ma_60;
        model.ma60 = [self getCloseAvgWithMANumWithCount:ma60Num andList:self.kline.list andIndex:index];
    }
    if (model.ma120.value == 0 && ![YXKLineConfigManager shareInstance].ma.ma_120_isHidden) {
        NSInteger ma120Num = [YXKLineConfigManager shareInstance].ma.ma_120;
        model.ma120 = [self getCloseAvgWithMANumWithCount:ma120Num andList:self.kline.list andIndex:index];
    }
    if (model.ma250.value == 0 && ![YXKLineConfigManager shareInstance].ma.ma_250_isHidden) {
        NSInteger ma250Num = [YXKLineConfigManager shareInstance].ma.ma_250;
        model.ma250 = [self getCloseAvgWithMANumWithCount:ma250Num andList:self.kline.list andIndex:index];
    }
}

#pragma mark - BOLL
- (void)calBollValueWithIndex:(NSInteger)index andObj:(YXKLine *)model {

    NSInteger cycle1 = [YXKLineConfigManager shareInstance].boll.cycle_1;
    NSInteger cycle2 = [YXKLineConfigManager shareInstance].boll.cycle_2;
    model.bollMA20 = [self getCloseAvgWithMANumWithCount:cycle1 andList:self.kline.list andIndex:index];
    //boll
    if (index >= cycle1 - 1) {
        model.BOLL_SUBMD = [[NumberDouble alloc] init:(model.close.value * 1.0 / self.fullBaseValue- model.bollMA20.value) * (model.close.value /self.fullBaseValue - model.bollMA20.value)];

        model.BOLL_SUBMD_SUM = [[NumberDouble alloc] init:self.kline.list[index - 1].BOLL_SUBMD_SUM.value + model.BOLL_SUBMD.value];

        double sum = 0.0;
        for (NSInteger x = index; x >= index - (cycle1 - 1); x --) {
            sum += (self.kline.list[x].close.value / self.fullBaseValue - model.bollMA20.value) * (self.kline.list[x].close.value / self.fullBaseValue - model.bollMA20.value);
        }
        model.bollMD = [[NumberDouble alloc] init:sqrtf(sum / cycle1)];

        model.bollMB = [[NumberDouble alloc] init:model.bollMA20.value];

        model.bollUP = [[NumberDouble alloc] init:model.bollMB.value + cycle2 * model.bollMD.value];

        model.bollDN = [[NumberDouble alloc] init:model.bollMB.value - cycle2 * model.bollMD.value];
    }
}

#pragma mark - MACD
- (void)calMACDValueWithIndex:(NSInteger)index andObj:(YXKLine *)model {
    NSInteger cycle1 = [YXKLineConfigManager shareInstance].macd.cycle_1;
    NSInteger cycle2 = [YXKLineConfigManager shareInstance].macd.cycle_2;
    NSInteger cycle3 = [YXKLineConfigManager shareInstance].macd.cycle_3;
    if (index == 0) {
        model.MACD_MA12 = [[NumberDouble alloc] init: model.close.value / self.fullBaseValue];
        model.MACD_MA26 = [[NumberDouble alloc] init: model.close.value / self.fullBaseValue];
        model.DIF = [[NumberDouble alloc] init: 0];
        model.DEA = [[NumberDouble alloc] init: 0];
        model.MACD = [[NumberDouble alloc] init: 0];
    } else {
        if (model.MACD_MA12.value == 0) {
            model.MACD_MA12 = [[NumberDouble alloc] init:(self.kline.list[index - 1].MACD_MA12.value * (cycle1 - 1) + 2 * model.close.value / self.fullBaseValue) / (cycle1 + 1)];
        }
        if (model.MACD_MA26.value == 0) {
            model.MACD_MA26 = [[NumberDouble alloc] init: (self.kline.list[index - 1].MACD_MA26.value * (cycle2 - 1) + 2 * model.close.value / self.fullBaseValue) / (cycle2 + 1)];
        }
        model.DIF = [[NumberDouble alloc] init:model.MACD_MA12.value - model.MACD_MA26.value];
        model.DEA = [[NumberDouble alloc] init:(self.kline.list[index - 1].DEA.value * (cycle3 - 1) + 2 * model.DIF.value) / (double)(cycle3 + 1)];
        model.MACD = [[NumberDouble alloc] init: 2 * (model.DIF.value - model.DEA.value)];
    }
}

#pragma mark - SAR
- (void)calSARValue {

    // 周期宏
    NSInteger SAR_mNaCycle = [YXKLineConfigManager shareInstance].sar.cycle_1;
    NSInteger SAR_mNbCycle = [YXKLineConfigManager shareInstance].sar.cycle_2;
    NSInteger SAR_mNcCycle = [YXKLineConfigManager shareInstance].sar.cycle_3;

    NSInteger listSize = self.kline.list.count;

    if (SAR_mNaCycle >= listSize) {
        return;
    }

    int sarLong = 0;
    int sarShort = 1;

    int flag = sarLong;
    double sar = self.kline.list[0].low.value;
    double sip = self.kline.list[0].high.value;
    double preSip;
    double af = SAR_mNbCycle / 100.0;

    YXKLine *preNode = nil;
    YXKLine *node = nil;

    for (int i = 0; i < listSize; ++i) {
        preNode = node;
        node = self.kline.list[i];

        if (i < SAR_mNaCycle - 1) {
            sar = MIN(sar, node.low.value);
            continue;
        }
        if (i == SAR_mNaCycle - 1) {
            sar = MIN(sar, node.low.value);
            node.sar = [[NumberDouble alloc] init:sar];
            continue;
        }

        preSip = sip;
        if (flag == sarLong) {
            if (node.low.value < self.kline.list[i-1].sar.value) {
                flag = sarShort;
                sip = node.low.value;
                af = SAR_mNbCycle / 100.0;
                sar = MAX(node.high.value, preNode.high.value);
                sar = MAX(sar, preSip + af * (sip - preSip));
            } else {
                flag = sarLong;
                if (node.high.value > preSip) {
                    sip = node.high.value;
                    af = MIN(af + SAR_mNbCycle / 100.0, SAR_mNcCycle / 100.0);
                }
                sar = MIN(node.low.value, preNode.low.value);
                sar = MIN(sar, self.kline.list[i-1].sar.value + af * (sip - self.kline.list[i-1].sar.value));
            }
        } else {
            if (node.high.value > self.kline.list[i-1].sar.value) {
                flag = sarLong;
                sip = node.high.value;
                af = SAR_mNbCycle / 100.0;
                sar = MIN(node.low.value, preNode.low.value);
                sar = MIN(sar, self.kline.list[i-1].sar.value + af * (sip - preSip));
            } else {
                flag = sarShort;
                if (node.low.value < preSip) {
                    sip = node.low.value;
                    af = MIN(af + SAR_mNbCycle / 100.0, SAR_mNcCycle / 100.0);
                }
                sar = MAX(node.high.value, preNode.high.value);
                sar = MAX(sar, self.kline.list[i-1].sar.value + af * (sip - self.kline.list[i-1].sar.value));
            }
        }

        node.sar = [[NumberDouble alloc] init:sar];

    }

}

#pragma mark - VOL
- (void)calVolumnValueWithIndex:(NSInteger)index andObj:(YXKLine *)model {

    if (model.MVOL5.value == 0 && ![YXKLineConfigManager shareInstance].mavol.mavol_5_isHidden) {
        model.MVOL5 = [self getVloumnNumWithCount:[YXKLineConfigManager shareInstance].mavol.mavol_5 andList:self.kline.list andIndex:index andModel:model];
    }
    if (model.MVOL10.value == 0 && ![YXKLineConfigManager shareInstance].mavol.mavol_10_isHidden) {
        model.MVOL10 = [self getVloumnNumWithCount:[YXKLineConfigManager shareInstance].mavol.mavol_10 andList:self.kline.list andIndex:index andModel:model];
    }
    if (model.MVOL20.value == 0 && ![YXKLineConfigManager shareInstance].mavol.mavol_20_isHidden) {
        model.MVOL20 = [self getVloumnNumWithCount:[YXKLineConfigManager shareInstance].mavol.mavol_20 andList:self.kline.list andIndex:index andModel:model];
    }
}

- (NumberDouble *)getVloumnNumWithCount:(NSInteger)count andList:(NSArray *)array andIndex: (NSInteger)index andModel:(YXKLine *)model {
    if (index >= count - 1) {
        if (self.isHKIndex) {
            NSArray *subArray = [array subarrayWithRange:NSMakeRange(index-count+1, count)];
            double avg = [[subArray valueForKeyPath:@"@avg.amount.value"] longLongValue];
            return [[NumberDouble alloc] init:avg];
        } else {
            NSArray *subArray = [array subarrayWithRange:NSMakeRange(index-count+1, count)];
            double avg = [[subArray valueForKeyPath:@"@avg.volume.value"] longLongValue];
            return [[NumberDouble alloc] init:avg];
        }
    } else {
        return nil;
    }
}

//对Model数组进行排序，初始化每个Model的最新9Clock的最低价和最高价
- (void)rangeLastNinePriceByArray:(NSArray<YXKLine *> *)models condition:(NSComparisonResult)cond
{
    switch (cond) {
            //最高价
        case NSOrderedAscending:
        {
        //            第一个循环结束后，ClockFirstValue为最小值
        for (NSInteger j = 7; j >= 1; j--)
            {
            NSNumber *emMaxValue = @0;

            NSInteger em = j;

            while ( em >= 0 )
                {
                double value = models[em].high.value / self.fullBaseValue;
                if([emMaxValue compare:[NSNumber numberWithFloat:value]] == cond)
                    {
                    emMaxValue = [NSNumber numberWithFloat:value];
                    }
                em--;
                }
            models[j].NineClocksMaxPrice = [[NumberDouble alloc] init:emMaxValue.doubleValue];
            }
        //第一个循环结束后，ClockFirstValue为最小值
        for (NSInteger i = 0, j = 8; j < models.count; i++,j++)
            {
            NSNumber *emMaxValue = @0;

            NSInteger em = j;

            while ( em >= i )
                {
                double value = models[em].high.value / self.fullBaseValue;
                if([emMaxValue compare:[NSNumber numberWithFloat:value]] == cond)
                    {
                    emMaxValue = [NSNumber numberWithFloat:value];
                    }
                em--;
                }
            models[j].NineClocksMaxPrice = [[NumberDouble alloc] init:emMaxValue.doubleValue];
            }
        }
            break;
        case NSOrderedDescending:
        {
        //第一个循环结束后，ClockFirstValue为最小值

        for (NSInteger j = 7; j >= 1; j--)
            {
            NSNumber *emMinValue = @(10000000000);

            NSInteger em = j;

            while ( em >= 0 )
                {
                double lowValue = models[em].low.value / self.fullBaseValue;
                if([emMinValue compare:[NSNumber numberWithFloat:lowValue]] == cond)
                    {
                    emMinValue = [NSNumber numberWithFloat:lowValue];
                    }
                em--;
                }
            models[j].NineClocksMinPrice = [[NumberDouble alloc] init:emMinValue.doubleValue];
            }

        for (NSInteger i = 0, j = 8; j < models.count; i++,j++)
            {
            NSNumber *emMinValue = @(10000000000);

            NSInteger em = j;

            while ( em >= i )
                {
                double lowValue = models[em].low.value / self.fullBaseValue;
                if([emMinValue compare: [NSNumber numberWithFloat:lowValue]] == cond)
                    {
                    emMinValue = [NSNumber numberWithFloat:lowValue];
                    }
                em--;
                }
            models[j].NineClocksMinPrice = [[NumberDouble alloc] init:emMinValue.doubleValue];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - ARBR
/**
 * K线-情绪指标（BRAR）
 * AR指标的计算方法
 * AR指标是通过比较一段周期内的开盘价在该周期价格中的高低。从而反映市场买卖人气的技术指标。
 * 以计算周期为日为例，其计算公式为：
 * N日AR=(N日内（H－O）之和除以N日内（O－L）之和)*100
 * 其中，H为当日最高价，L为当日最低价，O为当日开盘价，N为设定的时间参数，一般原始参数日设定为26日
 * <p>
 * BR指标的计算方法
 * BR指标是通过比较一段周期内的收盘价在该周期价格波动中的地位，来反映市场买卖意愿程度的技术指标。
 * 以计算周期为日为例，其计算公式为：
 * N日BR=N日内（H－CY）之和除以N日内（CY－L）之和*100
 * 其中，H为当日最高价，L为当日最低价，CY为前一交易日的收盘价，N为设定的时间参数，一般原始参数日设定为26日。
 */
- (void)calARBRValue {

    double arH = 0;
    double arL = 0;
    double brH = 0;
    double brL = 0;

    NSInteger BRAR_CYCLE = [YXKLineConfigManager shareInstance].arbr.cycle_1;
    YXKLine *node = nil;
    YXKLine *preNode = nil;

    for (int i = 0; i < self.kline.list.count; ++i) {
        node = self.kline.list[i];
        arH += node.high.value - node.open.value;
        arL += node.open.value - node.low.value;

        if (i > 0) {
            preNode = self.kline.list[i - 1];
        } else {
            preNode = nil;
        }

        brH += [self getNodeBrHWith:preNode andNode:node];
        brL += [self getNodeBrLWith:preNode andNode:node];

        if (i >= BRAR_CYCLE - 1) {
            if (arL == 0) {
                node.AR = [[NumberDouble alloc] init:0];
            } else {
                node.AR = [[NumberDouble alloc] init:arH / arL * 100];
            }

            if (brL == 0) {
                node.BR = [[NumberDouble alloc] init:0];
            } else {
                node.BR = [[NumberDouble alloc] init:brH / brL * 100];
            }

            node = self.kline.list[i - (BRAR_CYCLE - 1)];

            arH -= node.high.value - node.open.value;
            arL -= node.open.value - node.low.value;

            if (i - (BRAR_CYCLE - 1) > 0) {
                preNode = self.kline.list[i - (BRAR_CYCLE - 1) - 1];
            } else {
                preNode = nil;
            }

            brH -= [self getNodeBrHWith:preNode andNode:node];
            brL -= [self getNodeBrLWith:preNode andNode:node];
        }
    }
}

- (double)getNodeBrLWith:(YXKLine *)preNode andNode:(YXKLine *)node {
    double pClose = preNode != nil ? preNode.close.value : node.preClose.value;

    return MAX(0, pClose - node.low.value);
}

- (double)getNodeBrHWith:(YXKLine *)preNode andNode:(YXKLine *)node {
    double pClose = preNode != nil ? preNode.close.value : node.preClose.value;

    return MAX(0, node.high.value - pClose);
}

#pragma mark - DMA
/**
 * K线-DMA技术指标
 *
 * DMA指标是平均线差指标的简称，它是一种趋势分析指标，由两条曲线组成，其中波动较快的曲线是DDD线，波动较慢的是AMA线。
 * 通过对这两条移动平均线的差值情况来分析股价的趋势，比较两条线的差值可以判断出某只股票的买入和卖出量的大小，并且可以预测未来的趋势变化。
 * 另外，对其了解较多的朋友可以发现该指标与常用的MACD指标类似，其实该指标是由MACD指标简化而来。
 *
 * DMA指标计算方式
 *  1.DIF:收盘价的N1日简单移动平均-收盘价的N2日简单移动平均
 *  2.AMA=DIF的M日简单移动平均
 *  3.参数N1为10，参数N2为50，参数M为10
 */
- (void)calDMAValue {
    if (self.kline.list.count == 0) {
        return;
    }

    NSInteger DMA_SHORT_CYCLE = [YXKLineConfigManager shareInstance].dma.cycle_1;
    NSInteger DMA_LONG_CYCLE = [YXKLineConfigManager shareInstance].dma.cycle_2;
    NSInteger AMA_CYCLE = [YXKLineConfigManager shareInstance].dma.cycle_3;

    double svSum = 0;
    double lvSum = 0;

    double sv = 0;
    double lv = 0;

    double avSum = 0;

    YXKLine *node = nil;
    for (int i = 0; i < self.kline.list.count; ++i) {
        node = self.kline.list[i];

        svSum += node.close.value / self.fullBaseValue;
        lvSum += node.close.value / self.fullBaseValue;

        if (i >= DMA_SHORT_CYCLE - 1) {
            sv = svSum / DMA_SHORT_CYCLE;
            svSum -= self.kline.list[i - (DMA_SHORT_CYCLE - 1)].close.value / self.fullBaseValue;
        }

        if (i >= DMA_LONG_CYCLE - 1) {
            lv = lvSum / DMA_LONG_CYCLE;
            lvSum -= self.kline.list[i - (DMA_LONG_CYCLE - 1)].close.value / self.fullBaseValue;

            node.mDIF = [[NumberDouble alloc] init:sv - lv];
            avSum += node.mDIF.value;

            if (i >= (DMA_LONG_CYCLE - 1) + (AMA_CYCLE - 1)) {
                node.mAMA = [[NumberDouble alloc] init:avSum / AMA_CYCLE];
                avSum -= self.kline.list[i - (AMA_CYCLE - 1)].mDIF.value;
            }
        }

    }
}

- (NumberDouble *)getCloseAvgWithMANumWithCount:(NSInteger)count andList:(NSArray *)array andIndex: (NSInteger)index {
    if (index >= count - 1) {
        NSArray *subArray = [array subarrayWithRange:NSMakeRange(index-count+1, count)];
        double avg = [[subArray valueForKeyPath:@"@avg.close.value"] doubleValue] / self.fullBaseValue;
        return [[NumberDouble alloc] init:avg];
    } else {
        return nil;
    }
}


#pragma mark - WR
/**
 * K线-WR技术指标
 * 威廉指标WR又叫威廉超买超卖指标，简称威廉指标，兼具超买超卖和强弱分界的指标；是由拉瑞·威廉（Larry William）在1973年发明的，是目前股市技术分析中比较常用的短期研判指标。
 * <p>
 * 计算公式
 * WR1:100*(HHV(HIGH,N1)-CLOSE)/(HHV(HIGH,N1)-LLV(LOW,N1));
 * WR2:100*(HHV(HIGH,6)-CLOSE)/(HHV(HIGH,6)-LLV(LOW,6));
 */
- (void)calWRValue {
    NSInteger listSize = self.kline.list.count;

    NSInteger WR1_CYCLE = [YXKLineConfigManager shareInstance].wr.cycle_1;
    NSInteger WR2_CYCLE = [YXKLineConfigManager shareInstance].wr.cycle_2;

    if (listSize < WR1_CYCLE && listSize < WR2_CYCLE) {
        return;
    }

    double maxHigh1 = 0;
    double minLow1 = 0;


    double maxHigh2 = 0;
    double minLow2 = 0;

    YXKLine *node;
    YXKLine *newNode;
    YXKLine *cycleStartNode;
    YXKLine *nextNode;
    NSInteger cycleStartIndex;

    BOOL isInit = NO;

    for (int i = 0; i < listSize; ++i) {
        node = self.kline.list[i];
        if (isInit) {
            maxHigh1 = MAX(node.high.value, maxHigh1);
            minLow1 = MIN(node.low.value, minLow1);

            maxHigh2 = MAX(node.high.value, maxHigh2);
            minLow2 = MIN(node.low.value, minLow2);
        } else {
            isInit = true;
            maxHigh1 = maxHigh2 = node.high.value;
            minLow1 = minLow2 = node.low.value;
        }

        if (i >= WR1_CYCLE - 1) {
            if ((maxHigh1 - minLow1) == 0) {
                node.WR1 = [[NumberDouble alloc] init: 0];
            } else {
                node.WR1 = [[NumberDouble alloc] init: 100 * (maxHigh1 - node.close.value) / (maxHigh1 - minLow1)];
            }
            if (i < listSize - 1) {
                cycleStartIndex = i - (WR1_CYCLE - 1);
                cycleStartNode = self.kline.list[cycleStartIndex];
                nextNode = self.kline.list[i + 1];
                if ((cycleStartNode.high.value == maxHigh1 && nextNode.high.value < maxHigh1) || (cycleStartNode.low.value == minLow1 && nextNode.low.value > minLow1)) {
                    //(第一个点是最大的 或者 是最小的) && (下一个点的最大值小于当前的最大值 或者 最小值大于当前的最小值）
                    isInit = false;
                    for (NSInteger j = cycleStartIndex + 1; j <= i; j++) {
                        newNode = self.kline.list[j];
                        if (isInit) {
                            maxHigh1 = MAX(newNode.high.value, maxHigh1);
                            minLow1 = MIN(newNode.low.value, minLow1);
                        } else {
                            isInit = true;
                            maxHigh1 = newNode.high.value;
                            minLow1 = newNode.low.value;
                        }
                    }
                }
            }
        }

        if (i >= WR2_CYCLE - 1) {
            if ((maxHigh2 - minLow2) == 0) {
                node.WR2 = [[NumberDouble alloc] init: 0];
            } else {
                node.WR2 = [[NumberDouble alloc] init: 100 * (maxHigh2 - node.close.value) / (maxHigh2 - minLow2)];
            }
            if (i < listSize - 1) {
                cycleStartIndex = i - (WR2_CYCLE - 1);
                cycleStartNode = self.kline.list[cycleStartIndex];
                nextNode = self.kline.list[i + 1];

                if ((cycleStartNode.high.value == maxHigh2 && nextNode.high.value < maxHigh2) || (cycleStartNode.low.value == minLow2 && nextNode.low.value > minLow2)) {
                    //(第一个点是最大的 或者 是最小的) && (下一个点的最大值小于当前的最大值 或者 最小值大于当前的最小值）
                    isInit = false;
                    for (NSInteger j = cycleStartIndex + 1; j <= i; j++) {
                        newNode = self.kline.list[j];
                        if (isInit) {
                            maxHigh2 = MAX(newNode.high.value, maxHigh2);
                            minLow2 = MIN(newNode.low.value, minLow2);
                        } else {
                            isInit = true;
                            maxHigh2 = newNode.high.value;
                            minLow2 = newNode.low.value;
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - EMV
/**
 * K线-EMV技术指标
 * 根据成交量和人气的变化，构成一个完整的股价系统循环。该指标指导投资者在人气聚集且成交量热络的时候买进股票，在成交量逐渐展现无力，其他投资者尚未察觉时，卖出股票
 * 计算公式
 A=（今日最高价+今日最低价）/2
 B=（昨日最高价+昨日最低价）/2
 C=今日最高价-今日最低价
 2.EM=（A-B）*C/今日成交额
 3.EMV=N日内的EM之和
 4.MAEMV=EMV的M日的简单移动平均
 *一般设定N日为14日，M日为9日
 */
- (void)calEMVValue {
    NSInteger len = self.kline.list.count;

    NSInteger EMV_N_CYCLE = [YXKLineConfigManager shareInstance].emv.cycle_1;
    NSInteger EMV_M_CYCLE = [YXKLineConfigManager shareInstance].emv.cycle_2;

    YXKLine *preNode = nil;
    YXKLine *headNode = nil;

    double priceAmpSum = 0;
    double volSum = 0;
    double emSum = 0;
    double emvSum = 0;
    double em;

    double volThan;
    double mid;

    NSInteger mEMBeginIndex = EMV_N_CYCLE - 1;

    NSInteger mEMVBeginIndex = EMV_N_CYCLE * 2 - 2;
    NSInteger mMAEMVBeginIndex = EMV_N_CYCLE * 2 + EMV_M_CYCLE - 3;

    NSMutableArray <NSNumber *> *emList = [NSMutableArray array];

    for (int i = 0; i < len; ++i) {
        YXKLine *node = self.kline.list[i];

        priceAmpSum += (node.high.value - node.low.value);
        volSum += node.volume.value;

        if (i >= mEMBeginIndex) {
            if (node.volume.value == 0) {
                volThan = 0;
            } else {
                volThan = (volSum / EMV_N_CYCLE) / node.volume.value;
            }

            if (node.high.value + node.low.value == 0) {
                mid = 0;
            } else {
                mid = ((node.high.value + node.low.value) - (preNode.high.value + preNode.low.value)) / (double)(node.high.value + node.low.value) * 100;
            }

            if (priceAmpSum == 0) {
                em = 0;
            } else {
                em = mid * volThan * (node.high.value - node.low.value) / (priceAmpSum / EMV_N_CYCLE);
            }
            [emList addObject:@(em)];
            emSum += em;

            headNode = self.kline.list[i - (EMV_N_CYCLE - 1)];

            volSum -= headNode.volume.value;
            priceAmpSum -= (headNode.high.value - headNode.low.value);

            if (i >= mEMVBeginIndex) {

                node.EMV = [[NumberDouble alloc] init:emSum / EMV_N_CYCLE];
                emSum -= emList.firstObject.doubleValue;
                [emList removeObjectAtIndex:0];
                emvSum += self.kline.list[i].EMV.value;

                if (i >= mMAEMVBeginIndex) {
                    node.AEMV = [[NumberDouble alloc] init:emvSum / EMV_M_CYCLE];
                    emvSum -= self.kline.list[i - (EMV_M_CYCLE - 1)].EMV.value;
                }
            }
        }

        preNode = node;
    }
}


#pragma mark - CR
- (void)calCRValue {
    NSInteger len = self.kline.list.count;

    NSInteger CR_CYCLE = [YXKLineConfigManager shareInstance].cr.cycle_1;

    YXKLine *pre_point = nil;
    double mid, rise, fall;
    double cr = 0.0;
    //上升值求和
    double riseSum = 0.0;
    // 下跌值求和
    double fallSum = 0.0;
    NSMutableArray <NSNumber *> *riseList = [NSMutableArray array];
    NSMutableArray <NSNumber *> *fallList = [NSMutableArray array];

    //四个元素,每个元素对应一个cr的列表
    NSMutableArray <NSMutableArray *> *ma_sum_arr = [NSMutableArray arrayWithCapacity:4];
    //四个元素,每个元素对应一个cr均值列表
    NSMutableArray <NSMutableArray *> *cr_ma_arr = [NSMutableArray arrayWithCapacity:4];
    //四个元素,每个元素对应一条均线的点数
    //    int[] ma_num = new int[4];
    NSMutableArray <NSNumber *> *ma_num = [NSMutableArray arrayWithCapacity:4];
    //cr值求和
    NSMutableArray <NSNumber *> *crSun = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        [ma_sum_arr addObject:[NSMutableArray array]];
        [cr_ma_arr addObject:[NSMutableArray array]];
        [crSun addObject:@(0)];
        [ma_num addObject:@(0)];
    }

    for (int i = 0; i < len; i++) {
        YXKLine *p = self.kline.list[i];
        if (i == 0) {
            pre_point = p;
        }
        //计算CR
        mid = (pre_point.high.value + pre_point.low.value) * 0.5;
        //上升值
        rise = MAX(p.high.value - mid, 0);
        [riseList addObject:@(rise)];
        //下跌值
        fall = MAX(mid - p.low.value, 0);
        [fallList addObject:@(fall)];
        riseSum += rise;
        fallSum += fall;
        if (fallSum != 0) {
            cr = riseSum / fallSum * 100;
            //            mCrValues[i] = cr;
            p.CR = [[NumberDouble alloc] init:cr];
        }

        if (riseList.count == CR_CYCLE) {
            double value = riseList.firstObject.doubleValue;
            riseSum -= value;
            [riseList removeObjectAtIndex:0];
        }
        if (fallList.count == CR_CYCLE) {
            double value = fallList.firstObject.doubleValue;
            fallSum -= value;
            [fallList removeObjectAtIndex:0];
        }

        for (int j = 0; j < 4; j++) {
            [ma_sum_arr[j] addObject:@(cr)];
            crSun[j] = @(cr + crSun[j].doubleValue);
            if (ma_sum_arr[j].count == self.nMCycle[j].intValue) {
                int nMCycleValue = self.nMCycle[j].intValue;
                if (nMCycleValue == 0) {
                    [cr_ma_arr[j] addObject:@(0)];
                } else {
                    [cr_ma_arr[j] addObject:@(crSun[j].doubleValue / nMCycleValue)];
                }
                ma_num[j] = @(ma_num[j].intValue + 1);

                NSNumber *value = (NSNumber *)ma_sum_arr[j].firstObject;
                crSun[j] = @(crSun[j].doubleValue - value.doubleValue);
                [ma_sum_arr[j] removeObjectAtIndex:0];
            }
            //后移n天
            if (ma_num[j].intValue > self.nMaRefumnCycle[j].intValue) {
                //                int validIndex = ma_num[j] - mMa_refnum[j] - 1;
                int validIndex = ma_num[j].intValue - self.nMaRefumnCycle[j].intValue - 1;
                if (j == 0){
                    NSNumber *crNumber = (NSNumber *)cr_ma_arr[j][validIndex];
                    double cr = [crNumber doubleValue];
                    p.CR1 = [[NumberDouble alloc] init:cr];
                } else if (j == 1) {
                    NSNumber *crNumber = (NSNumber *)cr_ma_arr[j][validIndex];
                    double cr = [crNumber doubleValue];
                    p.CR2 = [[NumberDouble alloc] init:cr];
                } else if (j == 2) {
                    NSNumber *crNumber = (NSNumber *)cr_ma_arr[j][validIndex];
                    double cr = [crNumber doubleValue];
                    p.CR3 = [[NumberDouble alloc] init:cr];
                } else if (j == 3){
                    NSNumber *crNumber = (NSNumber *)cr_ma_arr[j][validIndex];
                    double cr = [crNumber doubleValue];
                    p.CR4 = [[NumberDouble alloc] init:cr];
                }
            }

        }
        pre_point = p;
    }
}

/*
 
 MA20:MA(CLOSE,20);
 A:MA(MAX(MAX((HIGH-LOW),ABS(REF(CLOSE,1)-HIGH)),ABS(REF(CLOSE,1)-LOW)),20)/C*100;
 上轨1:MA20+MA20*A*0.01;
 下轨1:MA20-MA20*A*0.01;
 */

#pragma mark - usmart
- (void)calUsmartWithIndex:(NSInteger)index andObj:(YXKLine *)model {
    
    if (model.usmartA.value == 0) {
        NSInteger value = MAX(MAX(model.high.value - model.low.value, ABS(model.preClose.value - model.high.value)), ABS(model.preClose.value - model.low.value));
        model.usmartA = [[NumberDouble alloc] init:(value / self.fullBaseValue)];
    }
    
    if (index >= 20) {
        // 大于20开始计算
        if (model.usmartMA20.value == 0) {
            model.usmartMA20 = [self getCloseAvgWithMANumWithCount:20 andList:self.kline.list andIndex:index];
        }
        if (model.usmartA20.value == 0) {
            NSArray *subArray = [self.kline.list subarrayWithRange:NSMakeRange(index-20+1, 20)];
            double avg = [[subArray valueForKeyPath:@"@avg.usmartA.value"] doubleValue] / (model.close.value / self.fullBaseValue) * 100;
            model.usmartA20 = [[NumberDouble alloc] init:avg];
        }
        if (model.usmartUp.value == 0 || model.usmartDown.value == 0) {
            double value = model.usmartMA20.value * model.usmartA20.value * 0.01;
            double usmartUp = model.usmartMA20.value + value;
            double usmartDown = model.usmartMA20.value - value;
            
            model.usmartUp = [[NumberDouble alloc] init:usmartUp];
            model.usmartDown = [[NumberDouble alloc] init:usmartDown];
        }
    }
}

//初始化第一条数据
- (void)initFirstModel:(YXKLine *)model{

    //ma
    model.ma5 = [[NumberDouble alloc] init:0];
    model.ma20 = [[NumberDouble alloc] init:0];
    model.ma60 = [[NumberDouble alloc] init:0];
    model.ma120 = [[NumberDouble alloc] init:0];
    model.ma250 = [[NumberDouble alloc] init:0];

    //ema
    model.ema5 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];

    model.ema12 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
    model.ema26 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
    model.ema20 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
    model.ema60 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
    model.ema120 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
    model.ema250 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];

    //macd
    model.DEA = [[NumberDouble alloc] init:0];
    model.DIF = [[NumberDouble alloc] init:0];
    model.MACD = [[NumberDouble alloc] init:0];
    model.MACD_MA12 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
    model.MACD_MA26 = [[NumberDouble alloc] init:model.close.value / self.fullBaseValue];
}


- (NSMutableArray <NSNumber *>*)nMCycle {
    if (_nMCycle == nil) {
        _nMCycle = [[NSMutableArray alloc] init];
        NSUInteger ma1 = [YXKLineConfigManager shareInstance].cr.cycle_2;
        NSUInteger ma2 = [YXKLineConfigManager shareInstance].cr.cycle_3;
        NSUInteger ma3 = [YXKLineConfigManager shareInstance].cr.cycle_4;
        NSUInteger ma4 = [YXKLineConfigManager shareInstance].cr.cycle_5;
        [_nMCycle addObject:@(ma1)];
        [_nMCycle addObject:@(ma2)];
        [_nMCycle addObject:@(ma3)];
        [_nMCycle addObject:@(ma4)];
    }
    return _nMCycle;
}

- (NSMutableArray <NSNumber *>*)nMaRefumnCycle {
    if (_nMaRefumnCycle == nil) {
        _nMaRefumnCycle = [[NSMutableArray alloc] init];

        int ma1 = floor([YXKLineConfigManager shareInstance].cr.cycle_2 / 2.5 + 1);
        int ma2 = floor([YXKLineConfigManager shareInstance].cr.cycle_3 / 2.5 + 1);
        int ma3 = floor([YXKLineConfigManager shareInstance].cr.cycle_4 / 2.5 + 1);
        int ma4 = floor([YXKLineConfigManager shareInstance].cr.cycle_5 / 2.5 + 1);

        [_nMaRefumnCycle addObject:@(ma1)];
        [_nMaRefumnCycle addObject:@(ma2)];
        [_nMaRefumnCycle addObject:@(ma3)];
        [_nMaRefumnCycle addObject:@(ma4)];
    }
    return _nMaRefumnCycle;
}



@end
