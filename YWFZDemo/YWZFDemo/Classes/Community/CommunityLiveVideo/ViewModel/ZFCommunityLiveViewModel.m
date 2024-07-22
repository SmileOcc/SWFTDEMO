//
//  ZFCommunityLiveViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveViewModel.h"
#import "ZFCommunityLiveListApi.h"
#import "ZFCommunityLiveDetailApi.h"
#import "ZFCommunityLivePlayStatisticsApi.h"
#import "ZFLiveRemindApi.h"
#import "ZFLiveRemindStateApi.h"

#import "ZFCommunityZegoLiveLikeApi.h"
#import "ZFCommunityZegoLiveCommentApi.h"
#import "ZFCommunityZegoLiveHistoryCommentApi.h"


#import "Constants.h"
#import "YWCFunctionTool.h"

#import "ZFCommunityLiveDataModel.h"
#import "ZFRequestModel.h"
#import "ZFLocalizationString.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"

@interface ZFCommunityLiveViewModel ()

@property (nonatomic, assign) NSInteger                         curPage;
@property (nonatomic, strong) ZFCommunityLiveDataModel          *liveDataModel;


@end


@implementation ZFCommunityLiveViewModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"live_list"             : [ZFCommunityLiveListModel class],
             @"end_live_list"             : [ZFCommunityLiveListModel class]
             };
}


- (NSMutableArray<ZFCommunityLiveListModel *> *)live_list {
    if (!_live_list) {
        _live_list = [[NSMutableArray alloc] init];
    }
    return _live_list;
}

- (NSMutableArray<ZFCommunityLiveListModel *> *)end_live_list {
    if (!_end_live_list) {
        _end_live_list = [[NSMutableArray alloc] init];
    }
    return _end_live_list;
}

- (void)requestCommunityLiveListisFirstPage:(BOOL)isFirstPage
                                 completion:(void (^)(NSDictionary *pageInfo))completion {
    
    if (isFirstPage) {
        self.curPage = 1;
    }else{
        self.curPage += 1;
    }
    ZFCommunityLiveListApi *api = [[ZFCommunityLiveListApi alloc] initWithcurPage:self.curPage pageSize:20];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 200) {
            self.liveDataModel = [ZFCommunityLiveDataModel yy_modelWithJSON:dict[@"data"]];

            //111,222,333,444
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            [self.liveDataModel.live_list enumerateObjectsUsingBlock:^(ZFCommunityLiveListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj calculateCommonFlowCellSize];
            
                NSString *like = ZFToString(obj.view_num);
                obj.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[like integerValue]]];
            }];
            
            [self.liveDataModel.end_live_list enumerateObjectsUsingBlock:^(ZFCommunityLiveListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj calculateCommonFlowCellSize];
                NSString *like = ZFToString(obj.view_num);
                obj.format_view_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[like integerValue]]];
            }];
            
            if (isFirstPage) {
                [self.live_list removeAllObjects];
                [self.end_live_list removeAllObjects];
                // 只要第一页才加载这个数据
                [self.live_list addObjectsFromArray:self.liveDataModel.live_list];
            }
            [self.end_live_list addObjectsFromArray:self.liveDataModel.end_live_list];
        }
        
        if (completion) {
            NSInteger totalPage = self.liveDataModel.end_live_list.count >= 20 ? (self.curPage + 1) : self.curPage;
            NSDictionary *pageInfo = @{kTotalPageKey  : @(totalPage),
                                       kCurrentPageKey: @(self.curPage) };
            completion(pageInfo);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        --self.curPage;
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)requestCommunityLiveDetailLiveID:(NSString *)liveID
                              completion:(void (^)(ZFCommunityLiveListModel *liveModel))completion {
    
    ZFCommunityLiveDetailApi *api = [[ZFCommunityLiveDetailApi alloc] initWithLiveID:ZFToString(liveID)];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        ZFCommunityLiveListModel *liveModel;
        if ([dict[@"code"] integerValue] == 200) {
            liveModel = [ZFCommunityLiveListModel yy_modelWithJSON:dict[@"data"]];
        }
        
        if (completion) {
            completion(liveModel);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)requestCommunityLiveDetailLiveGoods:(NSString *)url completion:(void (^)(ZFCommunityVideoLiveGoodsModel *liveGoodsModel))completion {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.forbidEncrypt = YES;
    requestModel.taget = self.controller;
    requestModel.type = ZFNetworkRequestTypeGET;
    requestModel.url = ZFToString(url);
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSDictionary *dataDic = responseObject[ZFDataKey];
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dataDic = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        ZFCommunityVideoLiveGoodsModel *goodsModel = [ZFCommunityVideoLiveGoodsModel yy_modelWithJSON:dataDic];
        goodsModel.timerInterval = [responseObject[@"interval"] doubleValue];
        goodsModel.time = [NSString stringWithFormat:@"%@",responseObject[@"time"]];
        if (completion) {
            completion(goodsModel);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}


- (void)requestCommunityLivePlayStatisticsLiveID:(NSString *)liveID
                                      completion:(void (^)(NSString *status))completion {
    
    ZFCommunityLivePlayStatisticsApi *api = [[ZFCommunityLivePlayStatisticsApi alloc] initWithLiveID:ZFToString(liveID)];

    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSString *statusStr = @"0";
        if ([dict[@"code"] integerValue] == 200) {
            if (ZFJudgeNSDictionary(dict[@"data"])) {
                statusStr = dict[@"data"][@"status"];
            }
        }
        
        if (completion) {
            //1第一次播放 0之前播放过
            completion(ZFToString(statusStr));
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(@"0");
        }
    }];
}

