//
//  YXNewStockPreMarketViewModel.m
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/19.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import "YXNewStockPreMarketViewModel.h"
#import "uSmartOversea-Swift.h"


//@class YXNewStockCenterPreMarketStockModel;
//@class YXNewStockCenterPreMarketModel;

@interface YXNewStockPreMarketViewModel()

@property (nonatomic, strong) NSMutableArray<YXNewStockCenterPreMarketStockModel2 *> *stockList;
@property (nonatomic, strong) YXRequest *request;

@end

@implementation YXNewStockPreMarketViewModel

- (void)initialize {
    [super initialize];
    
    HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
    if (netWorkStatus != HLNetWorkStatusNotReachable) {
        self.dataSource = @[];
    }
    
    self.stockStatus = ((NSNumber *)self.params[@"YXNewStockStatus"]).integerValue;
    
    //下拉刷新
    self.shouldPullToRefresh = NO;
    //上拉加载更多
    self.shouldInfiniteScrolling = YES;
    
    //页码
    self.page = 1;
    self.perPage = 30;
    if (self.stockStatus == YXNewStockStatusPurchase) {
        self.orderBy = @"latest_endtime";
        self.exchangeType = 0;
    } else {
        self.orderBy = @"listing_time";
        self.exchangeType = 50;
    }
    self.orderDirection = 1;
    
    //新股详情
    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath *indexPath) {
        @strongify(self)
        
        YXNewStockCenterPreMarketStockModel2 *stockModel = self.dataSource[indexPath.section][indexPath.row];
        if (stockModel.openApplyInfo == 1) {
            NSDictionary *dict = @{
                @"exchangeType": @(stockModel.exchangeType),
                @"ipoId": @(stockModel.ipoId.longLongValue),
                @"stockCode": stockModel.stockCode
            };
            [self.services pushPath:YXModulePathsNewStockDetail context:dict animated:YES];
        }else {
            NSString *market = kYXMarketHK;
            if (stockModel.exchangeType == 0) {
                market = kYXMarketHK;
            } else if (stockModel.exchangeType == 5) {
                market = kYXMarketUS;
            } else if (stockModel.exchangeType == 6) {
                market = kYXMarketChinaSH;
            }else if (stockModel.exchangeType == 7) {
                market = kYXMarketChinaSZ;
            }else if (stockModel.exchangeType == 67) {
                market = kYXMarketChina;
            }
            
            YXStockInputModel *input = [[YXStockInputModel alloc] init];
            input.market = market;
            input.symbol = stockModel.stockCode;
            input.name = stockModel.stockName;
            [self.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
        }
        
        return [RACSignal empty];
    }];

    [[RACObserve(self, orderDirection) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.requestRemoteDataCommand execute:@(1)];
    }];
    
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        
        if (self.request) {
            [self.request stop];
            self.request = nil;
        }
        self.page = page;
        YXNewStockPreMarketRequestModel *requestModel = [[YXNewStockPreMarketRequestModel alloc] init];
        requestModel.status = self.stockStatus;
        requestModel.orderBy = self.orderBy;
        requestModel.orderDirection = self.orderDirection;
        requestModel.pageNum = self.page;
        requestModel.pageSize = 30;
        requestModel.pageSizeZero = NO;
        requestModel.exchangeType = self.exchangeType;
        
        self.request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                
                if (self.page == 1) {
                    self.stockList = [NSMutableArray array];
                }
                YXNewStockCenterPreMarketModel2 *model = [YXNewStockCenterPreMarketModel2 yy_modelWithDictionary:responseModel.data];
                self.total = model.total;
                if (self.totalNewStockAmount) {
                    self.totalNewStockAmount(self.total);
                }
                BOOL hasGray = NO;
                if (self.stockStatus == YXNewStockStatusPreMarket) {
                    for (YXNewStockCenterPreMarketStockModel2 *item in model.list) {
                        if (item.greyFlag == 1) {
                            hasGray = YES;
                            break;
                        }
                    }
                    if (self.hasGrayBlock) {
                        self.hasGrayBlock(hasGray);
                    }
                }
                
                [self.stockList addObjectsFromArray:model.list];
                if ([self.stockList count] < model.total && [model.list count] != 0) {
                    self.loadNoMore = NO;
                } else {
                    self.loadNoMore = YES;
                }
                NSMutableArray *dataArr = [NSMutableArray array];
                [dataArr addObjectsFromArray:self.stockList];
                self.dataSource = @[dataArr];
                
                //判断是否区分高级普通账户
                BOOL financingAccountDiff = NO;
                for (YXNewStockCenterPreMarketStockModel2 *m in dataArr) {
                    if (m.financingAccountDiff > 0) {
                        financingAccountDiff = YES;
                    }
                }
                self.financingAccountDiff = financingAccountDiff;
                
                [subscriber sendNext:model];
                [subscriber sendCompleted];
                
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            self.dataSource = nil;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

@end
