//
//  YXUsmartSquareHomeViewModel.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXUsmartSquareHomeViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"
#import "YXBannerActivityModel.h"


@interface YXUsmartSquareHomeViewModel ()



@end


@interface YXUsmartSquareHomeViewModel ()


//@property (nonatomic, strong) YXQuoteRequest *guessUpAndDownQuoteRequest;

@property (nonatomic, strong) NSMutableArray *stockCommentList;

@property (nonatomic, strong) RACSignal *ipoZipSignal;


@end

@implementation YXUsmartSquareHomeViewModel


- (void)initialize {
    @weakify(self)
    
    // 初始化数据
    self.stockCommentList = [[NSMutableArray alloc] init];
    self.squareDefaultList = [[YXSquareManager getDefaultArr] mutableCopy];
    self.hotCommentList = [[NSMutableArray alloc] init];

    
    self.hotDiscussionCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(RACTuple *input) {
        @strongify(self);
        return [self refreshHotDiscussionRequest];
    }];
    
//    self.entranceConfigCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(RACTuple *input) {
//        @strongify(self)
//        return [self getModuleConfigData];
//    }];
//    self.ipoZipSignal = [RACSignal zip:@[[self requestIPOCountDataSignal], [self requestIPOADDataSignal], [self requestIPOListDataSignal]]];
    
}


- (RACSignal *)refreshHotDiscussionRequest {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXSquareHotDiscussionRequestModel *requestModel = [[YXSquareHotDiscussionRequestModel alloc] init];
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            YXHotDiscussionListModel *model = nil;
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                model = [YXHotDiscussionListModel yy_modelWithDictionary:responseModel.data];
            }
            [subscriber sendNext:model];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}
///  按钮配置
//- (RACSignal *)getModuleConfigData {
//    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//
//        YXModuleRequestModel *requestModel = [[YXModuleRequestModel alloc] init];
//        requestModel.moduleCategory = 3;
//        requestModel.market = @"squ";
//        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//        [request startWithBlockWithSuccess:^(__kindof YXModuleResponseModel *responseModel) {
//            if (responseModel.code == YXResponseStatusCodeSuccess) {
//                [subscriber sendNext:responseModel];
//                [subscriber sendCompleted];
//            } else {
//                [subscriber sendNext:nil];
//                [subscriber sendCompleted];
//            }
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//        }];
//
//        return  nil;
//    }];
//}


//- (RACSignal *)requestIPOCountDataSignal {
//
//    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        YXMarketIPORequestModel *requestModel = [[YXMarketIPORequestModel alloc] init];
//        requestModel.exchangeType = 50;
//        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//
//            if (responseModel.code == YXResponseStatusCodeSuccess) {
//                self.ipoTodayModel = [YXIPOTodayCountResModel yy_modelWithJSON:responseModel.data];
//            }
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//        }];
//
//        return nil;
//    }];
//}


//- (RACSignal *)requestIPOADDataSignal {
//
//    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        YXMarketIPOAdRequestModel *requestModel = [[YXMarketIPOAdRequestModel alloc] init];
//        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//
//            if (responseModel.code == YXResponseStatusCodeSuccess) {
//                self.ipoAdList = [NSArray array];
//                NSArray *list = [responseModel.data yx_arrayValueForKey:@"recommend_list"];
//                if (list.count > 0) {
//                    NSMutableArray *arrM = [NSMutableArray array];
//                    for (int i = 0; i < list.count; ++i) {
//                        if (i < 2) {
//                            NSDictionary *dic = list[i];
//                            YXIPOTodayCountItem *item = [[YXIPOTodayCountItem alloc] init];
//                            item.exchangeType = [dic yx_intValueForKey:@"exchange_id"];
//                            item.stockCode = [dic yx_stringValueForKey:@"secu_code"];
//                            item.stockName = [dic yx_stringValueForKey:@"company_name"];
//                            [arrM addObject:item];
//                        }
//                    }
//                    self.ipoAdList = [NSArray arrayWithArray:arrM];
//                }
//            }
//
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//        }];
//
//        return nil;
//    }];
//}

//- (RACSignal *)requestIPOListDataSignal {
//
//    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        YXNewStockPreMarketRequestModel *requestModel = [[YXNewStockPreMarketRequestModel alloc] init];
//        requestModel.status = 0;
//        requestModel.orderBy = @"latest_endtime";
//        requestModel.orderDirection = 1;
//        requestModel.pageNum = 1;
//        requestModel.pageSize = 30;
//        requestModel.pageSizeZero = false;
//        requestModel.exchangeType = 50;
//
//        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//            if (responseModel.code == YXResponseStatusCodeSuccess) {
//                self.ipoList = [NSArray array];
//                NSArray *list = [responseModel.data yx_arrayValueForKey:@"list"];
//                if (list.count > 0) {
//                    self.ipoList = [NSArray yy_modelArrayWithClass:[YXIPOTodayCountItem class] json:list];
//                }
//                self.ipoTodayModel.ipoAllList = self.ipoList;
//            }
//
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//        }];
//
//        return nil;
//    }];
//}



//- (void)reloadStockCommentWithCallBack:(void(^ _Nullable)(void))callBack {
//    [self.stockCommentList removeAllObjects];
//    // 新股
////    for (YXIPOTodayCountItem *item in self.ipoTodayModel.ipoAllList) {
////        NSString *market = item.exchangeType == 0 ? @"hk" : @"us";
////        NSString *code = [NSString stringWithFormat:@"%@%@", market, item.stockCode];
////        if (code > 0 &&  ![[YXSquareStockCommentManager shared].requsetList containsObject:code]) {
////            [self.stockCommentList addObject:code];
////        }
////    }
//
//    [[YXSquareStockCommentManager shared] getCommentDataWith:self.stockCommentList success:^{
//        if (callBack) {
//            callBack();
//        }
//    } fail:^{
//        if (callBack) {
//            callBack();
//        }
//    }];
//}

@end
