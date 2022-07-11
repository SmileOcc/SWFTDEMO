//
//  YXStockPickerResultLabel.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockPickerResultLabel.h"
#import "uSmartOversea-Swift.h"

#define kYXStockPickerNumberFont [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]
#define kYXStockPickerDefaultColor [QMUITheme textColorLevel1]

@implementation YXStockPickerResultLabel


+ (instancetype)labelWithFilterType:(NSInteger)filterType {
    YXStockPickerResultLabel *label = [[YXStockPickerResultLabel alloc] init];

    label.font = kYXStockPickerNumberFont;
    label.textColor = QMUITheme.textColorLevel2;
    label.textAlignment = NSTextAlignmentRight;
    label.filterType = filterType;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.7;
    return label;
}

- (void)setModel:(YXStockPickerList *)model {
    _model = model;

    double change = model.netchng;
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

    NSString *priceBaseFormat = [NSString stringWithFormat:@"%%.%ldf", (long)model.priceBase];

    NSString *priceBaseOperatorFormat = [NSString stringWithFormat:@"%@%@", operator, priceBaseFormat];

    YXStockFilterItemType type = self.filterType;
    switch (type) {
        case YXStockFilterItemTypeBoard:  //板块
        {
            if (model.board.count > 0) {
                self.text = [model.board componentsJoinedByString:@","];
            } else {
                self.text = @"--";
            }
        }
            break;

        case YXStockFilterItemTypeIndustry:  //行业
        {
            if (model.industry.name.length > 0) {
                self.text = model.industry.name;
            } else {
                self.text = @"--";
            }

        }
            break;
        case YXStockFilterItemTypeMargin:  //是否融资
        {
            if (model.margin > 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_yes"];
            } else {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_no"];
            }
        }
            break;
        case YXStockFilterItemTypeIndex:  //指数成分
        {
            if (model.index.count > 0) {
                NSString *indexString = @"";
                for (YXStockPickerIndustryModel *index in model.index) {
                    if (indexString.length > 0) {
                        indexString = [NSString stringWithFormat:@"%@，%@", indexString, index.name];
                    } else {
                        indexString = index.name;
                    }
                }
                self.text = indexString;
            } else {
                self.text = @"--";
            }

        }
            break;
        case YXStockFilterItemTypeHkschs:  //港股通
        {
            if (model.hkschs > 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_yes"];
            } else {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_no"];
            }
        }
            break;
        case YXStockFilterItemTypeAh:  //AH股
        {
            if (model.ah > 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_yes"];
            } else {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_no"];
            }
        }
            break;
        case YXStockFilterItemTypeExchange:  //交易所
        {
            if (model.exchange.length > 0) {
                self.text = model.exchange;
            } else {
                self.text = @"--";
            }
        }
            break;
        case YXStockFilterItemTypeHsschk:  //陆股通
        {
            if (model.hsschk > 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_yes"];
            } else {
                self.text = [YXLanguageUtility kLangWithKey:@"mine_no"];
            }
        }
            break;
        case YXStockFilterItemTypePrice:  //现价
        {
            if (model.price > 0) {
                self.text = [NSString stringWithFormat:priceBaseFormat, model.price];
            } else {
                self.text = @"--";
            }

            self.textColor = color;
        }
            break;
        case YXStockFilterItemTypePctchng: //涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", operator, model.pctchng * 100];
            self.textColor = color;
        }
            break;
        case YXStockFilterItemTypeNetchng://涨跌额
        {
            self.text = [NSString stringWithFormat:priceBaseOperatorFormat, model.netchng];
            self.textColor = color;
        }
            break;
        case YXStockFilterItemTypeTurnoverRate: //换手率
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.turnoverRate * 100];
        }
            break;
        case YXStockFilterItemTypeVolume: //成交量
        {
            self.text = [YXToolUtility stockData:model.volume deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit_en"] priceBase:0];
        }
            break;
        case YXStockFilterItemTypeAmount: //成交额
        {
            self.text = [YXToolUtility stockData:model.amount deciPoint:2 stockUnit:@"" priceBase:0];
        }
            break;

        case YXStockFilterItemTypeMktCap: //总市值
        {
            if (model.mktCap == 0) {
                self.text = @"--";
            } else {
                self.text = [YXToolUtility stockData:model.mktCap deciPoint:2 stockUnit:@"" priceBase:0];
            }
        }
            break;
        case YXStockFilterItemTypePeTTM: //市盈率动
        {
            if (model.peTTM < 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"stock_detail_loss"];
            } else {
                self.text = [NSString stringWithFormat:@"%.2f", model.peTTM];
            }
        }
            break;
        case YXStockFilterItemTypePe: //市盈率静
        {
            if (model.pe < 0) {
                self.text = [YXLanguageUtility kLangWithKey:@"stock_detail_loss"];
            } else {
                self.text = [NSString stringWithFormat:@"%.2f", model.pe];
            }
        }
            break;
        case YXStockFilterItemTypePb: //市净率
        {

            self.text = [NSString stringWithFormat:@"%.2f", model.pb];
        }
            break;
        case YXStockFilterItemTypeVolRatio: //量比
        {
            if (model.volRatio == 0) {
                self.text = @"--";
            } else {
                self.text = [NSString stringWithFormat:@"%.2f", model.volRatio];
            }
        }
            break;
        case YXStockFilterItemTypeCittThan: //委比
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.cittThan * 100];
        }
            break;
        case YXStockFilterItemTypeIssuedShare: //总股本
        {
            if (model.issuedShare == 0) {
                self.text = @"--";
            } else {

                self.text = [YXToolUtility stockData:model.issuedShare deciPoint:2 stockUnit:@"" priceBase:0];
            }
        }
            break;
        case YXStockFilterItemTypeFloatCap: //流通市值
        {
            if (model.floatCap == 0) {
                self.text = @"--";
            } else {
                self.text = [YXToolUtility stockData:model.floatCap deciPoint:2 stockUnit:@"" priceBase:0];
            }
        }
            break;
        case YXStockFilterItemTypeFloatShare: //流通股本
        {
            if (model.floatShare == 0) {
                self.text = @"--";
            } else {
                self.text = [YXToolUtility stockData:model.floatShare deciPoint:2 stockUnit:@"" priceBase:0];
            }
        }
            break;
        case YXStockFilterItemTypeListDate: //上市时间
        {

            if (model.listDate != 0) {

                self.text = [YXDateHelper commonDateStringWithNumber:model.listDate format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
            }else {
                self.text = @"--";
            }
        }
            break;

        case YXStockFilterItemTypeDivYield: // 股息率
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.divYield * 100];
        }
            break;
        case YXStockFilterItemTypeMainInflow: // 主力净流入
        {
            self.text = [YXToolUtility stockData:model.mainInflow deciPoint:2 stockUnit:@"" priceBase:0];
        }

            break;

        case YXStockFilterItemTypeRoe: // 净资产收益率
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.roe * 100];
        }
            break;
        case YXStockFilterItemTypeRoa: // 总资产收益率
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.roa * 100];
        }
            break;
        case YXStockFilterItemTypeEps: // 每股收益
        {
            self.text = [YXToolUtility stockData:model.eps deciPoint:2 stockUnit:@"" priceBase:0];
        }
            break;
        case YXStockFilterItemTypeBvps: // 每股净资产
        {
            self.text = [YXToolUtility stockData:model.bvps deciPoint:2 stockUnit:@"" priceBase:0];
        }
            break;
        case YXStockFilterItemTypeNetIncomeLtm: // 净利润
        {
            self.text = [YXToolUtility stockData:model.netIncomeLtm deciPoint:2 stockUnit:@"" priceBase:0];
        }
            break;

        case YXStockFilterItemTypeNetIncomeGRatio: // 净利润增长率
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.netIncomeGRatio * 100];
        }
            break;

        case YXStockFilterItemTypeBusinessIncome: // 营业收入
        {
            self.text = [YXToolUtility stockData:model.businessIncome deciPoint:2 stockUnit:@"" priceBase:0];
        }
            break;

        case YXStockFilterItemTypeBiYoyGRatio: // 营收同比增长率
        {
            self.text = [NSString stringWithFormat:@"%.2f%%", model.biYoyGRatio * 100];
        }
            break;
        case YXStockFilterItemTypeRangeChng5Day: //近5日涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChng5Day > 0 ? @"+" : @"", model.rangeChng5Day * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChng5Day];
        }
            break;
        case YXStockFilterItemTypeRangeChng10Day: //近10日涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChng10Day > 0 ? @"+" : @"", model.rangeChng10Day * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChng10Day];
        }
            break;
        case YXStockFilterItemTypeRangeChng30Day: //近30日涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChng30Day > 0 ? @"+" : @"", model.rangeChng30Day * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChng30Day];
        }
            break;
        case YXStockFilterItemTypeRangeChng60Day: //近60日涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChng60Day > 0 ? @"+" : @"", model.rangeChng60Day * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChng60Day];
        }
            break;
        case YXStockFilterItemTypeRangeChng120Day: //近120日涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChng120Day > 0 ? @"+" : @"", model.rangeChng120Day * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChng120Day];
        }
            break;
        case YXStockFilterItemTypeRangeChng250Day: //近250日涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChng250Day > 0 ? @"+" : @"", model.rangeChng250Day * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChng250Day];
        }
            break;
        case YXStockFilterItemTypeRangeChngThisYear: //今年以来涨跌幅
        {
            self.text = [NSString stringWithFormat:@"%@%.2f%%", model.rangeChngThisYear > 0 ? @"+" : @"", model.rangeChngThisYear * 100];
            self.textColor = [YXToolUtility changeColor:model.rangeChngThisYear];
        }
            break;
        default:
            break;
    }
}


@end
