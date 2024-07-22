//
//  ZFCommunityPostDetailViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAppsflyerAnalytics.h"
#import "ZFCommunityTopicDetailBaseSection.h"
#import "ZFCommunityTopicDetailPicSection.h"
#import "ZFCommunityTopicDetailDescripSection.h"
#import "ZFCommunityTopicDetailUserInfoSection.h"
#import "ZFCommunityTopicDetailSimilarSection.h"
#import "ZFCommunityTopicDetailRelateSection.h"
#import "ZFCommunityTopicDetailCommentSection.h"

#import "ZFCommunityPostListInfoModel.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFAnalytics.h"
#import "BaseViewModel.h"

@class YYPhotoGroupItem, ZFCommunityPostDetailModel;

extern NSString *const kIsCurrentVC;
@interface ZFCommunityPostDetailViewModel : BaseViewModel

@property (nonatomic, strong) NSMutableArray<ZFCommunityTopicDetailBaseSection *> *sectionArray;

@property (nonatomic, assign) NSInteger                 positionIndex;

@property (nonatomic, assign) ZFAppsflyerInSourceType   sourceType;

@property (nonatomic, strong) NSMutableArray            *colorSet;

//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpression;




/**
 帖子详情

 @param reviewID 帖子id
 @param relateFlag 1：获取相关帖子列表，0：不获取
 @param complateHandle
 */
- (void)requestTopicDetailWithReviewID:(NSString *)reviewID relateFlag:(BOOL)relateFlag complateHandle:(void(^)(void))complateHandle;

- (void)requestRelateWithReviewID:(NSString *)reviewID complateHandle:(void(^)(NSArray <ZFCommunityPostListInfoModel *> *topicArray))complateHandle;

- (void)requestLikeWithIndexPath:(NSIndexPath *)indexPath complateHandle:(void(^)(void))complateHandle;

- (void)requestFollowUserWithComplateHandle:(void(^)(void))complateHandle;

- (void)requestCollect:(NSString *)reviewID complateHandle:(void(^)(BOOL success, BOOL state, NSString *msg))complateHandle;


- (BOOL)isRequestSuccess;
- (NSString *)tipMessage;

- (void)setIsFollow:(BOOL)isFollow;
- (void)setIsLike:(BOOL)isLike;
- (void)setLikeNumberWithChangeNumber:(NSInteger)changeNumber;
- (void)setGoodsInfoArray:(NSArray *)goodsInfoArray;

// 获取布局数据
- (NSInteger)sectionCount;
- (ZFCommunityTopicDetailBaseSection *)baseSectionWithSection:(NSInteger)section;
- (CGSize)itemSizeWithIndexPath:(NSIndexPath *)indexPath;

#pragma mark - 获取显示数据
// 分组数据类型
- (ZFTopicSectionType)sectionTypeInSection:(NSInteger)section;

// 图片数据
- (NSString *)picURLInIndexPath:(NSIndexPath *)indexPath;

//显示点击的默认图片
- (YYAnimatedImageView *)currentShowImageView:(NSIndexPath *)indexPath placeHolder:(UIImage *)placeImage;
// 内容数据
- (ZFCommunityTopicDetailDescripSection *)descripSectionWithSection:(NSInteger)section;

// 用户数据
- (ZFCommunityTopicDetailUserInfoSection *)userInfoSectionWithSection:(NSInteger)section;
- (BOOL)userIsFollowURLInInIndexPath:(NSIndexPath *)indexPath;
- (NSString *)userNickName;

// 同款商品数据
- (ZFCommunityTopicDetailSimilarSection *)similarSectionWithSection:(NSInteger)section;

// 相关帖子数据
- (ZFCommunityTopicDetailRelateSection *)relateSectionWithSection:(NSInteger)section;

- (ZFCommunityTopicDetailCommentSection *)commentSectionWithSection:(NSInteger)section;

- (ZFCommunityPostDetailReviewsListMode *)commentModelWithSection:(NSIndexPath *)indexPath;


// 共用数据
- (BOOL)isMyTopic;
- (NSString *)replyCount;
- (NSString *)likeCount;
// 帖子类型
- (NSInteger)reviewType;
// 相关帖子ID
- (NSArray *)nextReviewIdsArray;
- (BOOL)isLiked;

- (NSString *)collectCount;
- (BOOL)isCollect;

- (NSArray<YYPhotoGroupItem *> *)collectionView:(UICollectionView *)collectionView  picItemWithIndexPath:(NSIndexPath *)indexPath beginFrame:(CGRect)beginFrame;
- (NSArray *)picImageViewArray;
- (NSString *)userID;
- (NSString *)nickname;
- (ZFCommunityPostDetailModel *)communityDetailModel;  // 解决历史遗留问题

// GA 商品点击统计
- (void)clickGoodsAdGAWithIndexPath:(NSIndexPath *)indexPath;

@end
