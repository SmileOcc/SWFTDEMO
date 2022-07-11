//
//  YXSDWeavesDetailVModel.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDWeavesDetailVModel.h"
#import "uSmartOversea-Swift.h"
#import <YXKit/YXKit.h>
#import "NSDictionary+Category.h"
#import "YXTickerTradeTypeDefine.h"
#import "YXTickerTradeTypeDefine.h"

@interface YXSDWeavesDetailVModel()

//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double pClose;
@property (nonatomic, assign) double lastPrice;

@property (nonatomic, assign) BOOL isLoadTickMore;

@property (nonatomic, strong) YXTickData *tickData;
// 刷新间隔
@property (nonatomic, assign) double refreshTime;

@property (nonatomic, strong) NSDictionary *brokerDic;

@property (nonatomic, assign) NSInteger tickCount;
@property (nonatomic, assign) YXTimeShareLineType timeShareType;

@property (nonatomic, assign) int extra;

@end

@implementation YXSDWeavesDetailVModel


- (void)initialize {
    
    //market + symbol
    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
    self.name = self.params[@"name"];
    self.pClose = [self.params[@"pClose"] doubleValue];
    self.lastPrice = [self.params[@"lastPrice"] doubleValue];

    
    YXSocketGreyMarketType greyMarketType = [self.params[@"greyMarket"] integerValue];
    self.timeShareType = [self.params yx_intValueForKey:@"timeShareType"];
    
    self.extra = YXSocketExtraQuoteNone;
    if (greyMarketType == YXSocketGreyMarketTypeFutu) {
        self.extra = YXSocketExtraQuoteFutu;
    } else if ([[YXUserManager shared] getLevelWith:self.market] == QuoteLevelUsNational) {
        self.extra = YXSocketExtraQuoteUsNation;
    }
    
    self.secu = [[Secu alloc] initWithMarket:self.market symbol:self.symbol extra:self.extra];
    
    
    
    self.loadBasicQuotaDataSubject = [RACSubject subject];
    self.loadTickDataSubject = [RACSubject subject];
    
    [self loadDataSetting];
}

- (void)loadDataSetting {
    
    
    double limitTimer = [YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeStockRealquoteRefreshFreq] / 1000.0;
    @weakify(self);
    //加载quota盘面数据
    self.loadBasicQuotaDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *idsArr) {
        @strongify(self);
        [self.quoteRequset cancel];
        self.quoteRequset = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus: @[self.secu] level:[self getLevel] handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
            @strongify(self);
            
            if (scheme == SchemeTcp) {
                // 推送的数据过来, 限制3毫秒内不能刷新
                double time = CFAbsoluteTimeGetCurrent();
                if ((time - self.refreshTime) < limitTimer) {
                    return;
                }
                self.refreshTime = time;
            }

            YXV2Quote *quoteModel = list.firstObject;
            
            // 更新股票类型
            if (self.quotaModel == nil) {
                self.quotaModel = quoteModel;
            } else {
                self.quotaModel = quoteModel;
            }
            [self.loadBasicQuotaDataSubject sendNext:nil];
        } failed:^{
            [self.loadBasicQuotaDataSubject sendNext:nil];
        }];
        
        return [RACSignal empty];
    }];
    
    //MARK: TickData
    self.loadTickDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *lastTickDic) {
        @strongify(self)
        
        BOOL isMore = [lastTickDic yx_boolValueForKey:@"isMore"];
        if (isMore) {
            self.isLoadTickMore = YES;
            [self.tickRequset nextTickWithSucceed:^(BOOL noMore) {
                @strongify(self)
                self.isLoadTickMore = NO;

                if (noMore && self.tickCount == self.tickData.list.count) {

                } else {
                    self.tickCount = self.tickData.list.count;
                    [self.loadTickDataSubject sendNext:self.tickData];
                }

            } failed:^{
                @strongify(self)
                self.isLoadTickMore = NO;
                //[self.loadTickDataSubject sendNext:[self refreshTickData]];
            }];
        } else {
            [self.tickRequset cancel];
            self.isLoadTickMore = NO;
            /*http://szshowdoc.youxin.com/web/#/23?page_id=524
            --> quotes-dataservice(行情服务) -->v2-2(新协议、暗盘、全市场)
            --> Tick接口
            /quotes-dataservice-app/api/v2-2/tick */
            
            QuoteType quoteType = QuoteTypeIntraDay;
            if (self.timeShareType == YXTimeShareLineTypeAfter) {
                quoteType = QuoteTypeAfter;
            } else if (self.timeShareType == YXTimeShareLineTypePre) {
                quoteType = QuoteTypePre;
            } else if (self.timeShareType == YXTimeShareLineTypeAll) {
                quoteType = QuoteTypeSQuoteAll;
            }
            if (quoteType == QuoteTypeSQuoteAll) {
                self.tickRequset = [[YXQuoteManager sharedInstance] subFullTickQuoteWithSecu:self.secu level: [self getLevel] type: quoteType handler:^(YXTickData * _Nonnull tickData, enum Scheme scheme) {
                    @strongify(self);
                    self.tickData = tickData;
                    [self addTickTradeType];
                    if (self.isLoadTickMore) {
                        return ;
                    }
                    self.tickCount = tickData.list.count;
                    [self.loadTickDataSubject sendNext:self.tickData];
                } failed:^{
                    @strongify(self)
                    if (self.isLoadTickMore) {
                        return ;
                    }
                    [self.loadTickDataSubject sendNext:nil];
                }];
            } else {
                self.tickRequset = [[YXQuoteManager sharedInstance] subTickQuoteWithSecu:self.secu level: [self getLevel] type: quoteType handler:^(YXTickData * _Nonnull tickData, enum Scheme scheme) {
                    @strongify(self);
                    self.tickData = tickData;
                    [self addTickTradeType];
                    if (self.isLoadTickMore) {
                        return ;
                    }
                    self.tickCount = tickData.list.count;
                    [self.loadTickDataSubject sendNext:self.tickData];
                } failed:^{
                    @strongify(self)
                    if (self.isLoadTickMore) {
                        return ;
                    }
                    [self.loadTickDataSubject sendNext:nil];
                }];
            }

        }
        
        return [RACSignal empty];
    }];
}

