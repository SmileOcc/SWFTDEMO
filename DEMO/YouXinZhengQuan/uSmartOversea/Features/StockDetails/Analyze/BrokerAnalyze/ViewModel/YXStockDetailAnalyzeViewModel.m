//
//  YXStockDetailAnalyzeViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockDetailAnalyzeViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXStockAnalyzeBrokerListModel.h"
#import "YXBrokerDetailViewModel.h"
#import "YXStockDetailBrokerHoldingVModel.h"
#import "NSDictionary+Category.h"
#import "YXStockDetailBrokerHoldingVC.h"
#import "YXBrokerDetailVC.h"

@interface YXStockDetailAnalyzeViewModel ()

@property (nonatomic, assign) YXTimerFlag tradingTimerFlag;
@property (nonatomic, assign) YXTimerFlag brokerTimerFlag;

@property (nonatomic, strong) NSArray *readStockList;
@property (nonatomic, assign) BOOL hasRight;

@end

@implementation YXStockDetailAnalyzeViewModel

- (void)initialize {
    self.symbol = [self.params yx_stringValueForKey:@"symbol"];
    self.name = [self.params yx_stringValueForKey:@"name"];
    self.market = [self.params yx_stringValueForKey:@"market"];
    self.preClose = [self.params yx_longLongValueForKey:@"preClose"];
    self.isHKVolumn = [self.params yx_boolValueForKey:@"isHKVolumn"];
    self.greyFlag = [self.params yx_boolValueForKey:@"greyFlag"];
    self.isStock = [self.params yx_boolValueForKey:@"isStock"];
    self.isWarrantCbbc = [self.params yx_boolValueForKey:@"isWarrantCbbc"];
    
    
    self.brokerType = 0;
    self.level = (int)[[YXUserManager shared] getLevelWith:self.market];
    
    @weakify(self)
    self.brokerListDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self brokerListData];
    }];

    self.brokerShareHoldingDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self brokerShareHoldingData];
    }];


    //跳转到经纪商持股详情
    self.pushToBrokerDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *input) {
        @strongify(self);
        NSMutableDictionary *param = @{@"symbol" : self.symbol,
                               @"market" : self.market,
                                @"name" : self.name}.mutableCopy;
        [param addEntriesFromDictionary:input];
        
        YXBrokerDetailViewModel *viewModel = [[YXBrokerDetailViewModel alloc] initWithServices:self.services params:param];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];

    //跳转详情
    self.pushToBrokerHoldingDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);

        NSMutableDictionary *params = @{
            @"name": self.name,
            @"symbol": self.symbol,
            @"market" : self.market,
            @"pClose": [@(self.preClose) stringValue],  //昨收
        }.mutableCopy;
        [params addEntriesFromDictionary:input];
        YXStockDetailBrokerHoldingVModel *detailViewModel = [[YXStockDetailBrokerHoldingVModel alloc] initWithServices:self.services params:params];
        [self.services pushViewModel:detailViewModel animated:YES];

        return [RACSignal empty];
    }];

    self.loadSellCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadSellData];
    }];

    self.loadSellMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadSellMoreData];
    }];

    self.loadHKVolumnCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadHKVolumnData];
    }];

    self.loadHKVolumnMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadHKVolumnMoreData];
    }];

    self.loadHKVolumnChangeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadHKVolumnChangeData];
    }];

    self.diagnoseScoreDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self diagnoseScoreData];
    }];

    self.diagnoseNumberDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self diagnoseNumberData];
    }];

    //跳转详情
    self.pushToAnalyzeDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);

        if ([YXUserManager isLogin]) {
            if (self.hasRight) {
                [self jumpDetail];
            } else {

                BOOL isRead = NO;

                NSString *stock = [NSString stringWithFormat:@"%@%@", self.market , self.symbol];
                for (NSDictionary *dic in self.readStockList) {
                    NSString *symbol = [dic yx_stringValueForKey:@"symbol"];
                    if ([symbol isEqualToString:stock]) {
                        isRead = YES;
                        break;
                    }
                }

                if (isRead) {
                    [self jumpDetail];
                } else {
                    if (self.number_surplus <= 0) {
                        [self showAnalyzeUpdateProAlert];
                    } else {
                        [self jumpDetail];
                    }
                }

            }
        } else {
            // 登录
            [(NavigatorServices *)self.services pushToLoginVCWithCallBack: nil];
        }

        return [RACSignal empty];
    }];

//    self.technicalInsightDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
//        @strongify(self)
//        return [self technicalInsightData];
//    }];

    self.pushToTechnicalDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self);
        if ([YXUserManager isLogin]) {
            if (input.boolValue) {
                [YXWebViewModel pushToWebVC: [YXH5Urls technicalDetailUrl: [NSString stringWithFormat:@"%@%@", self.market, self.symbol]]];
            } else {
                //引导升级
                NSString *title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"smart_pro_prompt3"], self.number_max];
                YXAlertView *alertView = [YXAlertView alertViewWithMessage:title];
                alertView.messageLabel.font = [UIFont systemFontOfSize:16];
                alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
                YXAlertAction *update = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"to_unlock"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
                    [YXWebViewModel pushToWebVC: [YXH5Urls goProUrl:@"XTDC_HK"]];
                }];
                YXAlertAction *cancel = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {

                }];
                [alertView addAction:cancel];
                [alertView addAction:update];

                [alertView showInWindow];

