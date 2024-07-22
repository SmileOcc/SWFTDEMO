//
//  ZFCommunityTopicDetailNewViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/9/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailNewViewModel.h"
#import "TopicDetailApi.h"
#import "ZFCommunityTopicHeadApi.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFLocalizationString.h"

@interface ZFCommunityTopicDetailNewViewModel ()
@property (nonatomic, strong) SYBatchRequest            *batchRequest;

@end

@implementation ZFCommunityTopicDetailNewViewModel


- (void)handleListContentHeight:(ZFCommunityTopicDetailModel *)detailModel topicType:(NSString *)topicType sortType:(NSString *)sortType{
    
    NSInteger topicTypeInt = [ZFToString(topicType) integerValue];
    NSInteger sortTypeInt = [ZFToString(sortType) integerValue];
    
    if (detailModel.list.count > 0) {
        [detailModel.list enumerateObjectsUsingBlock:^(ZFCommunityTopicDetailListModel  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            obj.positionIndex = idx;
            // 话题是穿搭，且是 RANKING/LATEAST列表
            if (topicTypeInt == TopicDetailActivityTypeOutfit
                && (sortTypeInt == TopicDetailSortTypeRanking || sortTypeInt == TopicDetailSortTypeLatest)) {
                obj.isABBigCell = YES;
                
                // Rank 前3个显示标识
                if (idx < 3) {
                    obj.isShowMark = sortTypeInt == TopicDetailSortTypeRanking ? YES : NO;
                }
                [obj calculateCommonFlowCellSize];
            } else {
                
                NSString *colorString =  [ZFThemeManager randomColorString:self.colorSet];
                if (self.colorSet.count == 3) {
                    [self.colorSet removeObjectAtIndex:0];
                }
                [self.colorSet addObject:colorString];
                obj.randomColor = [UIColor colorWithHexString:colorString];
                
                [obj calculateWaterFlowCellSize];
            }
        }];
        
    }
}

- (void)requestCommunityTopicPageData:(NSString *)topicId
                             reviewId:(NSString *)reviewId
                             sortType:(NSString *)sortType
                          isFirstPage:(BOOL)isFirstPage
                           completion:(void (^)(ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel,
                                                NSDictionary *pageInfo))completion {
    
    [self.batchRequest.requestArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SYNetworkManager sharedInstance] removeRequest:obj completion:nil];
    }];
    
    ZFCommunityTopicHeadApi *topicHeadApi = [[ZFCommunityTopicHeadApi alloc] initWithTopicId:topicId reviewId:reviewId];
    TopicDetailApi *detailApi = [[TopicDetailApi alloc] initWithcurPage:[Refresh integerValue]
                                                               pageSize:PageSize
                                                                topicId:topicId
                                                                   sort:sortType];
    
    //同时发送两个请求
    NSArray *apiArr = @[topicHeadApi, detailApi];
    self.batchRequest = [[SYBatchRequest alloc] initWithRequestArray:apiArr enableAccessory:YES];
    
    @weakify(self)
    [self.batchRequest startWithBlockSuccess:^(SYBatchRequest *batchRequest) {
        @strongify(self)
        
        NSArray *requests = batchRequest.requestArray;
        
        ZFCommunityTopicHeadApi *headApi = (ZFCommunityTopicHeadApi *)requests[0];
        self.topicDetailHeadModel = [self dataAnalysisFromJson:headApi.responseJSONObject request:headApi];

        TopicDetailApi *detailApi = (TopicDetailApi *)requests[1];
        self.topicDetailModel = [self dataAnalysisFromJson:detailApi.responseJSONObject request:detailApi];
        
        if (!ZFIsEmptyString(self.topicDetailHeadModel.top_review.reviewsId)) {
            NSMutableArray *listArray = [[NSMutableArray alloc] initWithArray:self.topicDetailModel.list];
            [listArray insertObject:self.topicDetailHeadModel.top_review atIndex:0];
            self.topicDetailModel.list = [[NSArray alloc] initWithArray:listArray];
        }
        
        [self setupAttributedContent];
        [self handleListContentHeight:self.topicDetailModel topicType:self.topicDetailHeadModel.activity.type sortType:sortType];
        self.dataArray = [NSMutableArray arrayWithArray:self.topicDetailModel.list];
        
        [self.colorSet removeAllObjects];
        
        if (completion) {
            NSDictionary *pageInfo = @{kTotalPageKey  : @(self.topicDetailModel.pageCount),
                                       kCurrentPageKey: @(self.topicDetailModel.curPage) };
            completion(self.topicDetailHeadModel, pageInfo);
        }
        
    } failure:^(SYBatchRequest *batchRequest) {
        if (completion) {
            completion(nil, nil);
        }
    }];
}


