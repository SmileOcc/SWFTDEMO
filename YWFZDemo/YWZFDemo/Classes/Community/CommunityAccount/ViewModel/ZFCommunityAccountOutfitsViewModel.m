//
//  ZFCommunityAccountOutfitsViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountOutfitsViewModel.h"
#import "ZFCommunityAccountOutfitsApi.h"
#import "ZFCommunityOutfitsListModel.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityOutfitsModel.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityAccountOutfitsViewModel ()
@property (nonatomic, strong) ZFCommunityOutfitsListModel       *listModel;
@property (nonatomic, strong) NSMutableArray                    *dataArray;
@end

@implementation ZFCommunityAccountOutfitsViewModel

- (void)requestOutfitsListData:(id)parmaters
            completion:(void (^)(id obj, NSInteger totalPage))completion
               failure:(void (^)(id))failure
{
    NSInteger page = [parmaters[1] integerValue];
    NSString *userId = parmaters[2];
    if (page != 1 && page == [self.listModel.total integerValue]) {
        if (completion) {
            completion(NoMoreToLoad, [self.listModel.total integerValue]);
        }
        return ;
    }
    
    ZFCommunityAccountOutfitsApi *api = [[ZFCommunityAccountOutfitsApi alloc] initWithUserid:userId currentPage:page];
    @weakify(self);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self);
        self.listModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        
        if (page == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.listModel.outfitsList];
        }else{
            [self.dataArray addObjectsFromArray:self.listModel.outfitsList];
        }
        
        self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoDataType;
        
        if (completion) {
            completion(self.dataArray, [self.listModel.total integerValue]);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoNetType;
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        if (failure) {
            failure(nil);
        }
    }];
    
}

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    ZFCommunityOutfitsModel *model = (ZFCommunityOutfitsModel *)(parmaters[kRequestModelKey]);
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:model.reviewId flag:![model.liked boolValue]];
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
                ShowToastToViewWithText(parmaters, dict[@"msg"]);
            }
            
            NSString *addTime = model.reviewAddTime ?: @"";
            NSString *avatar  = model.avatar ?: @"";
            NSString *content = model.reviewContent ?: @"";
            BOOL isFollow     = 0;
            NSString *nickName = model.nikename ?: @"";
            NSString *replyCount = model.replyCount ?: @"";
            NSArray *reviewPic = @[];
            NSString *userId = model.userId ?: @"";
            NSInteger likeCount = [model.likeCount integerValue];
            NSString *reviewId = model.reviewId ?: @"";
            BOOL isLiked = [model.liked boolValue];
            
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

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityAccountOutfitsApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"msg"] isEqualToString:@"Success"]) {
            return [ZFCommunityOutfitsListModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}
@end
