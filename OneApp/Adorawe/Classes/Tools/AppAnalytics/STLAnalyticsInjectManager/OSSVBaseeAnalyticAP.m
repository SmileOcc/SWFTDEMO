//
//  OSSVBaseeAnalyticAP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBaseeAnalyticAP.h"

@implementation OSSVBaseeAnalyticAP

- (NSString *)sourceKey {
    if (_sourceKey) {
        return _sourceKey;
    }
    _sourceKey = [OSSVBaseeAnalyticAP sourceString:self.source];
    return _sourceKey;
}

- (void)setSource:(STLAppsflyerGoodsSourceType)source {
    if (_source != source) {
        _source = source;
        _sourceKey = [OSSVBaseeAnalyticAP sourceString:self.source];
    }
}

+ (NSString *)sourceString:(STLAppsflyerGoodsSourceType)AOPSource {
    return nil;
}

- (NSMutableDictionary *)sourecDic {
    if (!STLJudgeNSDictionary(_sourecDic)) {
        return @{}.mutableCopy;
    }
    if (![_sourecDic isKindOfClass:[NSMutableDictionary class]]) {
        _sourecDic = _sourecDic.mutableCopy;
    }
    return _sourecDic;
}


- (void)refreshDataSource
{
    if ([self.goodsAnalyticsSet count]) {
        [self.goodsAnalyticsSet removeAllObjects];
    }
}

- (NSMutableArray *)goodsAnalyticsSet
{
    if (!_goodsAnalyticsSet) {
        _goodsAnalyticsSet = [[NSMutableArray alloc] init];
    }
    return _goodsAnalyticsSet;
}


@end
