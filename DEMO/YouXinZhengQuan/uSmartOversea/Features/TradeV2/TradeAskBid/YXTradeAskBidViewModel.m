//
//  YXTradeAskBidViewModel.m
//  YouXinZhengQuan
//
//  Created by youxin on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXTradeAskBidViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface YXTradeAskBidViewModel()
@property (nonatomic, strong) YXStockDetailTcpTimer *depthOrderTcpFilter;
@property (nonatomic, strong) YXStockDetailTcpTimer *depthChartTcpFilter;
@end

@implementation YXTradeAskBidViewModel

- (void)initialize {
    
    [super initialize];
//    YXStockDetailTcpFilter
    
    self.loadDepthOrderSubject = [RACSubject subject];
    self.loadDepthChartSubject = [RACSubject subject];
    @weakify(self)
    
    self.depthOrderTcpFilter = [[YXStockDetailTcpTimer alloc] initWithInterval:0.5 excute:^(YXDepthOrderData *model, Scheme scheme) {
        @strongify(self)
        
        [self.loadDepthOrderSubject sendNext:model];
    }];
    
    self.depthChartTcpFilter = [[YXStockDetailTcpTimer alloc] initWithInterval:0.5 excute:^(YXDepthOrderData *model, Scheme scheme) {
        @strongify(self)
        
        [self.loadDepthChartSubject sendNext:model];
    }];
    
    
    self.loadDepthOrderDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *dic) {
        @strongify(self);
        
        NSString *market = [dic yx_stringValueForKey:@"market"];
        NSString *symbol = [dic yx_stringValueForKey:@"symbol"];
        NSInteger type = 1;
        if ([market isEqualToString:kYXMarketSG]) {
            type = 10;
        }
        BOOL merge = [YXStockDetailUtility showDepthTradeCombineSamePrice];
        
        [self.depthOrderRequset cancel];
        @weakify(self)
        self.depthOrderRequset = [YXQuoteManager.sharedInstance subDepthOrderWithSecu:[[Secu alloc] initWithMarket:market symbol:symbol] type:type depthType: (merge ? YXSocketDepthTypeMerge : YXSocketDepthTypeNone) handler:^(YXDepthOrderData * _Nonnull model, enum Scheme scheme) {
            @strongify(self);
            [self.depthOrderTcpFilter onNext:model scheme:scheme];
        } failed:^{
            [self.loadDepthOrderSubject sendNext:nil];
        }];
        
        
        return [RACSignal empty];
    }];
    
    // 加载深度摆盘多空分布
    self.loadDepthChartDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *dic) {
        @strongify(self);
        
        NSString *market = [dic yx_stringValueForKey:@"market"];
        NSString *symbol = [dic yx_stringValueForKey:@"symbol"];
        NSInteger type = 1;
        if ([market isEqualToString:kYXMarketSG]) {
            type = 10;
        }
        [self.depthChartRequset cancel];
        @weakify(self);
        self.depthChartRequset = [YXQuoteManager.sharedInstance subDepthOrderWithSecu:[[Secu alloc] initWithMarket:market symbol:symbol] type:type depthType: YXSocketDepthTypeChart handler:^(YXDepthOrderData * _Nonnull model, enum Scheme scheme) {
            @strongify(self);
            [self.depthChartTcpFilter onNext:model scheme:scheme];
        } failed:^{
            @strongify(self);
            [self.loadDepthChartSubject sendNext:nil];
        }];

        return [RACSignal empty];
    }];
}

- (void)cancelRequest {
    [self.depthOrderRequset cancel];
    self.depthOrderRequset = nil;
    
    [self.depthChartRequset cancel];
    self.depthChartRequset = nil;
}

- (void)cancelTimer {
    [self.depthOrderTcpFilter invalidate];
    [self.depthChartTcpFilter invalidate];
}


@end
