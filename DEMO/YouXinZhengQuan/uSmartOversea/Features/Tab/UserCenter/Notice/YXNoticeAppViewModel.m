//
//  YXNoticeAppViewModel.m
//  YouXinZhengQuan
//
//  Created by suntao on 2021/1/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNoticeAppViewModel.h"
#import "YXNoticeSettingModel.h"
#import "uSmartOversea-Swift.h"
#import "YXStareSignalModel.h"
#import "NSDictionary+Category.h"

@interface YXNoticeAppViewModel ()

@property (nonatomic, strong) YXRequest *updateRequest;

@end

@implementation YXNoticeAppViewModel

-(void)initialize
{
    self.getSettingSubject = [[RACSubject alloc] init];
    self.newsTypeValue = -1;
    
    @weakify(self)
    self.updateSettingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXNoticeSettingModel *  _Nullable settingModel) {
        @strongify(self)
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            if (self.updateRequest) {
                [self.updateRequest stop];
            }
            YXNoticeSettingAPPRequestModel *requestModel = [[YXNoticeSettingAPPRequestModel alloc] init];
            requestModel.switchId = settingModel.httpDataKey;
            if ([settingModel.httpDataKey isEqualToString:@"news" ]){ //资讯提醒
                if (settingModel.isSubCell) {
                    requestModel.flag = settingModel.newsType;
                }else{
                    requestModel.flag = settingModel.isOn ? YXNewsNoticeTypeOff : YXNewsNoticeTypeAll ;
                }
               
            }else{
                requestModel.flag = settingModel.isOn ? 1 : 0 ;
            }
            
            
            self.updateRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
            YXProgressHUD *hud = [YXProgressHUD showLoading: @""];
            [self.updateRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                [hud hideAnimated:YES];
                if (responseModel.code == YXResponseCodeSuccess) {
                    
                    if([settingModel.httpDataKey isEqualToString:@"quote_smart"]){
                        BOOL resultOn = settingModel.isOn;
                        settingModel.isOn = !resultOn;
                        [self.smLoadPushSettingListRequestCommand execute: nil]; //去刷新盯盘精灵的内容
                    }
                    [subscriber sendNext:@(YES)];
                    
                   
                } else {
                    [YXProgressHUD showError:responseModel.msg];
                    [subscriber sendNext:@(NO)];
                }
                [subscriber sendCompleted];
                
                [self loadServiceData];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [hud hideAnimated:YES];
                [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"nfc_connect_error_tip"]];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                [self loadServiceData];
            }];
            return nil;
        }];
    }];
    [self resetData];
    
    
    self.smLoadPushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadSMPushSettingData];
    }];
    
    self.smUpdatePushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self updateSMPushSettingWithPara: para];
    }];
    
}

//默认数据
- (void)resetData
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
       
        BOOL isOpen = NO;
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            isOpen = YES;
        }
        [self loadDataFromPushOpen:isOpen];
    }];
}