- (void)requestCommunityLiveLikeLiveID:(NSString *)liveID
                              liveType:(NSString *)isLive
                              nickname:(NSString *)nickname
                                 phase:(NSString *)phase
                            completion:(void (^)(ZFCommunityLiveZegoLikeModel *likeModel))completion {
    
    ZFCommunityZegoLiveLikeApi *api = [[ZFCommunityZegoLiveLikeApi alloc] initWithLiveID:ZFToString(liveID) isLive:isLive nickname:ZFToString(nickname) phase:ZFToString(phase)];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        ZFCommunityLiveZegoLikeModel *liveLikeModel;
        if ([dict[@"code"] integerValue] == 200) {
            liveLikeModel = [ZFCommunityLiveZegoLikeModel yy_modelWithJSON:dict[@"data"]];
        }
        
        if (completion) {
            completion(liveLikeModel);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
    
}

- (void)requestCommunityLiveCommentLiveID:(NSString *)liveID
                                 liveType:(NSString *)isLive
                                  content:(NSString *)content
                                 nickname:(NSString *)nickname
                                    phase:(NSString *)phase
                               completion:(void (^)(BOOL success, NSString *msg))completion {
    
    ZFCommunityZegoLiveCommentApi *api = [[ZFCommunityZegoLiveCommentApi alloc] initWithLiveID:ZFToString(liveID) isLive:isLive content:ZFToString(content) nickname:ZFToString(nickname) phase:ZFToString(phase)];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if (completion) {// 去 statusCode
            completion([dict[@"code"] integerValue] == 200,ZFToString(dict[@"msg"]));
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(false,ZFLocalizedString(@"Global_NO_NET_404", nil));
        }
    }];
    
}
/**
 直播视频历史数据
 
 @param liveID
 @param completion
 */

- (void)requestCommunityLiveHistory:(NSDictionary *)parmaters
                         completion:(void (^)(ZFCommunityLiveZegoHistoryMessageModel *messagModels))completion {
    
    BOOL isFirstPage = [parmaters[@"firstpage"] boolValue];
    if (isFirstPage && self.historyCurPage <= 0) {
        self.historyCurPage = 1;
    }else{
        self.historyCurPage++;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @(9);
    info[@"directory"] = @(84);
    info[@"site"] = @"ZZZZZcommunity";
    info[@"loginUserId"] = USERID ?: @"0";
    info[@"id"] = ZFToString(parmaters[@"liveID"]);
    info[@"pageSize"] = @"20";
    info[@"page"] = @(self.historyCurPage);
    info[@"app_type"] = @"2";
    info[@"token"] = ZFToString(TOKEN);
    info[@"lang"] = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    info[@"device"] = ZFToString([AccountManager sharedManager].device_id);
    info[@"orderBy"] = @"desc";
    info[@"version"] = ZFToString(ZFSYSTEM_VERSION);

    
    ZFCommunityZegoLiveHistoryCommentApi *api = [[ZFCommunityZegoLiveHistoryCommentApi alloc] initWithLiveID:ZFToString(parmaters[@"liveID"]) page:info[@"page"] pageSize:@"20"];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
    
        NSDictionary *dict = request.responseJSONObject;
        //        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
        //            dict = ZF_COMMUNITY_RESPONSE_TEST();
        //        }
        
        ZFCommunityLiveZegoHistoryMessageModel *liveModel;
        if ([dict[@"code"] integerValue] == 200) {
            liveModel = [ZFCommunityLiveZegoHistoryMessageModel yy_modelWithJSON:dict[@"data"]];
            
            if (liveModel.list.count < 20) {
                self.historyCanNotRefresh = YES;
            }
        }
        
        if (!liveModel) {
            self.historyCurPage--;
        }
        
        if (completion) {
            if (completion) {
                completion(liveModel);
            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)requestLiveRemind:(NSDictionary *)parmaters completion:(void (^)(BOOL success, NSString *msg))completion {
    
    NSString *liveID = ZFToString(parmaters[@"liveID"]);
    ZFLiveRemindApi *api = [[ZFLiveRemindApi alloc] initWithLiveID:ZFToString(liveID)];

    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSDictionary *dict = request.responseJSONObject;
        //        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
        //            dict = ZF_COMMUNITY_RESPONSE_TEST();
        //        }
        NSString *msg = ZFToString(dict[@"msg"]);
        BOOL flag = NO;
        // 203 表示之前已提醒过
        if ([dict[@"code"] integerValue] == 200 || [dict[@"code"] integerValue] == 203) {
            flag = YES;
        }
        
        if (completion) {
            completion(flag,msg);
        }
        
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(NO,@"");
        }
    }];
        
}

- (void)requestLiveRemindState:(NSDictionary *)parmaters completion:(nonnull void (^)(BOOL, NSInteger, NSString * _Nonnull))completion {
    
    NSString *liveID = ZFToString(parmaters[@"liveID"]);
    ZFLiveRemindStateApi *api = [[ZFLiveRemindStateApi alloc] initWithLiveID:ZFToString(liveID)];

    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        NSDictionary *dict = request.responseJSONObject;
        //        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
        //            dict = ZF_COMMUNITY_RESPONSE_TEST();
        //        }
        NSString *msg = ZFToString(dict[@"msg"]);
        NSInteger status = 0;
        BOOL flag = NO;
        if ([dict[@"code"] integerValue] == 200) {
            if (ZFJudgeNSDictionary(dict[@"data"])) {
                status = [dict[@"data"][@"status"] integerValue];
            }
            flag = YES;
        }
        
        if (completion) {
            completion(flag,status,msg);
        }
        
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (completion) {
            completion(NO,0,@"");
        }
    }];
        
}
@end
