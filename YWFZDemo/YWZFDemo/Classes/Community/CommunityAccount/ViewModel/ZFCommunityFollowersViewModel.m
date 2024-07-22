//
//  ZFCommunityFollowersViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFollowersViewModel.h"
#import "ZFCommunityFollowListModel.h"
#import "ZFCommunityFollowModel.h"
#import "ZFCommunityFollowListApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityFollowersViewModel ()
@property (nonatomic, strong) ZFCommunityFollowListModel        *followModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityFollowModel *> *dataArray;
@end

@implementation ZFCommunityFollowersViewModel

#pragma mark - Requset
- (void)requestFollowersListData:(id)parmaters
                      completion:(void (^)(id obj, NSDictionary *pageDic))completion
                         failure:(void (^)(id))failure
{
    @weakify(self)
    
    NSString *refreshOrLoadMore = (NSString *)parmaters;
    NSInteger page = 1;
    if ([refreshOrLoadMore integerValue] == 0) {
        // 假如最后一页的时候
        if (self.followModel.page == self.followModel.pageCount) {
            if (completion) {
                NSDictionary *pageDic = @{kTotalPageKey:@(self.followModel.pageCount),
                                          kCurrentPageKey:@(self.followModel.page)};
                completion(NoMoreToLoad, pageDic);
            }
            return;
        }
        page = self.followModel.page  + 1;
    }
    
    ZFCommunityFollowListApi *api = [[ZFCommunityFollowListApi alloc] initWithCurPage:[@(page) stringValue] userListType:ZFUserListTypeFollowed userId:_userId];
    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        self.followModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        // 列表数据
        if (page == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.followModel.listArray];
        }else{
            [self.dataArray addObjectsFromArray:self.followModel.listArray];
        }
        self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoDataType;
        if (completion) {
            
            NSDictionary *pageDic = @{kTotalPageKey:@(self.followModel.pageCount),
                                      kCurrentPageKey:@(self.followModel.page)};
            completion(self.dataArray, pageDic);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoNetType;
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestFollowUserNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
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