//                [YXSensorAnalyticsTrack trackWithEvent: YXSensorAnalyticsEventViewClick properties:@{
//                    YXSensorAnalyticsPropsConstants.propViewPage: @"个股详情",
//                    YXSensorAnalyticsPropsConstants.propViewName: @"形态洞察-解锁弹框"
//                }];
            }
        } else {
            // 登录
            [(NavigatorServices *)self.services pushToLoginVCWithCallBack: nil];
        }

        return [RACSignal empty];
    }];


    self.pushToChipExplainCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);

        [YXWebViewModel pushToWebVC: [YXH5Urls analyzeChipExplainUrl]];
        return [RACSignal empty];
    }];

    self.pushToChipDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        YXStockChipDetailViewModel *viewModel = [[YXStockChipDetailViewModel alloc] initWithMarket:self.market symbol:self.symbol name:self.name];
        [self.services pushPath:YXModulePathsChipDetail context:viewModel animated:YES];

        return [RACSignal empty];
    }];

    //跳转登录
    self.loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {

        // 登录
        [(NavigatorServices *)self.services pushToLoginVCWithCallBack: nil];

        return [RACSignal empty];
    }];

    
    self.estimateDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *input) {
        @strongify(self)
        return [self estimateDataSignalWithItem:input];
    }];
    
    self.warrantCbbcScoreDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self warrantCbbcScoreData];
    }];
}

- (void)showAnalyzeUpdateProAlert {
     //引导升级
    NSString *title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"smart_pro_prompt2"], self.number_max];
    YXAlertView *alertView = [YXAlertView alertViewWithMessage:title];
    alertView.messageLabel.font = [UIFont systemFontOfSize:16];
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
    YXAlertAction *update = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"to_unlock"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
        [YXWebViewModel pushToWebVC: [YXH5Urls goConsultationUnlockUrl]];
    }];
    YXAlertAction *cancel = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {

    }];
    [alertView addAction:cancel];
    [alertView addAction:update];

    [alertView showInWindow];

}

- (void)jumpDetail {

    [YXWebViewModel pushToWebVC: [YXH5Urls analyzeDetailUrl: [NSString stringWithFormat:@"%@%@", self.market, self.symbol]]];
}


- (RACSignal *)brokerListData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeBrokerListRequestModel *requestModel = [[YXStockAnalyzeBrokerListRequestModel alloc] init];
        requestModel.symbol = self.symbol;
        requestModel.market = self.market;
        if (self.level != QuoteLevelLevel2) {
            //经纪商持股非level2，从1日开始
            requestModel.type = self.brokerType + 1;
        } else {
            requestModel.type = self.brokerType;
        }

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXStockAnalyzeBrokerListModel *model = [YXStockAnalyzeBrokerListModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        }];
        return nil;
    }];
}

- (RACSignal *)brokerShareHoldingData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeBrokerListRequestModel *requestModel = [[YXStockAnalyzeBrokerListRequestModel alloc] init];
        requestModel.symbol = self.symbol;
        requestModel.market = self.market;
        requestModel.type = 5;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXStockAnalyzeBrokerListModel *model = [YXStockAnalyzeBrokerListModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        }];
        return nil;
    }];
}

// 卖空
- (RACSignal *)loadSellData{

    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        YXBrokerSellDetailRequestModel *requestModel = [[YXBrokerSellDetailRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        requestModel.direction = @"0";
        requestModel.nextPageRef = nil;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                self.sellModel = [YXBrokerDetailModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];

            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {

            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];

        return nil;
    }];

}

//加载数据
- (RACSignal *)loadSellMoreData{

    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        YXBrokerSellDetailRequestModel *requestModel = [[YXBrokerSellDetailRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        requestModel.direction = @"0";
        requestModel.nextPageRef = self.sellModel.nextPageRef;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];

        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                YXBrokerDetailModel *model = [YXBrokerDetailModel yy_modelWithJSON:responseModel.data];
                NSMutableArray *arrM;
                if (self.sellModel.list.count > 0) {
                    arrM = [NSMutableArray arrayWithArray:self.sellModel.list];
                } else {
                    arrM = [NSMutableArray array];
                }
                if (model.list.count > 0) {
                    [arrM addObjectsFromArray:model.list];
                }
                model.list = arrM;
                self.sellModel = model;
                [subscriber sendNext:nil];
                [subscriber sendCompleted];

            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }

            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {

            [subscriber sendNext:nil];
            [subscriber sendCompleted];

            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];

        }];

        return nil;
    }];

}

