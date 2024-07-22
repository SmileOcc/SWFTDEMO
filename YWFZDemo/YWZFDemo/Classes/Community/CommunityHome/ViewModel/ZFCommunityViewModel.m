
//
//  ZFCommunityViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityViewModel.h"
#import "ZFCommunityMessageCountApi.h"
#import "YWCFunctionTool.h"
#import "ZFApiDefiner.h"
#import "ZFRequestModel.h"
#import "YWLocalHostManager.h"

@implementation ZFCommunityViewModel

+ (void)requestMessageCountNetwork:(id)parmaters
                        completion:(void (^)(NSInteger msgCount))completion
                           failure:(void (^)(NSError *error))failure
{
    //社区主页未读消息数不要loading
    ZFCommunityMessageCountApi *api = [[ZFCommunityMessageCountApi alloc] initWithUserid:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        NSDictionary *dic = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dic = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if ([dic[@"statusCode"] integerValue] == 200  && [dic[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDic = dic[@"data"];
                if (completion) {
                    NSString *messageTotal = ZFGetStringFromDict(dataDic, @"total");
                    completion([messageTotal integerValue]);
                    return ;
                }
            }
        }
        if (failure) {
            failure(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


/**
 * 热门话题列表
 */
- (void)requestHotTopicList:(BOOL)isPicture completion:(void(^)(NSArray<ZFCommunityHotTopicModel *> *results))completion {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = Community_API(Port_hot_topic_list);
    requestModel.parmaters = @{@"app_type"      : @"2",
                               @"site"          : @"ZZZZZcommunity",
                               @"size"          : @"20",
                               @"flag"          : isPicture ? @"1" : @"0"
    };

    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *resutDatas = responseObject[ZFDataKey];
        
        NSArray *dataArray = [NSArray array];
        if (ZFJudgeNSArray(resutDatas)) {
            dataArray = [NSArray yy_modelArrayWithClass:[ZFCommunityHotTopicModel class] json:resutDatas];

        }
        if (completion) {
            completion(dataArray);
        }
        
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

/**
* 关联帖子最多的话题列表
*/
- (void)requestReviewTopicList:(id)parmaters completion:(void(^)(NSArray<HotWordModel *> *results))completion {
    
    NSArray *localArrays = [[ZFOutfitSearchHotWordManager manager] getLocalHotWordList];
    if (localArrays.count > 0 && [ZFOutfitSearchHotWordManager manager].hasRequest) {
        return;
    }
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = Community_API(Port_review_topic_list);
    requestModel.parmaters = @{@"app_type"      : @"2",
                               @"site"          : @"ZZZZZcommunity",
                               @"size"          : @"3000"};

    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *resutDatas = responseObject[ZFDataKey];
        
        NSArray *dataArray = [NSArray array];
        if (ZFJudgeNSArray(resutDatas)) {
            dataArray = [NSArray yy_modelArrayWithClass:[HotWordModel class] json:resutDatas];
        }
        if (completion) {
            completion(dataArray);
        }
        
        if (dataArray.count > 0) {
            [ZFOutfitSearchHotWordManager manager].hasRequest = YES;
            [ZFOutfitSearchHotWordManager saveHotWordList:dataArray];
        }
        
    } failure:^(NSError *error) {
        NSArray *localArrays = [[ZFOutfitSearchHotWordManager manager] getLocalHotWordList];
        if (completion) {
            completion(localArrays.count > 0 ? localArrays : nil);
        }
        
    }];
}

@end
