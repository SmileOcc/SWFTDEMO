//
//  YXMobileBrief1Label.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXMobileBrief1Label.h"
#import "YXDateToolUtility.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"

#define kYXMobileBrief1NumberFont [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]
#define kYXMobileBrief1DefaultColor [QMUITheme textColorLevel1]

@implementation YXMobileBrief1Label

+ (instancetype)labelWithMobileBrief1Type:(YXMobileBrief1Type)mobileBrief1Type {
    YXMobileBrief1Label *label = [[YXMobileBrief1Label alloc] init];
    label.font = kYXMobileBrief1NumberFont;
    label.textColor = kYXMobileBrief1DefaultColor;
    label.textAlignment = NSTextAlignmentRight;
    label.mobileBrief1Type = mobileBrief1Type;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.3;
    return label;
}

- (void)setMobileBrief1Object:(id<YXSecuMobileBrief1Protocol>)mobileBrief1Object {
    _mobileBrief1Object = mobileBrief1Object;
    
    int64_t change = mobileBrief1Object.change;
    UIColor *color;
    NSString *operator = @"";
    if (change > 0) {
        operator = @"+";
        color = [QMUITheme stockRedColor];
    } else if (change < 0) {
        color = [QMUITheme stockGreenColor];
    } else {
        color = [QMUITheme stockGrayColor];
    }
    
    NSString *priceBaseFormat = [NSString stringWithFormat:@"%%.%df", mobileBrief1Object.priceBase];
    if (mobileBrief1Object.isWarrants) {
        //轮证priceBase=4 小数点需要保留3位
        priceBaseFormat = [NSString stringWithFormat:@"%%.%df", 3];
    }
    NSString *priceBaseOperatorFormat = [NSString stringWithFormat:@"%@%@", operator, priceBaseFormat];
    switch (self.mobileBrief1Type) {
        case YXMobileBrief1TypeNow:
        {
            if (mobileBrief1Object.now > 0) {
                self.text = [NSString stringWithFormat:priceBaseFormat, mobileBrief1Object.now/pow(10, mobileBrief1Object.priceBase)];
            } else {
                self.text = @"--";
            }
            
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypeRoc:
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.roc/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypeChange:
        {
            self.text = [NSString stringWithFormat:priceBaseOperatorFormat, mobileBrief1Object.change/pow(10, mobileBrief1Object.priceBase)];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypeTurnoverRate:
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.turnoverRate/100.0];
        }
            break;
        case YXMobileBrief1TypeVolume:
        {
            self.attributedText = [YXToolUtility stocKNumberData:mobileBrief1Object.volume deciPoint:2 stockUnit:@"股" priceBase:0 numberFont:kYXMobileBrief1NumberFont unitFont:[UIFont systemFontOfSize:16]];
        }
            break;
        case YXMobileBrief1TypeAmount:
        {
            self.attributedText = [YXToolUtility stocKNumberData:mobileBrief1Object.amount deciPoint:2 stockUnit:@"" priceBase:mobileBrief1Object.priceBase numberFont:kYXMobileBrief1NumberFont unitFont:[UIFont systemFontOfSize:16]];
        }
            break;
        case YXMobileBrief1TypeAmp:
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.amp/100.0];
        }
            break;
        case YXMobileBrief1TypeVolumeRatio:
        {
            if (mobileBrief1Object.volumeRatio == 0) {
                self.text = @"--";
            } else {
                self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.volumeRatio/10000.0];
            }
        }
            break;
        case YXMobileBrief1TypeMarketValue:
        {
            if (mobileBrief1Object.totalMarketvalue == 0) {
                self.attributedText = [[NSMutableAttributedString alloc] initWithString:@"--" attributes:@{NSFontAttributeName: kYXMobileBrief1NumberFont, NSForegroundColorAttributeName: QMUITheme.textColorLevel1}];
            } else {
                self.attributedText = [YXToolUtility stocKNumberData:mobileBrief1Object.totalMarketvalue deciPoint:2 stockUnit:@"" priceBase:mobileBrief1Object.priceBase numberFont:kYXMobileBrief1NumberFont unitFont:[UIFont systemFontOfSize:16]];
            }
        }
            break;
        case YXMobileBrief1TypePe:
        {
            if (mobileBrief1Object.pe < 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"stock_detail_loss"];
            } else {
                self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.pe/10000.0];
            }
        }
            break;
        case YXMobileBrief1TypePb:
        {
            self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.pb/10000.0];
        }
            break;
        case YXMobileBrief1TypeMaturityDate:
        {
            if (mobileBrief1Object.expireDate != 0) {
                self.text = [YXDateHelper commonDateStringWithNumber:mobileBrief1Object.expireDate format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
                
                
            }else {
                self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypePremium:
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.premium/100.0];
        }
            break;
        case YXMobileBrief1TypeOutstandingPct:
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.outstandingRatio/10000.0];
        }
            break;
        case YXMobileBrief1TypeGearing:
        {
            self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.leverageRatio/10000.0];
        }
            break;
        case YXMobileBrief1TypeConversionRatio:
        {

            self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.exchangeRatio/10000.0];
           
        }
            break;
        case YXMobileBrief1TypeStrike:
        {
            if (mobileBrief1Object.strikePrice != 0) {
                self.text = [NSString stringWithFormat:@"%.3f", mobileBrief1Object.strikePrice/10000.0];
            }else {
                self.text = @"--";
            }
            
        }
            break;
        case YXMobileBrief1TypeOutsidePrice:
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.moneyness/100.0];
        }
            break;
        case YXMobileBrief1TypeImpliedVolatility:
        {
            if (mobileBrief1Object.impliedVolatility != 0) {
                self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.impliedVolatility/10000.0];
            }else {
                self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypeActualLeverage:
        {
            if (mobileBrief1Object.effectiveLeverage != 0) {
                self.text = [NSString stringWithFormat:@"%.2f", mobileBrief1Object.effectiveLeverage/10000.0];
            }else {
                self.text = @"--";
            }
            
        }
            break;
        case YXMobileBrief1TypeRecoveryPrice:
        {
            if (mobileBrief1Object.callPrice != 0) {
                self.text = [NSString stringWithFormat:@"%.3f", mobileBrief1Object.callPrice/10000.0];
            }else {
                self.text = @"--";
            }
            
        }
            break;
        case YXMobileBrief1TypeToRecoveryPrice:
        {
            if (mobileBrief1Object.toCallPrice != 0) {
                self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.toCallPrice/100.0];
            } else {
               self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypePriceFloor:
        {
            if (mobileBrief1Object.priceFloor != 0) {
                self.text = [NSString stringWithFormat:@"%.3f", mobileBrief1Object.priceFloor/10000.0];
            } else {
                self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypePriceCeiling:
        {
            if (mobileBrief1Object.priceCeiling != 0) {
                self.text = [NSString stringWithFormat:@"%.3f", mobileBrief1Object.priceCeiling/10000.0];
            } else {
                self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypeToPriceFloor:
        {
            if (mobileBrief1Object.toPriceFloor != 0) {
                self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.toPriceFloor/100.0];
            } else {
                self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypeToPriceCeiling:
        {
            if (mobileBrief1Object.toPriceCeiling != 0) {
                self.text = [NSString stringWithFormat:@"%.2f%%", mobileBrief1Object.toPriceCeiling/100.0];
            } else {
                self.text = @"--";
            }
        }
            break;
        case YXMobileBrief1TypeAccer5:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.accer5 > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.accer5 < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.accer5/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg5day:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_5day > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_5day < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_5day/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg10day:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_10day > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_10day < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_10day/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg30day:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_30day > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_30day < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_30day/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg60day:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_60day > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_60day < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_60day/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg120day:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_120day > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_120day < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_120day/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg250day:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_250day > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_250day < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_250day/100.0];
            self.textColor = color;
        }
            break;
        case YXMobileBrief1TypePctChg1year:
        {
            UIColor *color;
            NSString *operator = @"";
            if (mobileBrief1Object.pct_chg_1year > 0) {
                operator = @"+";
                color = [QMUITheme stockRedColor];
            } else if (mobileBrief1Object.pct_chg_1year < 0) {
                color = [QMUITheme stockGreenColor];
            } else {
                color = [QMUITheme stockGrayColor];
            }
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, mobileBrief1Object.pct_chg_1year/100.0];
            self.textColor = color;
        }
            break;
        default:
            break;
    }
}

- (void)setWarrantsModel:(YXWarrantsFundFlowRankItem *)warrantsModel {
    switch (self.mobileBrief1Type) {
        case YXMobileBrief1TypeYXSelection:
            self.text = warrantsModel.derivative.name.length > 0? warrantsModel.derivative.name : @"--";
            self.font = [UIFont systemFontOfSize:16];
            break;
        case YXMobileBrief1TypeLongPosition: {
            UIColor *color = [YXToolUtility stockChangeColor:warrantsModel.asset.longPosNetIn];
            self.attributedText = [YXToolUtility stocKNumberData:warrantsModel.asset.longPosNetIn deciPoint:2 stockUnit:@"" priceBase:warrantsModel.asset.priceBase numberFont:[UIFont systemFontOfSize:16]  unitFont:[UIFont systemFontOfSize:16] color:color];
            
        }
            break;
        case YXMobileBrief1TypeWarrantBuy: {
            UIColor *color = [YXToolUtility stockChangeColor:warrantsModel.asset.subNetIn];
            self.attributedText = [YXToolUtility stocKNumberData:warrantsModel.asset.subNetIn deciPoint:2 stockUnit:@"" priceBase:warrantsModel.asset.priceBase numberFont:[UIFont systemFontOfSize:16]  unitFont:[UIFont systemFontOfSize:16] color: color];
            
        }
            break;
        case YXMobileBrief1TypeWarrantBull: {
            UIColor *color = [YXToolUtility stockChangeColor:warrantsModel.asset.bullNetIn];
            self.attributedText = [YXToolUtility stocKNumberData:warrantsModel.asset.bullNetIn deciPoint:2 stockUnit:@"" priceBase:warrantsModel.asset.priceBase numberFont:[UIFont systemFontOfSize:16] unitFont:[UIFont systemFontOfSize:16] color: color];
            
        }
            break;
        case YXMobileBrief1TypeShortPosition: {
            UIColor *color = [YXToolUtility stockChangeColor:warrantsModel.asset.shortPosNetIn];
            self.attributedText = [YXToolUtility stocKNumberData:warrantsModel.asset.shortPosNetIn deciPoint:2 stockUnit:@"" priceBase:warrantsModel.asset.priceBase numberFont:[UIFont systemFontOfSize:16] unitFont:[UIFont systemFontOfSize:16] color: color];
            
        }
            break;
        case YXMobileBrief1TypeWarrantSell: {
            UIColor *color = [YXToolUtility stockChangeColor:warrantsModel.asset.putNetIn];
            self.attributedText = [YXToolUtility stocKNumberData:warrantsModel.asset.putNetIn deciPoint:2 stockUnit:@"" priceBase:warrantsModel.asset.priceBase numberFont:[UIFont systemFontOfSize:16] unitFont:[UIFont systemFontOfSize:16] color: color];
            
        }
            break;
        case YXMobileBrief1TypeWarrantBear: {
            UIColor *color = [YXToolUtility stockChangeColor:warrantsModel.asset.bearNetIn];
            self.attributedText = [YXToolUtility stocKNumberData:warrantsModel.asset.bearNetIn deciPoint:2 stockUnit:@"" priceBase:warrantsModel.asset.priceBase numberFont:[UIFont systemFontOfSize:16] unitFont:[UIFont systemFontOfSize:16] color: color];
            
        }
            break;
        default:
            break;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
