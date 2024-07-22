
//
//  ZFCommunityFollowingViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFollowingViewModel.h"
#import "ZFCommunityFollowListModel.h"
#import "ZFCommunityFollowListApi.h"
#import "ZFCommunityFollowModel.h"
#import "ZFCommunityFollowApi.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityFollowingViewModel ()
@property (nonatomic, assign) NSInteger                         curPage;
@property (nonatomic, strong) ZFCommunityFollowListModel        *followModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityFollowModel *> *dataArray;
@end

@implementation ZFCommunityFollowingViewModel

#pragma mark - Requset

- (void)requestFollowingListData:(BOOL)isFirstPage
                      completion:(void (^)(NSMutableArray *dataArray, NSDictionary *pageDic))completion
                         failure:(void (^)(id))failure
{
    if (isFirstPage) {
        self.curPage = 1;
    } else {
        self.curPage = ++self.curPage;
    }
    
    ZFCommunityFollowListApi *api = [[ZFCommunityFollowListApi alloc] initWithCurPage:[@(self.curPage) stringValue] userListType:ZFUserListTypeFollowing userId:_userId];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        
        // 列表数据
        self.followModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        if (self.curPage == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.followModel.listArray];
        } else {
            [self.dataArray addObjectsFromArray:self.followModel.listArray];
        }
        
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(self.followModel.pageCount),
                                      kCurrentPageKey:@(self.followModel.page)};
            completion(self.dataArray, pageDic);
        }
    
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        --self.curPage;
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestFollowUserNetwork:(id)parmaters
                      completion:(void (^)(id))completion
                         failure:(void (^)(id))failure
{
    ShowLoadingToView(parmaters);
    ZFCommunityFollowModel *model = (ZFCommunityFollowModel *)(parmaters[kRequestModelKey]);
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:!model.isFollow followedUserId:model.userId];
    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            BOOL isFollow = !model.isFollow;
            NSDictionary *dic = @{@"userId"   : model.userId,
                                  @"isFollow" : @(isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
            ShowToastToViewWithText(parmaters, dict[@"msg"]);
        }
    
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityFollowListApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityFollowListModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}
@end
