//
//  YXSortButton.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSortButton.h"
#import "UIButton+utility.h"
#import "uSmartOversea-Swift.h"

@implementation YXSortButton

+ (instancetype)buttonWithSortType:(YXMobileBrief1Type)mobileBrief1Type sortState:(YXSortState)sortState {
    YXSortButton *button = [YXSortButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.mobileBrief1Type = mobileBrief1Type;
    button.sortState = sortState;
    [button setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateNormal];
//    [button setButtonImagePostion:YXButtonSubViewPositonRight interval:2];
    button.imagePosition = QMUIButtonImagePositionRight;
    button.spacingBetweenImageAndTitle = 8;
    button.adjustsImageWhenHighlighted = NO;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 10.0 / 12;
    button.titleLabel.numberOfLines = 2;
    return button;
}

- (void)setMobileBrief1Type:(YXMobileBrief1Type)mobileBrief1Type {
    _mobileBrief1Type = mobileBrief1Type;
    [self updateMobileBrief1Type];
}

- (void)setSortState:(YXSortState)sortState {
    _sortState = sortState;
    [self updateSortStatus];
}

- (void)updateMobileBrief1Type {
    switch (_mobileBrief1Type) {
        case YXMobileBrief1TypeNow:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"market_now"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeRoc:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"market_roc"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeChange:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"market_change"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeTurnoverRate:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"market_turnoverRate"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeVolume:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"market_volume"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeAmount:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"market_amount"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeAmp:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_amplitude"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeVolumeRatio:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_vol_ratio"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeMarketValue:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_mkt_cap"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePe:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_pe"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePb:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_pb"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeMaturityDate:
            [self setTitle:@"到期日" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePremium:
            [self setTitle:@"溢价" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeOutstandingPct:
            [self setTitle:@"街货比" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeGearing:
            [self setTitle:@"杠杆比率" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeConversionRatio:
            [self setTitle:@"换股比率" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeStrike:
            [self setTitle:@"行使价" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeOutsidePrice:
            [self setTitle:@"价内/价外" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeImpliedVolatility:
            [self setTitle:@"引伸波幅" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeActualLeverage:
            [self setTitle:@"实际杠杆" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeRecoveryPrice:
            [self setTitle:@"回收价" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeToRecoveryPrice:
            [self setTitle:@"距回收价" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePriceCeiling:
            [self setTitle:@"上限价" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePriceFloor:
            [self setTitle:@"下限价" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeToPriceCeiling:
            [self setTitle:@"距上限" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeToPriceFloor:
            [self setTitle:@"距下限" forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeMarketValueAndNumber:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"warrants_value_qty"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeLastAndCostPrice:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"warrants_price_cost"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeDailyBalance:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"hold_daily_profit_loss"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeHoldingBalance:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"hold_position_profit_loss"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeDealAmount:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bubear_net_buy_qty"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeFundFlow:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bubear_net_capital_flow"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeDealRatio:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bubear_trade_volume"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeYXSelection:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bullbear_usmart_highlight2"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeLongPosition:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_interests_long"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeWarrantBuy:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bullbear_call_warrant"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeWarrantBull:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"warrants_bull"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeShortPosition:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_interests_short"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeWarrantSell:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bullbear_put_warrant"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeWarrantBear:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"warrants_bear"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeAccer5:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_5_min_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg5day:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_5_day_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg10day:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_10_day_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg30day:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_30_day_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg60day:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_60_day_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg120day:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_120_day_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg250day:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_250_day_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypePctChg1year:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"interval_52_week_chg"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeAvgSpread:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"average_premium"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeOpenOnTime:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"on_time_rate"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeLiquidity:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"warrant_liquidity"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeOneTickSpreadProducts:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"premium_quantity"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeOneTickSpreadDuration:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"percentage_premium_time"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeYXScore:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"bullbear_yxscore"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeInitialMargin:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"init_margin_funds"] forState:UIControlStateNormal];
            break;
        case YXMobileBrief1TypeInterestBearing:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"short_selling_interest"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)updateSortStatus {
    UIImage *image = nil;
    if (self.mobileBrief1Type == YXMobileBrief1TypeYXSelection
        || self.mobileBrief1Type == YXMobileBrief1TypeInitialMargin
        || self.mobileBrief1Type == YXMobileBrief1TypeInterestBearing) {
        self.userInteractionEnabled = NO;
        return;
    }else {
        self.userInteractionEnabled = YES;
    }
    
//    if (self.mobileBrief1Type == YXMobileBrief1TypeLastAndCostPrice) {
//        [self setImage:[UIImage imageNamed:@"trading_notice"] forState:UIControlStateNormal];
//        return;
//    }
    switch (_sortState) {
        case YXSortStateNormal:
            image = [UIImage imageNamed:@"hold_sort"];
            break;
        case YXSortStateDescending:
            image = [UIImage imageNamed:@"hold_sort_desc"];
            break;
        case YXSortStateAscending:
            image = [UIImage imageNamed:@"hold_sort_asc"];
            break;
        default:
            break;
    }
    [self setImage:image forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
