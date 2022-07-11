//
//  YXStockAnalyzeBrokerListModel.h
//  uSmartOversea
//
//  Created by youxin on 2020/3/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface YXStockAnalyzeBrokerListDetailInfo : YXModel
//经纪商代码
@property (nonatomic, strong) NSString *brokerCode;
//日期
@property (nonatomic, assign) long long date;
//持股比例
@property (nonatomic, assign) long long holdRatio;
//净买量
@property (nonatomic, assign) long long holdVolume;
@end


@interface YXStockAnalyzeBrokerListModel : YXModel

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) NSString *symbol;
//最近行情时间
@property (nonatomic, assign) long long latestTime;
//参与经纪商总数，真实值除以10000，目前只有请求参数type为5的时候不为0。
@property (nonatomic, assign) int brokerCount;
//参与经纪商总持股比例，真实值除以10000，目前只有请求参数type为5的时候不为0
@property (nonatomic, assign) long totalHoldRatio;
//十大买入经纪商
@property (nonatomic, strong) NSArray<YXStockAnalyzeBrokerListDetailInfo *> *blist;
//十大卖出经纪商
@property (nonatomic, strong) NSArray<YXStockAnalyzeBrokerListDetailInfo *> *slist;
@end


@interface YXStockAnalyzeBrokerStockInfo : YXModel

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *code;
@end


@interface YXStockAnalyzeDiagnoseScoreDetailInfo : YXModel
//运营能力得分
@property (nonatomic, assign) int capacity_score;
//行业平均运营能力得分
@property (nonatomic, assign) int avg_capacity_score;
//成长能力得分得分
@property (nonatomic, assign) int growth_score;
//行业平均成长性得分
@property (nonatomic, assign) int avg_growth_score;
//打败行业百分比
@property (nonatomic, assign) int industry_percentage;
//行业前景
@property (nonatomic, assign) int prospect_score;
//股息率得分
@property (nonatomic, assign) int rate_dividend_score;
//行业平均股息率得分
@property (nonatomic, assign) int avg_rate_dividend_score;
//盈利能力得分
@property (nonatomic, assign) int roe_score;
//行业平均盈利能力得分
@property (nonatomic, assign) int avg_roe_score;
//总得分
@property (nonatomic, assign) int score;
//估值水平得分
@property (nonatomic, assign) int valuation_score;
//行业平均估值水平得分
@property (nonatomic, assign) int avg_valuation_score;
//全港股排名
@property (nonatomic, strong) NSString *hk_rankings;
//行业名称
@property (nonatomic, strong) NSString *industry_name;
//行业排名
@property (nonatomic, strong) NSString *industry_rankings;
//股票名称
@property (nonatomic, strong) NSString *name;
//股票名称
@property (nonatomic, strong) NSString *symbol;
//诊股时间
@property (nonatomic, strong) NSString *update_time;
//行业类型
@property (nonatomic, strong) NSString *industry_type;
//行业平均资金流向
@property (nonatomic, assign) int avg_capital_flows_score;
//资金流向
@property (nonatomic, assign) int capital_flows_score;
//股价走势得分
@property (nonatomic, assign) int trend_score;
//股价走势行业得分
@property (nonatomic, assign) int avg_trend_score;
//全市场排名
@property (nonatomic, strong) NSString *rankings;
//打败百分比
@property (nonatomic, assign) int ranking_percentage;
@end

@interface YXStockAnalyzeDiagnoseScoreModel : YXModel
//小数点个数
@property (nonatomic, assign) NSInteger base;
//特性标签
@property (nonatomic, strong) NSString *tag_list;

//@property (nonatomic, assign) int currency;

@property (nonatomic, strong) YXStockAnalyzeDiagnoseScoreDetailInfo *list;

@end


@interface YXStockAnalyzeTechnicalSignRankList : YXModel

@property (nonatomic, strong) NSString *end_date;
@property (nonatomic, strong) NSString *event_type_id;
@property (nonatomic, strong) NSString *event_type_name;
//枚举值 S:看跌 L:看涨
@property (nonatomic, strong) NSString *trade_type;
//枚举值 S：短期 I：中期 L：长期
@property (nonatomic, strong) NSString *trading_horizon;

@end


@interface YXStockAnalyzeTechnicalSummaryData : YXModel

//看跌事件个数
@property (nonatomic, assign) NSInteger bearish_count;
//看涨事件个数
@property (nonatomic, assign) NSInteger bullish_count;
/*
能量图数据：填充（绝对值作为个数，正负表示红绿，默认四格）
中性：0中性特征
利好（正数）：1弱势牛市特征， 2牛市特征，3-4强势牛市特征
利空（负数）：1弱势熊市特征， 2熊市特征，3-4强势熊市特征
 */
@property (nonatomic, strong) NSString *normalized_score;
//支撑位
@property (nonatomic, strong) NSString *support;
//阻力位
@property (nonatomic, strong) NSString *resistance;
//止损位
@property (nonatomic, strong) NSString *stops_lower;


@end



@interface YXStockAnalyzeTechnicalModel : YXModel

@property (nonatomic, assign) NSInteger item_id;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, assign) BOOL not_show_flag;

@property (nonatomic, assign) BOOL jump_h5_flag;

@property (nonatomic, assign) NSInteger product_type;

@property (nonatomic, strong) NSArray<YXStockAnalyzeTechnicalSignRankList *> *sign_rank_list;
@property (nonatomic, strong) YXStockAnalyzeTechnicalSummaryData *summary_data;

@end



@interface YXAnalyzeEstimateSubModel : YXModel

@property (nonatomic, strong) NSString *date;

@property (nonatomic, assign) double value;

@property (nonatomic, assign) double mean;

@end

@interface YXAnalyzeEstimateModel : YXModel

@property (nonatomic, strong) NSString *itme;

@property (nonatomic, strong) NSString *updateTime;

@property (nonatomic, strong) NSArray <YXAnalyzeEstimateSubModel *>*list;

@end


NS_ASSUME_NONNULL_END
