//
//  ZFBaseAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseAnalyticsAOP.h"

@implementation ZFCMSBaseAnalyticsAOP

- (NSString *)sourceKey {
    if (_sourceKey) {
        return _sourceKey;
    }
    _sourceKey = [ZFCMSBaseAnalyticsAOP sourceString:self.source];
    return _sourceKey;
}

- (void)setSource:(ZFAnalyticsAOPSource)source {
    if (_source != source) {
        _source = source;
        _sourceKey = [ZFCMSBaseAnalyticsAOP sourceString:self.source];
    }
}

+ (NSString *)sourceString:(ZFAnalyticsAOPSource)AOPSource {
    
    if (AOPSource == ZFAnalyticsAOPSourceHome) {
        return @"Home";
    } else if (AOPSource == ZFAnalyticsAOPSourceCommunityHome) {
        return @"Community";//未定
    } else if (AOPSource == ZFAnalyticsAOPSourceAccount) {
        return @"Account";//未定
    } else if (AOPSource == ZFAnalyticsAOPSourceGoodsDetail) {
        return @"GoodsDetail";//未定
    }
    return @"unKnow";
}

+ (NSString *)generateAnalyticsAopId:(NSString *)sourceKey {
    return [NSString stringWithFormat:@"%@_%d",sourceKey,arc4random() % 10000];
}

@end