-(void)loadDataFromPushOpen:(BOOL) isopen
{
    YXNoticeGroupSettingModel *pushOpenGroup = [[YXNoticeGroupSettingModel alloc] init];
    pushOpenGroup.gruopId = @"push_all_smart";
    pushOpenGroup.title = @"";
    YXNoticeSettingModel *pushmodel= [[YXNoticeSettingModel alloc] init];
    pushmodel.title = [YXLanguageUtility kLangWithKey:@"mine_message_switch"];
    pushmodel.settingId = @"push_all_smart";
    pushmodel.isSwitch = NO;
    pushmodel.isArrow = isopen ?  NO: YES;
    pushmodel.rightButonTitle = isopen ? [YXLanguageUtility kLangWithKey:@"mine_opened"]:[YXLanguageUtility kLangWithKey:@"mine_go_open"];
    pushmodel.isOn = isopen;
//    pushmodel.showBold = YES;
    pushmodel.isShowLine = NO;
    pushOpenGroup.settings = @[pushmodel];
    
    if (isopen == NO) {
        NSArray * settings = @[pushOpenGroup];
        self.settingList = [NSMutableArray arrayWithArray:settings];
        [self.getSettingSubject sendNext:nil];
        return;
    }
    
//    YXNoticeGroupSettingModel *group1 = [[YXNoticeGroupSettingModel alloc] init];
//    group1.gruopId = @"app";
//    group1.title = [YXLanguageUtility kLangWithKey:@"push_set_smartTip"];
//    YXNoticeSettingModel *model1_1= [[YXNoticeSettingModel alloc] init];
//    model1_1.title = [YXLanguageUtility kLangWithKey:@"push_set_smartStrategy"];
//    model1_1.httpDataKey = @"smart_policy";
//    model1_1.isSwitch = YES;
//    model1_1.showBold = YES;
//    model1_1.isShowLine = YES;
//
//    YXNoticeSettingModel *model1_2= [[YXNoticeSettingModel alloc] init];
//    model1_2.title = [YXLanguageUtility kLangWithKey:@"trend_signal"];
//    model1_2.httpDataKey = @"smart_channel";
//    model1_2.isSwitch = YES;
//    model1_2.showBold = YES;
//    model1_2.isShowLine = YES;
//
//    YXNoticeSettingModel *model1_3= [[YXNoticeSettingModel alloc] init];
//    model1_3.title = [YXLanguageUtility kLangWithKey:@"today_hot_stock"];
//    model1_3.httpDataKey = @"hot_stock";
//    model1_3.isSwitch = YES;
//    model1_3.showBold = YES;
//    model1_3.isShowLine = YES;
//
//    group1.settings = @[model1_1,model1_2, model1_3];
    
//    YXNoticeGroupSettingModel *group2 = [[YXNoticeGroupSettingModel alloc] init];
//    group2.gruopId = @"app";
//    group2.title = [YXLanguageUtility kLangWithKey:@"push_set_remind"];
//    YXNoticeSettingModel *model2_1= [[YXNoticeSettingModel alloc] init];
//    model2_1.title = [YXLanguageUtility kLangWithKey:@"push_set_dipan"];
//    model2_1.isSwitch = YES;
//    model2_1.showBold = YES;
//    model2_1.isShowLine = YES;
//    model2_1.httpDataKey = @"quote_smart";
//    group2.settings = @[model2_1];
    
    YXNoticeGroupSettingModel *group3 = [[YXNoticeGroupSettingModel alloc] init];
    group3.gruopId = @"app";    
    group3.title = [YXLanguageUtility kLangWithKey:@"push_set_remind"];
    YXNoticeSettingModel *model3_1 = [[YXNoticeSettingModel alloc] init];
    model3_1.title = [YXLanguageUtility kLangWithKey:@"remind_price_title"];
    model3_1.httpDataKey = @"quote_stock";
//    model3_1.showBold = YES;
    model3_1.isSwitch = YES;
    model3_1.isShowLine = NO;
    group3.settings = @[model3_1];
//
//    YXNoticeGroupSettingModel *group4 = [[YXNoticeGroupSettingModel alloc] init];
//    group4.gruopId = @"app";
//    group4.title = [YXLanguageUtility kLangWithKey:@"push_set_other"];
//    YXNoticeSettingModel *model4_1= [[YXNoticeSettingModel alloc] init];
//    model4_1.title = [YXLanguageUtility kLangWithKey:@"push_set_newsRemind"];
//    model4_1.httpDataKey = @"news";
//    model4_1.showBold = YES;
//    model4_1.isSwitch = YES;
//    model4_1.isShowLine = YES;
//    group4.settings = @[model4_1];
//
//    YXNoticeGroupSettingModel *group5 = [[YXNoticeGroupSettingModel alloc] init];
//    group5.gruopId = @"app";
//    group5.title = @"";
//    YXNoticeSettingModel *model5_1 = [[YXNoticeSettingModel alloc] init];
//    model5_1.title = [YXLanguageUtility kLangWithKey:@"push_set_live"];
//    model5_1.httpDataKey = @"live";
//    model5_1.isSwitch = YES;
//    model5_1.showBold = YES;
//    model5_1.isShowLine = YES;
//    group5.settings = @[model5_1];
    
//    NSArray * settings = @[pushOpenGroup ,group1, group2, group3, group4,group5];
    NSArray * settings = @[pushOpenGroup, group3];
    self.settingList = [NSMutableArray arrayWithArray:settings];
    [self loadServiceData];
}


