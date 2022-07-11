//
//  YXStockFilterMarketGroupViewModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockFilterMarketGroupViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXStockPickerResultViewModel.h"
#import "YXStockPickerResultViewController.h"

@interface YXStockFilterMarketGroupViewModel()



@end

@implementation YXStockFilterMarketGroupViewModel

- (void)initialize {
    [super initialize];

    if(self.params[@"market"] != nil) {
        self.market = self.params[@"market"];
    } else {
        self.market = @"";
    }

    if ([self.market isEqualToString:@"all"]) {
        self.market = @"";
    }

    self.shouldPullToRefresh = YES;
    //self.shouldInfiniteScrolling = YES;

    HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
    if (netWorkStatus != HLNetWorkStatusNotReachable) {
        self.dataSource = @[];
    }

    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self)

        YXStockFilterUserFilterList *model = self.dataSource[indexPath.section][indexPath.row];

        QuoteLevel level = [[YXUserManager shared] getLevelWith:model.market];
        if (level == QuoteLevelDelay) {
            [self showDelayOrBmpAlert];
        } else {
            YXStockPickerResultViewModel *viewModel = [[YXStockPickerResultViewModel alloc] initWithServices:self.services params:@{@"market" : model.market, @"groups": model.groups, @"updateType": @(YXStockFilterOperationTypeQuery), @"groupName": (model.name ? : @"")}];
            [self.services pushViewModel:viewModel animated:YES];
        }
        return [RACSignal empty];
    }];


    self.saveResultCommand = [[RACCommand alloc] initWithSignalBlock:^(NSDictionary* _Nullable dic) {
        @strongify(self)

        NSString *name = dic[@"name"];
        int64_t identifier = [dic[@"idString"] longLongValue];
        YXStockFilterOperationType type = [dic[@"type"] integerValue];
        NSString *market = dic[@"market"];

        return [[self saveResultData:market optType:type identifier:identifier name:name] takeUntil:self.rac_willDeallocSignal];
    }];

}

- (void)showDelayOrBmpAlert {
    YXAlertView *alertView = [YXAlertView alertViewWithTitle:[YXLanguageUtility kLangWithKey:@"common_tips"] message:[YXLanguageUtility kLangWithKey:@"filter_delay_prompt"]];
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {

    }]];
    @weakify(self)
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"upgrade_immediately"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
        @strongify(self)
        [YXWebViewModel pushToWebVC:[YXH5Urls myQuotesUrl]];

    }]];

    [alertView showInWindow];
}


- (RACSignal *)requestWithOffset:(NSInteger)offset{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)


        YXStockFilterQueryUserRequestModel *requestModel = [[YXStockFilterQueryUserRequestModel alloc] init];
        requestModel.market = self.market;
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        //YXProgressHUD *hud = [YXProgressHUD showLoading:@""];  //转圈
        @weakify(self)
        [request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {
            @strongify(self)

            //[hud hideHud];
            YXStockFilterUserFilter *item = [YXStockFilterUserFilter yy_modelWithJSON:responseModel.data];

            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self.dataSource firstObject]];
            if (offset == 0) {
                array = [NSMutableArray array];
            }

            if (item.list.count > 0) {
                [array addObjectsFromArray:item.list];
                [subscriber sendNext:item];
            }
            self.dataSource = @[array];

            [subscriber sendCompleted];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendError:request.error];
        }];
        return nil;
    }];
}


- (RACSignal *)saveResultData:(NSString *)market optType:(YXStockFilterOperationType)type identifier:(int64_t)identifier name:(NSString *)name {
    //@weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //@strongify(self)

        YXStockFilterSaveResultRequestModel *requestModel = [[YXStockFilterSaveResultRequestModel alloc] init];
        requestModel.market = market;
        requestModel.optType = type;
        requestModel.name = name;
        requestModel.id = identifier;
        YXProgressHUD *hud = [YXProgressHUD showLoading:@""];  //转圈
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {

            [hud hideHud];
            if (responseModel.code == YXResponseCodeSuccess) {

                [subscriber sendNext:@(1)];
            } else {
                [subscriber sendNext:@(-1)];
            }
            [subscriber sendCompleted];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:@(-1)];
            [subscriber sendError:request.error];
        }];
        return nil;
    }];
}

@end
