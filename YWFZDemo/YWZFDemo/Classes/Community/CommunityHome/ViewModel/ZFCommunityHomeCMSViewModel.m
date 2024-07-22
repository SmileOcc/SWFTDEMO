//
//  ZFCommunityHomeCMSViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/6/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeCMSViewModel.h"

@implementation ZFCommunityHomeCMSViewModel

- (void)requestCMSListDataCompletion:(void (^)(NSArray<ZFCMSSectionModel *> *, BOOL ))completion {
    
    self.cmsModelArr = @[];
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.forbidEncrypt = YES;
    requestModel.needToCache = YES;
    requestModel.taget = self.controller;
    
    requestModel.timeOut = [[AccountManager sharedManager].cmsTimeOutDuration integerValue];
    requestModel.url = CMS_API(Port_cms_community);//CMS数据
    
    NSMutableDictionary *parmaters = [self baseParmatersDic];
    [parmaters addEntriesFromDictionary:@{@"page_code":@"Community"}];
    
    if (![YWLocalHostManager isOnlineRelease]){ //⚠️警告: 只供测试时使用,线上环境时不能传
        NSDictionary *siftDict = GetUserDefault(kTestCMSParmaterSiftKey);
        if (ZFJudgeNSDictionary(siftDict)) {
            [parmaters addEntriesFromDictionary:siftDict];
        }
    }

    parmaters[@"user_info"] = [[AccountManager sharedManager] userInfo];
    
    requestModel.parmaters = parmaters;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
        BOOL isCacheData = requestModel.isCacheData;
        if (isCacheData && [self.recommendResponseDict isEqualToDictionary:responseObject]) {
            YWLog(@"如果此次返回的是缓存数据,并且和当前列表数据相同则无需刷新");
            return;
        }
        self.recommendResponseDict = responseObject;
        NSDictionary *resultDic = responseObject[ZFDataKey];
        
        NSArray<ZFCMSSectionModel *> *cmsModelArr = @[];
        if (ZFJudgeNSDictionary(resultDic)) {
            
            self.menu_name = resultDic[@"menu_name"];
            self.menu_id = [NSString stringWithFormat:@"%@",resultDic[@"menu_id"]];
            NSArray *menuDataList = resultDic[@"menu_data"];
            if (ZFJudgeNSArray(menuDataList)) {
                cmsModelArr = [NSArray yy_modelArrayWithClass:[ZFCMSSectionModel class] json:menuDataList];
            }
            
            NSDictionary *btsDict = resultDic[@"bts_data"];
            if (ZFJudgeNSDictionary(btsDict)) {
                self.cmsBtsModel = [ZFBTSModel yy_modelWithJSON:btsDict];
            }
        }
        
        if (!isCacheData) {
            self.cmsModelArr = cmsModelArr;
        }
        
        if (completion) {
            NSArray<ZFCMSSectionModel *> *sectionModelArray = [self configCMSListData:cmsModelArr];
            completion(sectionModelArray, isCacheData);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil, NO);
        }
    }];
}
@end