//获取app推送的状态值
-(void) loadServiceData {
    YXNoticeSettingNewRequestModel *requestModel = [[YXNoticeSettingNewRequestModel alloc] init];
    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
    @weakify(self)
    [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
        @strongify(self)
        if (responseModel.code == YXResponseCodeSuccess) {
            NSDictionary * dataDict = responseModel.data;
            [self combineModelWithData:dataDict];
        }
        [self.getSettingSubject sendNext:nil];
    }failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"nfc_connect_error_tip"]];
        [self.getSettingSubject sendNext:nil];
    }];
}

//置上状态
-(void) combineModelWithData: (NSDictionary *) dataDic
{
    if (dataDic) {
        for (YXNoticeGroupSettingModel * group in self.settingList ) {
            for (YXNoticeSettingModel * setModel in group.settings) {
                if ([setModel.httpDataKey isEqualToString:@"news"]) { //资讯时
                    YXNewsNoticeType newsType = (YXNewsNoticeType)[dataDic yx_intValueForKey:@"news"];
                    self.newsTypeValue = newsType;
                    
                    setModel.isOn = (newsType == YXNewsNoticeTypeOff) ? NO : YES ;
                    if (setModel.isOn) {
                        YXNoticeSettingModel *model4_1= [[YXNoticeSettingModel alloc] init];
                        model4_1.title = [YXLanguageUtility kLangWithKey:@"push_set_newsRemind"];
                        model4_1.httpDataKey = @"news";
                        model4_1.showBold = YES;
                        model4_1.isSwitch = YES;
                        model4_1.isShowLine = YES;
                        model4_1.isOn = setModel.isOn;
                        
                        YXNoticeSettingModel *model4_2= [[YXNoticeSettingModel alloc] init];
                        model4_2.title = @"";
                        model4_2.minTitle = @"";
                        model4_2.httpDataKey = @"news";
                        model4_2.showBold = NO;
                        model4_2.isSubCell = YES;
                        model4_2.isShowLine = NO;
                        model4_2.newsType = newsType;
                        
                        group.settings = @[model4_1, model4_2];
                        
                    }else{
                        YXNoticeSettingModel *model4_1= [[YXNoticeSettingModel alloc] init];
                        model4_1.title = [YXLanguageUtility kLangWithKey:@"push_set_newsRemind"];
                        model4_1.httpDataKey = @"news";
                        model4_1.showBold = YES;
                        model4_1.isSwitch = YES;
                        group.settings = @[model4_1];
                    }
                }else if([setModel.settingId isEqualToString:@"smQuote"]){ //盯盘里的项目由盯盘的接口来置状态
                    
                }else if([setModel.settingId isEqualToString:@"push_all_smart"]){
                    //系统的不用置
                } else{
                    setModel.isOn = ![dataDic yx_boolValueForKey:setModel.httpDataKey];
                }
            }
        }
    }
}


#pragma mark - 盯盘精灵

//加载数据
- (RACSignal *)loadSMPushSettingData{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
//        YXStarePsuhSettinglistRequestModel *requestModel = [[YXStarePsuhSettinglistRequestModel alloc] init];
//
//        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
//
//        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//            if (responseModel.code == YXResponseStatusCodeSuccess){
//                NSDictionary *dataDic = responseModel.data;
//                NSArray *modelList = [dataDic yx_arrayValueForKey:@"list"];
//                NSArray * smLists = [NSArray yy_modelArrayWithClass:[YXStarePushSettingModel class] json:modelList];
//
//                //组合数据
//                [self combineSmartQuoteData:smLists];
//
//                [subscriber sendNext:nil];
//                [subscriber sendCompleted];
//
//
//            }else{
//                [subscriber sendNext:nil];
//                [subscriber sendCompleted];
//            }
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//
//        }];
        
        return nil;
    }];
    
}

