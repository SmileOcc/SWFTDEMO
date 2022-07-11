//
//  YXStockDetailMyRemindersViewModel.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXStockDetailMyRemindersViewModel.h"
#import "YXStockReminderHomeViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXReminderModel.h"
#import <QMUIKit/QMUIKit.h>
#import "YXAuthorityReminderTool.h"
#import "NSDictionary+Category.h"

@interface YXStockDetailMyRemindersViewModel ()<YXSocketReceiveDataProtocol>
@property (nonatomic, strong) YXQuoteRequest *delayRequest;
@property (nonatomic, strong) YXQuoteRequest *bmpRequest;
@property (nonatomic, strong) YXQuoteRequest *level1Request;
@property (nonatomic, strong) YXQuoteRequest *level2Request;
@property (nonatomic, strong) YXQuoteRequest *usnationRequest;

@end

@implementation YXStockDetailMyRemindersViewModel

- (void)initialize{
    [super initialize];

    self.market = self.params[@"market"];
    self.symbol = self.params[@"code"];
    self.marketSymbol = [NSString stringWithFormat:@"%@%@", self.market, self.symbol];
    
    //下拉刷新
    self.shouldPullToRefresh = YES;
    //上拉加载更多
    self.shouldInfiniteScrolling = NO;
    //加载数据
    @weakify(self);
    // 停止轮询
    [self.didDisappearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.delayRequest cancel];
        [self.bmpRequest cancel];
        [self.level1Request cancel];
        [self.level2Request cancel];
    }];
    
    //行情
    self.quotaSubject = [RACSubject subject];
    
    self.remindListSubject = [RACSubject subject];
    
    //编辑
    self.editRemindCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *param) {
        
        @strongify(self);
        NSString *market = [param yx_stringValueForKey:@"market"];
        NSString *code = [param yx_stringValueForKey:@"symbol"];
        NSString *name = [param yx_stringValueForKey:@"name"];
        if ([self.marketSymbol isEqualToString:[NSString stringWithFormat:@"%@%@", market, code]]) {
            [UIViewController.cyl_topmostViewController.navigationController popViewControllerAnimated:YES];
        } else {
            if (market.length > 0 && code.length > 0 && name.length > 0) {
                YXStockReminderHomeViewModel *reminderViewModel = [[YXStockReminderHomeViewModel alloc] initWithServices:self.services params:@{@"market" : market, @"code" : code, @"name" : name, @"fromReminderSetting" : @(YES)}];            
                [self.services pushViewModel:reminderViewModel animated:YES];
            }
        }

        return [RACSignal empty];
        
    }];
    
    //删除后的通知
    self.deleteRemindNotifySubject = [RACSubject subject];
    
    //删除
    self.deleteRemindCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *param) {
       
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            NSString *market = [param yx_stringValueForKey:@"market"];
            NSString *code = [param yx_stringValueForKey:@"symbol"];
            if (market.length > 0 && code.length > 0) {
                YXRemindSettingDeleteRuleRequestModel *deleteRequest = [[YXRemindSettingDeleteRuleRequestModel alloc] init];
                deleteRequest.stockCode = code;
                deleteRequest.stockMarket = market;
                YXRequest *request = [[YXRequest alloc] initWithRequestModel:deleteRequest];
                [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                    @strongify(self)
                    if (responseModel.code == YXResponseStatusCodeSuccess) {
                        //删除成功
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"mine_del_success"]];
                        //删除提醒
                        [self.deleteRemindNotifySubject sendNext:param];
                    } else {
                        [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"delete_fail"]];
                    }
                    [subscriber sendCompleted];
                } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                    [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"common_net_error"]];
                    [subscriber sendCompleted];
                }];
            }
            return nil;
        }];
    }];
}

- (RACSignal *)requestWithOffset:(NSInteger)offset{
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        YXRemindGetAllUserSettingRequestModel *remindDataRequest = [[YXRemindGetAllUserSettingRequestModel alloc] init];
        YXRequest *remindRequest = [[YXRequest alloc] initWithRequestModel:remindDataRequest];
        [remindRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            NSArray *remindList = [NSArray array];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                
                NSArray *sourceData = [responseModel.data yx_arrayValueForKey:@"stocklist"];
                NSArray *list = [NSArray yy_modelArrayWithClass:[YXReminderListModel class] json:sourceData];
                if (list == nil) {
                    self.dataSource = @[[NSArray array]];
                } else {
                    self.dataSource = @[list];
                }
                [subscriber sendCompleted];
                // 加载行情数据
                // 根据权限进行分组，并按权限进行请求或者订阅
                NSArray<YXAuthorityReminderToolGroupingDelegate> *arr = [list copy];
                [self getQuoteWihtArray:arr result:nil];
                NSLog(@"");
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            
            if (self.remindListSubject) {
                [self.remindListSubject sendNext:remindList];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    
    }];
    
}

- (void)getQuoteWihtArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array result:(GetHttpQuoteResultBlock)resultBlock {
    if (![array isKindOfClass:[NSArray class]] || array.count < 1) {
        if (resultBlock) resultBlock(@"0");
        return;
    }
    YXAuthorityReminderTool *authorityTool = [[YXAuthorityReminderTool alloc] init];
    NSDictionary *group = [authorityTool groupingWithArray:array];
    NSMutableArray *bmp = group[@"bmp"];
    NSMutableArray *delay = group[@"delay"];
    NSMutableArray *level1 = group[@"level1"];
    NSMutableArray *level2 = group[@"level2"];
    NSMutableArray *usnation = group[@"usnation"];
    
    [self.delayRequest cancel];
    [self.bmpRequest cancel];
    [self.level1Request cancel];
    [self.level2Request cancel];
    [self.usnationRequest cancel];

    [self getHttpQuoteArr:bmp andLevel:QuoteLevelBmp];
    [self getHttpQuoteArr:delay andLevel:QuoteLevelDelay];
    [self getHttpQuoteArr:level1 andLevel:QuoteLevelLevel1];
    [self getHttpQuoteArr:level2 andLevel:QuoteLevelLevel2];
    [self getHttpQuoteArr:usnation andLevel:QuoteLevelUsNational];
}


- (void)getHttpQuoteArr:(NSArray *)arr andLevel:(QuoteLevel)level {
    if (arr.count == 0) {
        return;
    }
    NSMutableArray *arrM = [NSMutableArray array];
    for (YXReminderListModel *model in arr) {
        Secu *secu = [[Secu alloc] initWithMarket:model.stockMarket symbol:model.stockCode];
        [arrM addObject:secu];
    }
    @weakify(self);
    YXQuoteRequest *request = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:arrM level:level handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
           @strongify(self);
           if (self.quotaSubject && list.count > 0) {
               [self.quotaSubject sendNext:list];
           }
       } failed:^{
               [self.quotaSubject sendNext:nil];
       }];
    
    if (level == QuoteLevelDelay) {
        self.delayRequest = request;
    } else if (level == QuoteLevelBmp) {
        self.bmpRequest = request;
    } else if (level == QuoteLevelLevel1) {
        self.level1Request = request;
    } else if (level == QuoteLevelUsNational) {
        self.usnationRequest = request;
    } else {
        self.level2Request = request;
    }
   
    
}


@end