- (QuoteLevel)getLevel {
    if (self.quotaModel && self.quotaModel.greyFlag.value > 0) {
        return QuoteLevelLevel2;
    }

    QuoteLevel level = [YXUserManager.shared getLevelWith:self.market];

    return level;
}

- (void)addTickTradeType {

    for (YXTick *detailModel in self.tickData.list) {
        
        if (detailModel.trdTypeString == nil) {
            //tick交易类型
            detailModel.trdTypeString = [self trdTypeString:detailModel.trdType.value];
        }

    }
}

- (NSString *)trdTypeString:(YXTickerTrdType)type  {
    //tick交易类型，数值与类型之间的对应关系为：4:P 22:M 100:Y 101:X 102:D 103:U
    NSString *trdType = @"";
    switch (type) {
            //HK
        case LATE_TRADE:
            trdType = @"P";
            break;
        case NON_DIRECT_OFF_EXCHANGE:
            trdType = @"M";
            break;
        case AUTO_MATCH_INTERNALIZED:
            trdType = @"Y";
            break;
        case DIRECT_OFF_EXCHANGE:
            trdType = @"X";
            break;
        case ODD_LOT_TRADE:
            trdType = @"D";
            break;
        case AUCTION_TRADE:
            trdType = @"U";
            break;
            //US
        case US_BUNCHED:
            trdType = @"B";
            break;
        case US_CASH:
            trdType = @"C";
            break;
        case US_INTERMARKET_SWEEP:
            trdType = @"F";
            break;
        case US_BUNCHED_SOLD:
            trdType = @"G";
            break;
        case US_PRICE_VIRIATION:
            trdType = @"H";
            break;
        case US_ODD_LOT:
            trdType = @"I";
            break;
        case US_RULE_127_Rule_155:
            trdType = @"K";
            break;
        case US_SOLD_LAST:
            trdType = @"L";
            break;
        case US_MARKET_CENTER_CLOSE:
            trdType = @"M";
            break;
        case US_NEXT_DAY:
            trdType = @"N";
            break;
        case US_MARKET_CENTER_OPENING:
            trdType = @"O";
            break;
        case US_PRIOR_REFERENCE_PRICE:
            trdType = @"P";
            break;
        case US_MARKET_CENTER_OPEN:
            trdType = @"Q";
            break;
        case US_SELLER:
            trdType = @"R";
            break;
        case US_FORM_T:
            trdType = @"T";
            break;
        case US_EXTENDED_TRADE_HOUR:
            trdType = @"U";
            break;
        case US_CONTINGENT:
            trdType = @"V";
            break;
        case US_AVERAGE_PRICE:
            trdType = @"W";
            break;
        case US_SOLD_OUT_OF_SEQUENCE:
            trdType = @"Z";
            break;
        case US_ODD_LOT_CROSS:
            trdType = @"0";
            break;
        case US_DERIVATIVELY_PRICED:
            trdType = @"4";
            break;
        case US_RE_OPENING_PRICE:
            trdType = @"5";
            break;
        case US_CLOSING_PRICE:
            trdType = @"6";
            break;
        case US_QUALIFIED_CONTINGENT:
            trdType = @"7";
            break;
        case US_CONSOLIDATED_LATE_PRC:
            trdType = @"9";
            break;
        default:
            break;
    }

    //下面这段是后台说值可能重复，要加的市场判断
//    if ([market isEqualToString:kYXMarketHK]) {
//        if (type > 200) {
//            trdType = @"";
//        }
//    } else if ([market isEqualToString:kYXMarketUS] || [market isEqualToString:kYXMarketUsOption]) {
//        if (type < 200) {
//            trdType = @"";
//        }
//    }

    return trdType;
}


@end