//设置盯盘精灵子项用的
- (RACSignal *)updateSMPushSettingWithPara:(NSDictionary *)para {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXStareUpdatePsuhSettinglistRequestModel *requestModel = [[YXStareUpdatePsuhSettinglistRequestModel alloc] init];
        
        NSInteger type = [para yx_intValueForKey:@"type"];
        NSArray *list = [para yx_arrayValueForKey:@"list"];
        
        requestModel.type = type;
        requestModel.list = list?:@[];
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        YXProgressHUD *hud = [YXProgressHUD showLoading: @""];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [hud hideAnimated:YES];
            if (responseModel.code == YXResponseStatusCodeSuccess){
                //                NSDictionary *dataDic = responseModel.data;
                
                [subscriber sendNext:@(YES)];
                [subscriber sendCompleted];
                
            } else if (responseModel.code == 808018) {
                [QMUITips showInfo:[YXLanguageUtility kLangWithKey:@"monitor_push_industry_limit"]];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:@(2)];
                [subscriber sendCompleted];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [hud hideAnimated:YES];
            [subscriber sendNext:@(2)];
            [subscriber sendCompleted];
            
        }];
        
        return nil;
    }];
    
}

-(void)combineSmartQuoteData:(NSArray *) list
{
    if (list.count > 0) {
        
        // 解析数据
        NSData *data = [[MMKV defaultMMKV] getDataForKey:@"industryListPath"];
        NSDictionary *dic = [NSDictionary dictionary];
        if (data) {
            dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
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
        myModel.name = [YXLanguageUtility kLangWithKey:@"news_watchlist"];
        YXStarePushSettingSubModel *holdModel = [[YXStarePushSettingSubModel alloc] init];
        holdModel.type = 5;
        holdModel.isShow = YES;
        holdModel.name = [YXLanguageUtility kLangWithKey:@"trading_hold_warehouse"];
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
                    for (YXStarePushSettingSubModel *subModel in model.list) {
                        if ([subModel.identifier hasPrefix:@"hk"]) {
                            subModel.name =  [YXLanguageUtility kLangWithKey:@"community_hk_stock"];
                        } else if ([subModel.identifier hasPrefix:@"us"]) {
                            subModel.name = [YXLanguageUtility kLangWithKey:@"community_us_stock"];
                        } else {
                            subModel.name = [YXLanguageUtility kLangWithKey:@"community_cn_stock"];
                        }
                    }
                }
            }
        }
        
        //转换模型
        NSMutableArray * dataSource = [NSMutableArray array];
        NSMutableArray * smGroupList = [NSMutableArray array];
        [dataSource addObjectsFromArray:arr1];
        if (arr2.count > 0) {
            [dataSource addObjectsFromArray:arr2];
        }
        if (arr3.count > 0) {
            [dataSource addObjectsFromArray:arr3];
        }
        if (dataSource.count > 0 ) {
            for (int i = 0; i<dataSource.count; i++) {
                YXStarePushSettingSubModel * smModel = dataSource[i];
                
                YXNoticeSettingModel *model= [[YXNoticeSettingModel alloc] init];
                model.identifier = smModel.identifier;
                model.isOn = smModel.status;
                model.title = smModel.name;
                model.smType = smModel.type;
                model.settingId = @"smQuote"; //盯盘精灵子项临时 区分
                model.showBold = NO;
                model.isSubCell = YES;
                model.isSwitch = YES;
                model.isShowLine = (i == dataSource.count-1) ? YES : NO;
                [smGroupList addObject:model];
            }
        }
        @synchronized (self) {
            [self insertSMModelToSettingModel:smGroupList];
        }
    }
}

-(void) insertSMModelToSettingModel:(NSArray *) smList
{
    NSMutableArray * smQuoteMutArray = [NSMutableArray array];
    for (YXNoticeGroupSettingModel * group in self.settingList ) {
        for (YXNoticeSettingModel * setModel in group.settings) {
            if ([setModel.httpDataKey isEqualToString:@"quote_smart"]) { //盯盘精灵
                if(setModel.isOn == YES){
                    if (smList.count > 0) {
                        [smQuoteMutArray addObjectsFromArray:smList];
                        [smQuoteMutArray insertObject:setModel atIndex:0];
                    }else{
                        [smQuoteMutArray addObject:setModel];
                    }
                }else{
                    [smQuoteMutArray addObject:setModel];
                }
                group.settings = [smQuoteMutArray copy];
            }
        }
    }
    [self.getSettingSubject sendNext:nil];
}


#pragma mark - Getter

-(NSMutableArray<YXNoticeGroupSettingModel *> *)settingList
{
    if (!_settingList) {
        _settingList = [NSMutableArray array];
    }
    return _settingList;
}

@end
