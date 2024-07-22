
//
//  ZFCommunitySearchResultViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchViewModel.h"
#import "ZFCommunityFriendsResultApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFCommunityCommendUserApi.h"
#import "ZFCommunitySearchResultListModel.h"
#import "ZFCommunitySuggestedUsersListModel.h"
#import "ZFCommunitySearchResultModel.h"
#import "ZFCommunitySuggestedUsersModel.h"
#import "ZFCommunitySuggestedUsersModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunitySearchViewModel ()
@property (nonatomic, strong) NSMutableArray<ZFCommunitySearchResultModel *>    *resultDataArray;
@property (nonatomic, strong) NSMutableArray<ZFCommunitySuggestedUsersModel *>  *suggestedDataArray;
@property (nonatomic, strong) ZFCommunitySearchResultListModel   *searchListModel;
@property (nonatomic, strong) ZFCommunitySuggestedUsersListModel *suggestedUsersListModel;
@property (nonatomic, assign) NSInteger                          usersCurPage;
@property (nonatomic, assign) NSInteger                          commonCurPage;
@end

@implementation ZFCommunitySearchViewModel

#pragma mark - request methods

- (void)requestSearchUsersPageData:(BOOL)isFirstPage
                         searchKey:(NSString *)searchKey
                        completion:(void (^)(NSMutableArray *resultDataArray, NSDictionary *pageDic))completion
                           failure:(void (^)(NSError *error))failure {
    if (isFirstPage) {
        self.usersCurPage = 1;
    } else {
        self.usersCurPage = ++self.usersCurPage;
    }
    
    ZFCommunityFriendsResultApi *api = [[ZFCommunityFriendsResultApi alloc] initWithkeyWord:searchKey andCurPage:self.usersCurPage pageSize:[PageSize integerValue]];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        @strongify(self)
        self.searchListModel = [self dataAnalysisForSearchResultFromJson: request.responseJSONObject request:api];
        
        if (isFirstPage) {
            self.resultDataArray = [NSMutableArray arrayWithArray:self.searchListModel.searchList];
        }else{
            [self.resultDataArray addObjectsFromArray:self.searchListModel.searchList];
        }
        
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(self.searchListModel.pageCount),
                                      kCurrentPageKey:@([self.searchListModel.curPage integerValue])};
            completion(self.resultDataArray, pageDic);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        --self.usersCurPage;
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCommonPageData:(BOOL)isFirstData
                   completion:(void (^)(NSMutableArray *resultDataArray, NSDictionary *pageDic))completion
                      failure:(void (^)(id))failure {
    
    if (isFirstData) {
        self.commonCurPage = 1;
    } else {
        self.commonCurPage = ++self.commonCurPage;
    }
    
    ZFCommunityCommendUserApi *api = [[ZFCommunityCommendUserApi alloc] initWithcurPage:self.commonCurPage pageSize:[PageSize integerValue]];
    @weakify(self);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        @strongify(self);
        self.suggestedUsersListModel = [self dataAnalysisForSuggestedUsersFromJson:request.responseJSONObject request:api];
        
        if (isFirstData) {
            self.suggestedDataArray = [NSMutableArray arrayWithArray:self.suggestedUsersListModel.suggestedList];
        }else{
            [self.suggestedDataArray addObjectsFromArray:self.suggestedUsersListModel.suggestedList];
        }
        
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(self.suggestedUsersListModel.pageCount),
                                      kCurrentPageKey:@([self.suggestedUsersListModel.curPage integerValue])};
            completion(self.suggestedDataArray, pageDic);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        --self.commonCurPage;
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    NSInteger page = 1;
    if ([parmaters integerValue] == 0) {
        // 假如最后一页的时候
        if ([self.suggestedUsersListModel.curPage integerValue] == self.suggestedUsersListModel.pageCount) {
            if (completion) {
                completion(NoMoreToLoad);
            }
            return;
        }
        page = [self.suggestedUsersListModel.curPage integerValue]  + 1;
    }
    
    
    ZFCommunityCommendUserApi *api = [[ZFCommunityCommendUserApi alloc] initWithcurPage:page pageSize:[PageSize integerValue]];
    @weakify(self);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        @strongify(self);
        self.suggestedUsersListModel = [self dataAnalysisForSuggestedUsersFromJson:request.responseJSONObject request:api];
        
        if (page == 1) {
            self.suggestedDataArray = [NSMutableArray arrayWithArray:self.suggestedUsersListModel.suggestedList];
        }else{
            [self.suggestedDataArray addObjectsFromArray:self.suggestedUsersListModel.suggestedList];
        }
    
        if (completion) {
            completion(self.suggestedDataArray);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

//关注用户
- (void)requestFollowedNetwork:(id)parmaters UserID:(NSString *)ModelUserId Follow:(BOOL)isFollow completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    NSString *userId = parmaters[kRequestUserIdKey];
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:YES followedUserId:userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        NSDictionary *dict = request.responseJSONObject;
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            if (completion) {
                completion(nil);
            }
            NSDictionary *dic = @{@"userId"   : ModelUserId,
                                  @"isFollow" : @(!isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
        }
        ShowToastToViewWithText(parmaters, dict[@"msg"]);
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - deal with datas

//搜索结果数据解析
- (id)dataAnalysisForSearchResultFromJson:(id)json request:(SYBaseRequest *)request {
    if ([request isKindOfClass:[ZFCommunityFriendsResultApi class]]) {
        
        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
            json = ZF_COMMUNITY_RESPONSE_TEST();
        }
        
        if ([json[@"msg"] isEqualToString:@"Success"]) {
            return [ZFCommunitySearchResultListModel yy_modelWithJSON:json[@"data"]];
        } else {
            ShowToastToViewWithText(nil, json[@"errors"]);
        }
    }
    return nil;
}

- (id)dataAnalysisForSuggestedUsersFromJson:(id)json request:(SYBaseRequest *)request{
    if ([request isKindOfClass:[ZFCommunityCommendUserApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"msg"] isEqualToString:@"Success"]) {
            return [ZFCommunitySuggestedUsersListModel yy_modelWithJSON:json[@"data"]];
        }
        else {
            ShowToastToViewWithText(nil, json[@"errors"]);
            
        }
    }
    return nil;
}

@end