//帖子列表
- (void)requestTopicDetailListNetwork:(NSString *)topicId
                             sortType:(NSString *)sortType
                            topicType:(NSString *)topicType
                          isFirstPage:(BOOL)isFirstPage
                           completion:(void (^)(NSDictionary *pageInfo))completion {
    
    if (isFirstPage) {
        self.topicDetailModel.curPage = 1;
    }else{
        self.topicDetailModel.curPage += 1;
    }
    TopicDetailApi *api = [[TopicDetailApi alloc] initWithcurPage:self.topicDetailModel.curPage
                                                         pageSize:PageSize
                                                          topicId:topicId
                                                             sort:sortType];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        
        self.topicDetailModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        
        if (self.topicDetailModel.curPage == 1) {
            if (!ZFIsEmptyString(self.topicDetailHeadModel.top_review.reviewsId)) {
                NSMutableArray *listArray = [[NSMutableArray alloc] initWithArray:self.topicDetailModel.list];
                [listArray insertObject:self.topicDetailHeadModel.top_review atIndex:0];
                self.topicDetailModel.list = [[NSArray alloc] initWithArray:listArray];
            }
        }
        //计算高度
        [self handleListContentHeight:self.topicDetailModel topicType:ZFToString(topicType) sortType:sortType];
        if (self.topicDetailModel.curPage == 1) {
            [self.colorSet removeAllObjects];
            self.dataArray = [NSMutableArray arrayWithArray:self.topicDetailModel.list];
        } else {
            [self.dataArray addObjectsFromArray:self.topicDetailModel.list];
        }
        
        if (completion) {
            NSDictionary *pageInfo = @{kTotalPageKey  : @(self.topicDetailModel.pageCount),
                                       kCurrentPageKey: @(self.topicDetailModel.curPage) };
            completion(pageInfo);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        --self.topicDetailModel.curPage;
        if (completion) {
            completion(nil);
        }
    }];
}

//点赞
- (void)requestLikeNetwork:(id)parmaters
                completion:(void (^)(id obj))completion
                   failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    if (self.isLoadLike) {
        return;
    }
    self.isLoadLike = YES;
    
    ZFCommunityTopicDetailListModel *model = (ZFCommunityTopicDetailListModel *)dict[kRequestModelKey];
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:model.reviewsId flag:!model.isLiked];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        self.isLoadLike = NO;
        NSDictionary *result = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            result = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if ([dict[@"code"] integerValue] == 0) {
            NSString *addTime = model.addTime;
            NSString *avatar  = model.avatar;
            NSString *content = model.content;
            BOOL isFollow     = model.isFollow;
            NSString *nickName = model.nickname;
            NSString *replyCount = model.replyCount;
            NSArray *reviewPic = model.reviewPic;
            NSString *userId = model.userId;
            NSInteger likeCount = [model.likeCount integerValue];
            NSString *reviewId = model.reviewsId;
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
        
        NSString *tipMes = result[@"msg"];
        if (tipMes) {
            ShowToastToViewWithText(dict, tipMes);
        }
        
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        self.isLoadLike = NO;
        if (failure) {
            failure(nil);
        }
    }];
}

////关注
- (void)requestFollowNetwork:(id)parmaters
              completion:(void (^)(id obj))completion
                   failure:(void (^)(id obj))failure {

       NSDictionary *dict = parmaters;
       if (self.isLoadfollow) {
           return;
       }
       self.isLoadfollow = YES;

       ZFCommunityTopicDetailListModel *model = (ZFCommunityTopicDetailListModel*)dict[@"model"];
       ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:!model.isFollow followedUserId:model.userId];

       @weakify(self)
       [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
           @strongify(self)

           YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);

           self.isLoadfollow = NO;
           NSDictionary *result = request.responseJSONObject;