// 港股通
- (RACSignal *)loadHKVolumnData{

    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        YXBrokerHKVolumnDetailRequestModel *requestModel = [[YXBrokerHKVolumnDetailRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        requestModel.direction = @"0";
        requestModel.nextPageRef = nil;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                self.HKVolumnModel = [YXBrokerDetailModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];

            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {

            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];

        return nil;
    }];

}

//加载数据
- (RACSignal *)loadHKVolumnMoreData{

    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        YXBrokerHKVolumnDetailRequestModel *requestModel = [[YXBrokerHKVolumnDetailRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        requestModel.direction = @"0";
        requestModel.nextPageRef = self.HKVolumnModel.nextPageRef;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];

        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                YXBrokerDetailModel *model = [YXBrokerDetailModel yy_modelWithJSON:responseModel.data];
                NSMutableArray *arrM;
                if (self.HKVolumnModel.list.count > 0) {
                    arrM = [NSMutableArray arrayWithArray:self.HKVolumnModel.list];
                } else {
                    arrM = [NSMutableArray array];
                }
                if (model.list.count > 0) {
                    [arrM addObjectsFromArray:model.list];
                }
                model.list = arrM;
                self.HKVolumnModel = model;
                [subscriber sendNext:nil];
                [subscriber sendCompleted];

            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }

            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {

            [subscriber sendNext:nil];
            [subscriber sendCompleted];

            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];

        }];

        return nil;
    }];

}

// 港股通比例变更
- (RACSignal *)loadHKVolumnChangeData{

    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        YXBrokerHKVolumnChangeRequestModel *requestModel = [[YXBrokerHKVolumnChangeRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                self.hkVolumnChangeModel = [YXHkVolumnModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];

            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {

            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];

        return nil;
    }];

}

- (RACSignal *)diagnoseScoreData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeDiagnoseScoreRequestModel *requestModel = [[YXStockAnalyzeDiagnoseScoreRequestModel alloc] init];
        requestModel.symbol = [NSString stringWithFormat:@"%@%@",self.market, self.symbol];
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXStockAnalyzeDiagnoseScoreModel *model = [YXStockAnalyzeDiagnoseScoreModel yy_modelWithJSON:responseModel.data];
                if (responseModel.data[@"list"][@"score"] == nil || responseModel.data[@"list"][@"score"] == [NSNull null]) {
                    model.list.score = -1;
                }
                if (responseModel.data[@"list"][@"ranking_percentage"] == nil || responseModel.data[@"list"][@"ranking_percentage"] == [NSNull null]) {
                    model.list.ranking_percentage = -1;
                }
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        }];
        return nil;
    }];
}

- (RACSignal *)diagnoseNumberData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeDiagnosenumberRequestModel *requestModel = [[YXStockAnalyzeDiagnosenumberRequestModel alloc] init];

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {

                NSDictionary *dic = [responseModel.data yx_dictionaryValueForKey:@"user_right"];
                NSDictionary *countDic = [dic yx_dictionaryValueForKey:@"count"];
                self.number_surplus = [countDic yx_intValueForKey:@"count_surplus"];
                self.number_max = [countDic yx_intValueForKey:@"count_max"];
                self.readStockList = [responseModel.data yx_arrayValueForKey:@"list"];
                self.hasRight = [responseModel.data yx_boolValueForKey:@"has_right" defaultValue:NO];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}


- (RACSignal *)technicalInsightData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeTechnicalInsightRequestModel *requestModel = [[YXStockAnalyzeTechnicalInsightRequestModel alloc] init];
        requestModel.stockId = [NSString stringWithFormat:@"%@%@",self.market, self.symbol];
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {

                YXStockAnalyzeTechnicalModel *model = [YXStockAnalyzeTechnicalModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}


- (RACSignal *)estimateDataSignalWithItem:(NSString *)item {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeEsimatedRequestModel *requestModel = [[YXStockAnalyzeEsimatedRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.code = self.symbol;
        requestModel.item = item;

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                
                YXAnalyzeEstimateModel *model = [YXAnalyzeEstimateModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)warrantCbbcScoreData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeWarrantScoreRequestModel *requestModel = [[YXStockAnalyzeWarrantScoreRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {

                YXStockAnalyzeWarrantCbbcScoreModel *model = [YXStockAnalyzeWarrantCbbcScoreModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}



#pragma mark - 定时器相关
- (void)openTimer {
    @weakify(self)
    if (self.brokerTimerFlag > 0) {
        [self closeTimer];
    }
    self.brokerTimerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        if (self.brokerTimerSubject) {
            [self.brokerTimerSubject sendNext:nil];
        }
    } timeInterval:60 repeatTimes:NSIntegerMax atOnce:NO];
}

- (void)closeTimer {

    [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.brokerTimerFlag];
    self.brokerTimerFlag = 0;
}

@end
