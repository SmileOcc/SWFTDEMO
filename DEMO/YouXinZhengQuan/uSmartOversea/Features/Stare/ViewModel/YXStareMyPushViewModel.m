//
//  YXStareMyPushViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareMyPushViewModel.h"
#import "YXStareSignalModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@implementation YXStareMyPushViewModel

- (void)initialize{
    
    NSArray *list = [self.params yx_arrayValueForKey:@"list"];
    self.list = list;
    if (list.count > 0) {
        
        // 解析数据
        NSData *data = [[MMKV defaultMMKV] getDataForKey:@"industryListPath"];
        NSDictionary *dic = [NSDictionary dictionary];
        if (data) {
            NSDictionary *totalDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
            if (YXUserManager.isENMode) {
                dic = totalDic[@"en"];
            } else if (YXUserManager.curLanguage == YXLanguageTypeCN) {
                dic = totalDic[@"cn"];
            } else {
                dic = totalDic[@"tc"];
            }
        }
        
        for (YXStarePushSettingModel *model in list) {
            if (model.list == nil) {
                model.list = [[NSArray alloc] init];
            }
            for (YXStarePushSettingSubModel *subModel in model.list) {
                subModel.type = model.type;
            }
        }
                
        // 第一组
        NSMutableArray *arr1 = [NSMutableArray array];
        YXStarePushSettingSubModel *myModel = [[YXStarePushSettingSubModel alloc] init];
        myModel.type = 0;
        myModel.isShow = YES;
        YXStarePushSettingSubModel *holdModel = [[YXStarePushSettingSubModel alloc] init];
        holdModel.type = 5;
        holdModel.isShow = YES;
        [arr1 addObject:myModel];
        [arr1 addObject:holdModel];
        
        // 第二组
        NSMutableArray *arr2 = [NSMutableArray array];
        
        // 第三组
        NSMutableArray *arr3 = [NSMutableArray array];
                
        for (YXStarePushSettingModel *model in list) {
            model.list.lastObject.isShow = YES;
            if (model.type == 5) {
                YXStarePushSettingSubModel *subModel = model.list.lastObject;
                holdModel.status = subModel.status;
            }
            
            if (model.type == 0) {
                YXStarePushSettingSubModel *subModel = model.list.lastObject;
                myModel.status = subModel.status;
            }
            
            if (model.type == 1) {
                // 行业
                if (model.list.count > 0) {
                    [arr2 addObjectsFromArray:model.list];
                    
                    // 行业名字
                    NSString *market = @"";
                    NSString *marketName = @"";
                    for (YXStarePushSettingSubModel *subModel in model.list) {
                        if ([subModel.identifier hasPrefix:@"hk"]) {
                            market = @"hk";
                            marketName = [YXLanguageUtility kLangWithKey:@"community_hk_stock"];
                        } else if ([subModel.identifier hasPrefix:@"us"]) {
                            market = @"us";
                            marketName = [YXLanguageUtility kLangWithKey:@"community_us_stock"];
                        } else {
                            market = @"a";
                            marketName = [YXLanguageUtility kLangWithKey:@"community_cn_stock"];
                        }
                        NSDictionary *aDic = [dic yx_dictionaryValueForKey:market];
                        NSDictionary *map = [aDic yx_dictionaryValueForKey:@"map"];
                        [map enumerateKeysAndObjectsUsingBlock:^(NSString   * _Nonnull key, NSArray   * _Nonnull obj, BOOL * _Nonnull stop) {
                            for (NSDictionary *industryDic in obj) {
                                if ([[industryDic yx_stringValueForKey:@"industry_code_yx"] isEqualToString:subModel.identifier]) {
                                    subModel.name = [NSString stringWithFormat:@"%@-%@", marketName, [industryDic yx_stringValueForKey:@"industry_name"]];
                                    *stop = YES;
                                }
                            }
                        }];
                    }
                }
            }
            if (model.type == 3) {
                // 新股
                if (model.list.count > 0) {
                    [arr3 addObjectsFromArray:model.list];
                    
                    //                     
                    for (YXStarePushSettingSubModel *subModel in model.list) {
                        if ([subModel.identifier hasPrefix:@"hk"]) {
                            subModel.name = [YXLanguageUtility kLangWithKey:@"community_hk_stock"];
                        } else if ([subModel.identifier hasPrefix:@"us"]) {
                            subModel.name = [YXLanguageUtility kLangWithKey:@"community_us_stock"];
                        } else {
                            subModel.name = [YXLanguageUtility kLangWithKey:@"community_cn_stock"];
                        }
                    }
                }
            }
        }
        
        NSMutableArray *dataSource = [NSMutableArray array];
        [dataSource addObject:arr1];
        if (arr2.count > 0) {
            [dataSource addObject:arr2];
        }
        if (arr3.count > 0) {
            [dataSource addObject:arr3];
        }
        
        self.dataSource = dataSource;
    }
    
    @weakify(self);
    self.updatePushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self updatePushSettingWithPara: para];
    }];
}

- (RACSignal *)updatePushSettingWithPara:(NSDictionary *)para {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXStareUpdatePsuhSettinglistRequestModel *requestModel = [[YXStareUpdatePsuhSettinglistRequestModel alloc] init];
        
        NSInteger type = [para yx_intValueForKey:@"type"];
        NSArray *list = [para yx_arrayValueForKey:@"list"];
        
        requestModel.type = type;
        requestModel.list = list?:@[];
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                //                NSDictionary *dataDic = responseModel.data;
                
                [subscriber sendNext:@(YES)];
                [subscriber sendCompleted];
                
            } else if (responseModel.code == 808018) {
                [QMUITips showInfo:[YXLanguageUtility kLangWithKey:@"monitor_push_industry_limit"]];
                [subscriber sendNext:nil];
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


@end
