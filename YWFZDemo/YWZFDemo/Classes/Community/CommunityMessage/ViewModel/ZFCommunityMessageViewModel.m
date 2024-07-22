

//
//  ZFCommunityMessageViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessageViewModel.h"
#import "ZFCommunityMessageListModel.h"
#import "ZFCommunityMessagesApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityMessageViewModel ()
@property (nonatomic, strong) NSMutableArray                *messageListArray;
@property (nonatomic, strong) ZFCommunityMessageListModel   *messageListModel;
@end

@implementation ZFCommunityMessageViewModel

- (void)requestMessageListData:(id)parmaters
                    completion:(void (^)(id obj, NSDictionary *pageDic))completion
                       failure:(void (^)(id))failure
{
    
    NSArray *array = (NSArray *)parmaters;
    NSInteger page = 1;
    if ([array[0] integerValue] == 0) {
        // 假如最后一页的时候
        if ([self.messageListModel.curPage integerValue] == self.messageListModel.pageCount) {
            if (completion) {
                NSDictionary *pageDic = @{kTotalPageKey:@(self.messageListModel.pageCount),
                                          kCurrentPageKey:@([self.messageListModel.curPage integerValue])};
                completion(NoMoreToLoad, pageDic);
            }
            return;
        }
        page = [self.messageListModel.curPage integerValue]  + 1;
    }
    
    ZFCommunityMessagesApi *api = [[ZFCommunityMessagesApi alloc] initWithcurPage:page pageSize:PageSize];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        self.messageListModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        if (page == 1) {
            self.messageListArray = [NSMutableArray arrayWithArray:self.messageListModel.messageList];
        }else{
            [self.messageListArray addObjectsFromArray:self.messageListModel.messageList];
        }
        self.emptyViewShowType = self.messageListArray.count > 0 ? EmptyViewHideType : EmptyShowNoDataType;
        
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(self.messageListModel.pageCount),
                                      kCurrentPageKey:@([self.messageListModel.curPage integerValue])};
            completion(self.messageListArray, pageDic);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
    
}

//关注
- (void)requestFollowedNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSString *followedUserId = parmaters[kRequestUserIdKey];
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:YES followedUserId:followedUserId];
    ShowLoadingToView(parmaters);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        NSDictionary *dict = request.responseJSONObject;
        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
            dict = ZF_COMMUNITY_RESPONSE_TEST();
        }
        if ([dict[@"code"] integerValue] == 0) {
            
            if (completion) {
                completion(nil);
            }
            ShowToastToViewWithText(parmaters, dict[@"msg"]);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];

}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
    
    if ([request isKindOfClass:[ZFCommunityMessagesApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityMessageListModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}

@end
