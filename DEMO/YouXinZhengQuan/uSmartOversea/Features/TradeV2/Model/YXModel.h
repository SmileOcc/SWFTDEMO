//
//  YXModel.h
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

//#define kYXMapper @{\
//@"now": @"1",\
//@"pclose": @"2",\
//@"open": @"3",\
//@"high": @"4",\
//@"low": @"5",\
//@"highP1Y": @"14",\
//@"lowP1Y": @"15",\
//@"avg": @[@"18", @"45"],\
//@"price": @"19",\
//@"volume": @"20",\
//@"amount": @"21",\
//@"in_p": @"22",\
//@"out_p": @"23",\
//@"change": @"24",\
//@"roc": @"25",\
//@"amp": @"26",\
//@"turnoverRate": @"27",\
//@"pb": @"28",\
//@"yield": @"29",\
//@"yieldRatio": @"30",\
//@"peTtm": @"31",\
//@"pe": @"32",\
//@"cittthan": @"33",\
//@"cittdiff": @"34",\
//@"volumeRatio": @"35",\
//@"tradingUnit": @"37",\
//@"share": @"38",\
//@"total": @"39",\
//@"circulationValue" : @"40",\
//@"marketValue": @"41",\
//@"time": @[@"46", @"47", @"51"],\
//@"priceBase": @"53",\
//@"bid": @"94",\
//@"bidSize": @"95",\
//@"bidOrderNum": @"96",\
//@"ask": @"97",\
//@"askSize": @"98",\
//@"askOrderNum": @"99",\
//@"market": @"100",\
//@"symbol": @"101",\
//@"name": @"102",\
//@"enName": @"103",\
//@"pinyin": @"104",\
//@"type1": @"117",\
//@"type2": @"118",\
//@"type3": @"119",\
//@"listStatus" : @"120",\
//@"tradingUnit": @"124",\
//@"eps": @"129",\
//@"epsExp": @"130",\
//@"bvps": @"131",\
//@"nav": @"132",\
//@"marketStatus": @"133",\
//@"spread": @"134",\
//@"accer": @"135",\
//@"positionArray": @"138",\
//@"close": @"141",\
//@"premium": @"211",\
//@"infoTitle":@"2304",\
//@"media" : @"2301",\
//@"publishDate" : @"2300",\
//@"pdfAddress" : @"2312",\
//@"articleList" : @"2217",\
//@"newsId" : @"2000",\
//@"newsTag" : @"2001",\
//@"newsTitle" : @"2003",\
//@"newsSource" : @"2004",\
//@"newsTime" : @"2009",\
//@"newsType" : @"2225",\
//@"newsList" : @"2217",\
//@"currency" : @"currency"\
//}

#define kYXPBMapper @{\
@"highP1Y": @"high_p1y",\
@"lowP1Y": @"low_p1y",\
@"in_p": @"in",\
@"out_p": @"out",\
@"turnoverRate": @"turnover_rate",\
@"yieldRatio": @"yield_ratio",\
@"peTtm": @"pe_ttm",\
@"volumeRatio": @"volume_ratio",\
@"tradingUnit": @"trading_unit",\
@"circulationValue" : @"circulation_value",\
@"marketValue": @[@"circulation_value", @"marketValue"],\
@"priceBase": @"price_base",\
@"bidSize": @"bid_size",\
@"bidOrderNum": @"bid_order_num",\
@"askSize": @"ask_size",\
@"askOrderNum": @"ask_order_num",\
@"symbol": @"symbol",\
@"listStatus" : @"list_status",\
@"tradingUnit": @"trading_unit",\
@"epsExp": @"eps_exp",\
@"marketStatus": @"market_status",\
@"positionArray": @"position",\
@"tradingStatus": @"trading_status",\
@"preQuote": @"pre_quote",\
@"afterQuote": @"after_quote",\
}

@interface YXModel : NSObject


/**
 jason转model 主要封装三方，方便替换三方库

 @param json 字典
 @return 模型
 */
+ (instancetype)yxModelWithJSON:(id)json;


/**
 模型转字典

 @return 字典
 */
- (id)yxModelToJSONObject;


+ (NSArray *)mappedKeys;

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

@end
