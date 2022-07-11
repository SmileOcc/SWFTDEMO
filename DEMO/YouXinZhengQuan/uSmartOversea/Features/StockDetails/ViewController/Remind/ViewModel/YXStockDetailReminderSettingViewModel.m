//
//  YXStockDetailReminderSettingViewModel.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/20.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXStockDetailReminderSettingViewModel.h"
#import "YXStockDetailMyRemindersViewModel.h"
#import "uSmartOversea-Swift.h"
#import <QMUIKit/QMUIKit.h>
#import "YXRemindTool.h"
#import "NSDictionary+Category.h"

@implementation YXStockDetailReminderSettingViewModel

- (void)initialize {
    
    //market
    self.market = self.params[@"market"];
    self.symbol = self.params[@"code"];
    self.formArr = [self.params yx_arrayValueForKey:@"formArr"];
    
    self.reminderModel = [[YXReminderModel alloc] init];
    self.reminderModel.notifyType = 1;
    self.reminderModel.status = 1;

//    self.fromReminderSetting = [self.params[@"fromReminderSetting"] boolValue];
    
    @weakify(self);
    //跳转到"我的提醒"
    self.pushToMyRemindsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        [self.services popViewModelAnimated:true];
        return [RACSignal empty];
    }];
    
    //保存提醒设置
    self.remindSettingSaveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        return [self saveRemindSetting];
    }];
    
}

//保存提醒数据
- (RACSignal *)saveRemindSetting {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXRequest *request;
        YXReminderType type;
        if (self.reminderModel.ntfType > 0) {
            type = self.reminderModel.ntfType;
        } else {
            type = self.reminderModel.formShowType;
        }
        
        if (self.reminderModel.id.length > 0) {
            // 编辑
            if ([YXRemindTool isFormWithType:type]) {
                YXRemindSettingUpdateFormRequestModel *saveDataRequest = [[YXRemindSettingUpdateFormRequestModel alloc] init];
                saveDataRequest.id = self.reminderModel.id;
                saveDataRequest.stockCode = self.symbol;
                saveDataRequest.stockMarket = self.market;
                saveDataRequest.formShowType = self.reminderModel.formShowType;
                saveDataRequest.notifyType = self.reminderModel.notifyType;
                saveDataRequest.status = self.reminderModel.status;
                request = [[YXRequest alloc] initWithRequestModel:saveDataRequest];
            } else {
                YXRemindSettingUpdatePriceRequestModel *saveDataRequest = [[YXRemindSettingUpdatePriceRequestModel alloc] init];
                saveDataRequest.id = self.reminderModel.id;
                saveDataRequest.stockCode = self.symbol;
                saveDataRequest.stockMarket = self.market;
                saveDataRequest.ntfType = self.reminderModel.ntfType;
                saveDataRequest.notifyType = self.reminderModel.notifyType;
                saveDataRequest.status = self.reminderModel.status;
                saveDataRequest.ntfValue = self.reminderModel.ntfValue.doubleValue;
                request = [[YXRequest alloc] initWithRequestModel:saveDataRequest];
            }

        } else {
            // 新增
            if ([YXRemindTool isFormWithType:type]) {
                YXRemindSettingAddFormRequestModel *saveDataRequest = [[YXRemindSettingAddFormRequestModel alloc] init];
                saveDataRequest.stockCode = self.symbol;
                saveDataRequest.stockMarket = self.market;
                saveDataRequest.formShowType = self.reminderModel.formShowType;
                saveDataRequest.notifyType = self.reminderModel.notifyType;
                saveDataRequest.status = self.reminderModel.status;
                request = [[YXRequest alloc] initWithRequestModel:saveDataRequest];
            } else {
                YXRemindSettingAddPriceRequestModel *saveDataRequest = [[YXRemindSettingAddPriceRequestModel alloc] init];
                saveDataRequest.stockCode = self.symbol;
                saveDataRequest.stockMarket = self.market;
                saveDataRequest.ntfType = self.reminderModel.ntfType;
                saveDataRequest.notifyType = self.reminderModel.notifyType;
                saveDataRequest.status = self.reminderModel.status;
                saveDataRequest.ntfValue = self.reminderModel.ntfValue.doubleValue;
                request = [[YXRequest alloc] initWithRequestModel:saveDataRequest];
            }
        }
        
        YXProgressHUD *hud = [YXProgressHUD showLoading:@""];
        
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [hud hideHud];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                //保存成功                
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"user_saveSucceed"]];
                [UIViewController.cyl_topmostViewController.navigationController popViewControllerAnimated:YES];
            } else {
                [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"user_saveFailed"]];
            }
            [subscriber sendCompleted];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [hud hideHud];
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"common_net_error"]];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}
@end
