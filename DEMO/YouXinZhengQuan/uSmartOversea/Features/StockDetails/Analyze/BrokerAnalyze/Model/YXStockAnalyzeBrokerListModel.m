//
//  YXStockAnalyzeBrokerListModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/3/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockAnalyzeBrokerListModel.h"

@implementation YXStockAnalyzeBrokerListDetailInfo

@end


@implementation YXStockAnalyzeBrokerListModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"blist" : [YXStockAnalyzeBrokerListDetailInfo class],
             @"slist" : [YXStockAnalyzeBrokerListDetailInfo class]};
}

@end


@implementation YXStockAnalyzeBrokerStockInfo

@end


@implementation YXStockAnalyzeDiagnoseScoreModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"list": [YXStockAnalyzeDiagnoseScoreDetailInfo class]};
}

@end

@implementation YXStockAnalyzeDiagnoseScoreDetailInfo


@end


@implementation YXStockAnalyzeTechnicalSignRankList


@end


@implementation YXStockAnalyzeTechnicalSummaryData


@end


@implementation YXStockAnalyzeTechnicalModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"sign_rank_list": [YXStockAnalyzeTechnicalSignRankList class]};
}

@end


@implementation YXAnalyzeEstimateSubModel

@end


@implementation YXAnalyzeEstimateModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"list": [YXAnalyzeEstimateSubModel class]};
}

@end
