//
//  ZFCommunityTopicDetailNewViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/9/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityTopicDetailHeadLabelModel.h"
#import "ZFCommunityTopicDetailModel.h"
#import "ZFCommunityTopicDetailListModel.h"
#import "ZFCommunityStyleLikesModel.h"

@interface ZFCommunityTopicDetailNewViewModel : BaseViewModel

@property (nonatomic, strong) ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel;
@property (nonatomic, strong) ZFCommunityTopicDetailModel          *topicDetailModel;
@property (nonatomic, strong) NSMutableArray            *dataArray;

@property (nonatomic, strong) NSMutableArray            *colorSet;


@property (nonatomic, assign) BOOL                      isLoadLike;// 是否正在加载点攒接口
@property (nonatomic, assign) BOOL                      isLoadfollow;


- (void)requestCommunityTopicPageData:(NSString *)topicId
                             reviewId:(NSString *)reviewId
                             sortType:(NSString *)sortType
                          isFirstPage:(BOOL)isFirstPage
                           completion:(void (^)(ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel,
                                                NSDictionary *pageInfo))completion;



//帖子列表
- (void)requestTopicDetailListNetwork:(NSString *)topicId
                             sortType:(NSString *)sortType
                            topicType:(NSString *)topicType
                          isFirstPage:(BOOL)isFirstPage
                           completion:(void (^)(NSDictionary *pageInfo))completion;

//点赞
- (void)requestLikeNetwork:(id)parmaters
                completion:(void (^)(id obj))completion
                   failure:(void (^)(id obj))failure;

//关注
- (void)requestFollowNetwork:(id)parmaters
                  completion:(void (^)(id obj))completion
                     failure:(void (^)(id obj))failure;

@end
