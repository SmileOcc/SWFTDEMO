//
//  YXBrokerDetailModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerDetailModel.h"

@implementation YXBrokerDetailSubModel

- (void)setShortShares:(int64_t)shortShares {
    _shortShares = shortShares;
    _changeVolume = shortShares;
}

- (void)setVolume:(int64_t)volume {
    _volume = volume;
    _holdVolume = volume;
}

- (void)setShortSharesPct:(int64_t)shortSharesPct {
    _shortSharesPct = shortSharesPct;
    _holdRatio = shortSharesPct;
}

- (void)setScmHoldings:(int64_t)scmHoldings {
    _scmHoldings = scmHoldings;
    _holdVolume = scmHoldings;
}

- (void)setNetPurchaseAmount:(int64_t)netPurchaseAmount {
    _netPurchaseAmount = netPurchaseAmount;
    _changeVolume = netPurchaseAmount;
}

@end


@implementation YXBrokerDetailModel

// 声明自定义类参数类型
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"list" : [YXBrokerDetailSubModel class]};
}

@end
