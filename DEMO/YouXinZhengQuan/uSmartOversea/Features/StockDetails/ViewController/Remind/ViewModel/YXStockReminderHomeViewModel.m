//
//  YXStockReminderHomeViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockReminderHomeViewModel.h"
#import "YXStockDetailMyRemindersViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXReminderModel.h"
#import "YXStockDetailReminderSettingViewModel.h"

@implementation YXStockReminderHomeViewModel

- (void)initialize {
    [super initialize];
    //market
    self.market = self.params[@"market"];
    self.symbol = self.params[@"code"];
    
    self.shouldPullToRefresh = YES;
    
    @weakify(self);
    //跳转到"我的提醒"
    self.pushToMyRemindsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        YXStockDetailMyRemindersViewModel *remindersVM = [[YXStockDetailMyRemindersViewModel alloc] initWithServices:self.services params:self.params];
        [self.services pushViewModel:remindersVM animated:YES];
        
        return [RACSignal empty];
    }];
    
    self.deleteCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXReminderModel *model) {
        @strongify(self);

        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            YXRemindSettingDeleteRuleRequestModel *requestModel = [[YXRemindSettingDeleteRuleRequestModel alloc] init];
            requestModel.stockCode = self.symbol;
            requestModel.stockMarket = self.market;
            if (model.ntfType > 0) {
                requestModel.delStockNtfs = @[model.id?:@""];
            } else {
                requestModel.delStockForms = @[model.id?:@""];
            }
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            YXProgressHUD *hud = [YXProgressHUD showLoading:@""];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                [hud hideHud];
                if (responseModel.code == YXResponseCodeSuccess) {
                    [self.requestRemoteDataCommand execute:@(1)];
                    [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"mine_del_success"]];
                } else {
                    [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"delete_fail"]];
                }
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [subscriber sendCompleted];
                [hud hideHud];
                [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"common_net_error"]];
            }];
            
            return nil;
        }];
    }];
    
    
    self.updateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXReminderModel *model) {
        @strongify(self);

        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            YXRequest *request;
            
            if (model.ntfType > 0) {
                YXRemindSettingUpdatePriceRequestModel *requestModel = [[YXRemindSettingUpdatePriceRequestModel alloc] init];
                requestModel.stockCode = self.symbol;
                requestModel.stockMarket = self.market;
                requestModel.id = model.id;
                requestModel.ntfType = model.ntfType;
                requestModel.ntfValue = model.ntfValue.doubleValue;
                requestModel.notifyType = model.notifyType;
                requestModel.status = model.status == 1 ? 2 : 1;
                request = [[YXRequest alloc] initWithRequestModel:requestModel];
            } else {
                YXRemindSettingUpdateFormRequestModel *requestModel = [[YXRemindSettingUpdateFormRequestModel alloc] init];
                requestModel.stockCode = self.symbol;
                requestModel.stockMarket = self.market;
                requestModel.id = model.id;
                requestModel.formShowType = model.formShowType;
                requestModel.notifyType = model.notifyType;
                requestModel.status = model.status == 1 ? 2 : 1;
                request = [[YXRequest alloc] initWithRequestModel:requestModel];
            }
            
            YXProgressHUD *hud = [YXProgressHUD showLoading:@""];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                [hud hideHud];
                if (responseModel.code == YXResponseCodeSuccess) {
                    if (model.status == 1) {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"turn_off_remind_success"]];
                    } else {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"turn_on_remind_success"]];
                    }
                    model.status = model.status == 1 ? 2 : 1;
                    // 刷新
                    self.dataSource = self.dataSource;
                } else {
                    [YXProgressHUD showError:responseModel.msg];
                }
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [subscriber sendCompleted];
                [hud hideHud];
                [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"common_net_error"]];
            }];
            
            return nil;
        }];
    }];
    
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        
        NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:self.params];
        if (self.formArr) {
            para[@"formArr"] = self.formArr;
        }
        YXReminderModel *model = self.dataSource[indexPath.section].firstObject;
        YXStockDetailReminderSettingViewModel *viewModel = [[YXStockDetailReminderSettingViewModel alloc] initWithServices:self.services params:para];
        viewModel.reminderModel = model;
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
}

- (RACSignal *)requestWithOffset:(NSInteger)offset {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {


        YXRemindSettingRequestModel *requestModel = [[YXRemindSettingRequestModel alloc] init];
        requestModel.stockMarket = self.market;
        requestModel.stockCode = self.symbol;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseCodeSuccess) {
                YXReminderListModel *model = [YXReminderListModel yy_modelWithDictionary:responseModel.data];
                NSMutableArray *arrM = [NSMutableArray array];                
                for (id obj in model.stockNtfs) {
                    [arrM addObject:@[obj]];
                }
                for (id obj in model.stockForms) {
                    [arrM addObject:@[obj]];
                }
                self.formArr = model.stockForms;
                self.dataSource = arrM;
            } else {
                self.dataSource = nil;
            }
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

@end
