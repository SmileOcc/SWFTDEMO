

//
//  ZFCommunityFavesViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFavesViewModel.h"
#import "ZFCommunityFavesApi.h"
#import "ZFCommunityFavesModel.h"
#import "ZFCommunityFavesItemModel.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityFavesViewModel ()
@property (nonatomic, strong) ZFCommunityFavesModel     *model;
@property (nonatomic, strong) NSMutableArray            *dataArray;
@end

@implementation ZFCommunityFavesViewModel

- (void)requestFavesListData:(id)parmaters
                      userId:(NSString *)userId
                  completion:(void (^)(id obj, NSDictionary *pageDic))completion
                     failure:(void (^)(id obj))failure
{
    NSInteger page = 1;
    if ([parmaters integerValue] == 0) {
        // 假如最后一页的时候
        if ([self.model.curPage integerValue] == self.model.pageCount) {
            if (completion) {
                NSDictionary *pageDic = @{kTotalPageKey:@(self.model.pageCount),
                                          kCurrentPageKey:@([self.model.curPage integerValue])};
                completion(NoMoreToLoad, pageDic);
            }
            return;
        }
        page = [self.model.curPage integerValue]  + 1;
    }
    
    ZFCommunityFavesApi *api = [[ZFCommunityFavesApi alloc] initWithcurrentPage:page listUserId:userId];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        @strongify(self)
        self.model = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        
        
        //防止添加空对象,计算瀑布流的高度
        if (self.model.list && self.model.list.count > 0) {
            self.model.list = [self calculateCellHeight:self.model.list];
        }
        
        //列表数据
        if (page == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.model.list];
        }else{
            [self.dataArray addObjectsFromArray:self.model.list];
        }
        
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(self.model.pageCount),
                                      kCurrentPageKey:@([self.model.curPage integerValue])};
            completion(self.dataArray, pageDic);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        if (failure) {
            failure(self.dataArray);
        }
    }];
}

/**
 * 计算瀑布流的高度
 */
- (NSArray *)calculateCellHeight:(NSArray<ZFCommunityFavesItemModel *> *)listArray
{
    if (listArray.count==0) return nil;
    
    [listArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel * _Nonnull favesModel, NSUInteger idx, BOOL * _Nonnull stop) {
        //利用约束计算Cell大小
        [favesModel calculateCellSize];
    }];
    return listArray;
}

- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    ZFCommunityFavesItemModel *model = (ZFCommunityFavesItemModel *)(parmaters[kRequestModelKey]);
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:model.reviewId flag:!model.isLiked];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            if (completion) {
                completion(nil);
            }
            NSString *addTime = model.addTime ?: @"";
            NSString *avatar  = model.avatar ?: @"";
            NSString *content = model.content ?: @"";
            BOOL isFollow     = model.isFollow;
            NSString *nickName = model.nickname ?: @"";
            NSString *replyCount = model.replyCount ?: @"";
            NSArray *reviewPic = model.reviewPic;
            NSString *userId = model.userId ?: @"";
            NSInteger likeCount = [model.likeCount integerValue];
            NSString *reviewId = model.reviewId ?: @"";
            BOOL isLiked = model.isLiked;
            
            NSDictionary *dic = @{@"addTime" : addTime,
                                  @"avatar" : avatar,
                                  @"content" : content,
                                  @"isFollow" : @(isFollow),
                                  @"isLiked" : @(!isLiked),
                                  @"likeCount" : @(likeCount),
                                  @"nickname" : nickName,
                                  @"replyCount" : replyCount,
                                  @"reviewPic" : reviewPic,
                                  @"userId" : userId,
                                  @"reviewId" : reviewId};
            
            ZFCommunityStyleLikesModel *likeModel = [ZFCommunityStyleLikesModel yy_modelWithJSON:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLikeStatusChangeNotification object:likeModel];
        }
        ShowToastToViewWithText(parmaters, dict[@"msg"]);
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityFavesApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"msg"] isEqualToString:@"Success"]) {
            return [ZFCommunityFavesModel yy_modelWithJSON:json[@"data"]];
        }
        else {
            ShowToastToViewWithText(nil, json[@"errors"]);
        }
    }
    return nil;
}

@end