//           if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//               result = ZF_COMMUNITY_RESPONSE_TEST();
//           }
           if ([dict[@"code"] integerValue] == 0) {
               NSDictionary *dic = @{@"userId"   : model.userId,
                                     @"isFollow" : @(!model.isFollow)};
               [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
           }
           ShowToastToViewWithText(dict, result[@"msg"]);

           if (completion) {
               completion(nil);
           }
       } failure:^(__kindof SYBaseRequest *request, NSError *error) {
           self.isLoadfollow = NO;
           if (failure) {
               failure(nil);
           }
       }];
    
}


 - (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
     YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
     if ([request isKindOfClass:[ZFCommunityTopicHeadApi class]]) {
//         if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//             json = ZF_COMMUNITY_RESPONSE_TEST();
//         }
         if ([json[@"code"] integerValue] == 0) {
             return [ZFCommunityTopicDetailHeadLabelModel yy_modelWithJSON:json[@"data"]];
         }
     }else if ([request isKindOfClass:[TopicDetailApi class]]) {
//         if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//             json = ZF_COMMUNITY_RESPONSE_TEST();
//         }
         if ([json[@"code"] integerValue] == 0) {
             return [ZFCommunityTopicDetailModel yy_modelWithJSON:json[@"data"]];
         }
     }
     return nil;
 }


- (void)setupAttributedContent
{
    //一个Model只初始化一次帖子富文本
    if (!self.topicDetailHeadModel.contentAttributedText) {
        
        NSString *contentStr = @"";
        if (!ZFIsEmptyString(self.topicDetailHeadModel.topicLabel)) {
            contentStr = [NSString stringWithFormat:@"%@ %@",ZFToString(self.topicDetailHeadModel.topicLabel) ,ZFToString(self.topicDetailHeadModel.content)];
        } else {
            contentStr = [NSString stringWithFormat:@"%@",ZFToString(self.topicDetailHeadModel.content)];
        }
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr];
        content.yy_font = [UIFont systemFontOfSize:14];
        content.yy_color = ZFC0x666666();
        
        if(self.topicDetailHeadModel.topicLabel.length > 0) {
            [content yy_setColor:ColorHex_Alpha(0xFFA800, 1.0) range:NSMakeRange(0,self.topicDetailHeadModel.topicLabel.length)];
        }
        
        NSArray <NSValue *> *rangeValues = [NSStringUtils matchString:content.string reg:RegularExpression matchOptions:NSMatchingReportProgress];
        [rangeValues enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj rangeValue];
            [content yy_setColor:ZFC0x3D76B9() range:range];
            [content yy_setTextHighlightRange:range color:ZFC0x3D76B9() backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NSString *labName = [content.string substringWithRange:range];
                if (self.topicDetailHeadModel.topicDetailBlock) {
                    self.topicDetailHeadModel.topicDetailBlock(labName);
                }
            }];
        }];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            paraStyle.alignment = NSTextAlignmentRight;
            [content addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, content.length)];
        }
        self.topicDetailHeadModel.contentAttributedText = content;
    }
    
    if (!self.topicDetailHeadModel.likedNumAttributedText) {
        
        if ([self.topicDetailHeadModel.liked_num integerValue] > 0) {
            //111,222,333,444
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            NSString *formatLikeCount = [formatter stringFromNumber:[NSNumber numberWithInteger:[self.topicDetailHeadModel.liked_num integerValue]]];
            
            NSString *contentStr = [NSString stringWithFormat:ZFLocalizedString(@"Community_story_x_likes", nil), formatLikeCount];
            
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr];
            content.yy_font = [UIFont systemFontOfSize:14];
            content.yy_color = ZFC0x666666();
            
            if(!ZFIsEmptyString(formatLikeCount)) {
                NSRange range = [contentStr rangeOfString:formatLikeCount];
                [content yy_setColor:ZFC0xFE5269() range:range];
            }
            
            //        if ([SystemConfigUtils isRightToLeftShow]) {
            //            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            //            paraStyle.alignment = NSTextAlignmentRight;
            //            [content addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, content.length)];
            //        }
            
            self.topicDetailHeadModel.likedNumAttributedText = content;

        } else {
            
            self.topicDetailHeadModel.likedNumAttributedText = [[NSMutableAttributedString alloc] initWithString:@""];
        }
        
    }
}


- (NSMutableArray *)colorSet {
    if (!_colorSet) {
        _colorSet = [[NSMutableArray alloc] init];
    }
    return _colorSet;
}
@end
