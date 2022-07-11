//
//  YXStockDetailTradeStaticVModel.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockDetailTradeStaticVModel.h"

@interface YXStockDetailTradeStaticVModel ()

@property (nonatomic, strong, readwrite) YXSDWeavesDetailVModel *weavesVModel;
@property (nonatomic, strong, readwrite) YXSDDealStatisticalVModel *staticVModel;

@end

@implementation YXStockDetailTradeStaticVModel

- (void)initialize {
    self.weavesVModel = [[YXSDWeavesDetailVModel alloc] initWithServices:self.services params:self.params];
    self.staticVModel = [[YXSDDealStatisticalVModel alloc] initWithServices:self.services params:self.params];

    self.market = self.params[@"market"];
    
//    @weakify(self)
//    [self.willAppearSignal subscribeNext:^(id  _Nullable x) {
//        @strongify(self)
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectSocket) name:@"kYXSocketReconnectNotification" object:nil];
//    }];
//
//    [self.willDisappearSignal subscribeNext:^(id  _Nullable x) {
//        @strongify(self)
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//    }];
}

- (void)reconnectSocket{

}

@end
