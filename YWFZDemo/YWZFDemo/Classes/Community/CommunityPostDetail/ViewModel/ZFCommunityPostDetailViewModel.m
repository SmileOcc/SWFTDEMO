//
//  ZFCommunityPostDetailViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostDetailViewModel.h"
#import "CommunityDetailApi.h"
#import "YYPhotoBrowseView.h"
#import "ZFAppsflyerAnalytics.h"

#import "ZFCommunityPictureModel.h"
#import "ZFGoodsModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ZFCommunityPostListInfoModel.h"
#import "ZFCommunityPostDetailModel.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFPiecingOrderViewModel.h"
#import "YWLocalHostManager.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Constants.h"

#import "ZFBTSManager.h"
#import "ZFThemeManager.h"

#import "ZFCommunityPostDetailPicCCell.h"

NSString *const kIsCurrentVC = @"kIsCurrentVC";
@interface ZFCommunityPostDetailViewModel ()

@property (nonatomic, strong) ZFCommunityPostDetailModel *detailModel;
@property (nonatomic, strong) NSMutableArray *picViewArray;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *reviewID;
///保存统计推荐商品的属性
@property (nonatomic, strong) NSArray *analyticsGoodsList;
@end

@implementation ZFCommunityPostDetailViewModel

#pragma mark - 网络请求
- (void)requestTopicDetailWithReviewID:(NSString *)reviewID relateFlag:(BOOL)relateFlag  complateHandle:(void(^)(void))complateHandle {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = @{
                               @"is_enc"      : @"0",
                               @"type"        : @"9",
                               @"directory"   : @"35",
                               @"site"        : @"ZZZZZcommunity",
                               @"loginUserId" : USERID,
                               @"reviewId"    : reviewID,
                               @"app_type"    : @"2",
                               @"rotation"    : relateFlag ? @"1" : @"0"
                               };
    self.reviewID = reviewID;
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        self.detailModel  = [ZFCommunityPostDetailModel yy_modelWithJSON:responseObject[@"data"]];
        self.detailModel.reviewsId = reviewID;
        [self setSectionDataArray];
        if (complateHandle) {
            complateHandle();
        }
    } failure:^(NSError *error) {
        if (complateHandle) {
            complateHandle();
        }
    }];
}

- (void)requestRelateWithReviewID:(NSString *)reviewID complateHandle:(void(^)(NSArray <ZFCommunityPostListInfoModel *> *topicArray))complateHandle {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.eventName = @"relate_goods";
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = @{
                               @"is_enc"      : @"0",
                               @"type"        : @"9",
                               @"directory"   : @"67",
                               @"site"        : @"ZZZZZcommunity",
                               @"loginUserId" : USERID,
                               @"reviewId"    : reviewID,
                               @"app_type"    : @"2"
                               };
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        NSDictionary *dataDict = [responseObject ds_dictionaryForKey:@"data"];
        NSArray *list          = [dataDict ds_arrayForKey:@"list"];
        NSMutableArray<ZFCommunityPostListInfoModel *> *topicArray = [NSMutableArray new];
        [self.colorSet removeAllObjects];
        for (NSDictionary *infoDict in list) {
            ZFCommunityPostListInfoModel *topicModel = [ZFCommunityPostListInfoModel yy_modelWithJSON:infoDict];
            NSString *colorString =  [ZFThemeManager randomColorString:self.colorSet];
            if (self.colorSet.count == 3) {
                [self.colorSet removeObjectAtIndex:0];
            }
            [self.colorSet addObject:colorString];
            topicModel.randomColor = [UIColor colorWithHexString:colorString];
            [topicArray addObject:topicModel];
        }
        
        if (topicArray.count > 0) {
            ZFCommunityTopicDetailRelateSection *relateSection = [[ZFCommunityTopicDetailRelateSection alloc] init];
            relateSection.topicArray = topicArray;
            [self.sectionArray addObject:relateSection];
        }
        
        if (complateHandle) {
            complateHandle(topicArray);
        }
    } failure:^(NSError *error) {
        if (complateHandle) {
            complateHandle(nil);
        }
    }];
}

- (void)requestLikeWithIndexPath:(NSIndexPath *)indexPath complateHandle:(void (^)(void))complateHandle {
    NSString *reviewID = nil;
    BOOL isLike        = NO;
    ZFCommunityPostListInfoModel *topicInfoModel = [[ZFCommunityPostListInfoModel alloc] init];
    ZFCommunityTopicDetailRelateSection *relateSection = (ZFCommunityTopicDetailRelateSection *)[self.sectionArray objectAtIndex:indexPath.section];
    if (indexPath != nil) {
        if ([self sectionTypeInSection:indexPath.section] == ZFTopicSectionTypeRelated) {
            topicInfoModel = [relateSection.topicArray objectAtIndex:indexPath.item];
            reviewID       = topicInfoModel.reviewId;
            isLike         = topicInfoModel.isLiked;
        }
    } else {
        reviewID = self.detailModel.reviewsId;
        isLike   = self.detailModel.isLiked;
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.eventName = @"like";
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = @{
                               @"type"      : @"4",
                               @"site"      : @"ZZZZZcommunity",
                               @"userId"    : USERID,
                               @"reviewId"  : reviewID,
                               @"flag"      : [NSString stringWithFormat:@"%d", !isLike],  // 0为点赞;1为取消点赞
                               @"app_type"  : @"2"
                               };
    self.isSuccess = NO;
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSInteger code     = [responseObject ds_integerForKey:@"code"];
        NSString  *message = [responseObject ds_stringForKey:@"msg"];
        self.message       = message;
        if (code == 0) {
            self.isSuccess = YES;
            
            // 旧方式该更新相关页面
            NSString *addTime = topicInfoModel.addTime ?: @"";
            NSString *avatar  = topicInfoModel.avatar ?: @"";
            NSString *content = topicInfoModel.content ?: @"";
            BOOL isFollow     = topicInfoModel.isFollow;
            NSString *nickName = topicInfoModel.nickname ?: @"";
            NSString *replyCount = [NSString stringWithFormat:@"%ld",topicInfoModel.replyCount];
            NSArray *reviewPic = topicInfoModel.reviewPic;
            NSString *userId = topicInfoModel.userId ?: @"";
            NSInteger likeCount = topicInfoModel.likeCount;
            NSString *reviewId = topicInfoModel.reviewId ?: @"";
            BOOL isLiked = topicInfoModel.isLiked;
            
            if (indexPath == nil) {
                reviewId = self.detailModel.reviewsId;
                isLiked = self.detailModel.isLiked;
            }
            
            // 新方式该更新详情页操作
            if (indexPath == nil) {
                self.detailModel.isLiked = !self.detailModel.isLiked;
                NSInteger changeValue    = (self.detailModel.isLiked ? 1 : -1);
                NSInteger likeCount      = [self.detailModel.likeCount integerValue];
                likeCount = likeCount + changeValue;
                self.detailModel.beLikedTotal = [NSString stringWithFormat:@"%ld", [self.detailModel.beLikedTotal integerValue] + changeValue];
                self.detailModel.likeCount = [NSString stringWithFormat:@"%ld", likeCount];
                [self setBeLikedTotal];
            } else {
                topicInfoModel.isLiked   = !topicInfoModel.isLiked;
                topicInfoModel.likeCount = topicInfoModel.likeCount + (topicInfoModel.isLiked ? 1 : -1);
            }
            
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
                                  @"reviewId" : reviewId,
                                  kIsCurrentVC : [NSString stringWithFormat:@"%d", YES]};
            
            ZFCommunityStyleLikesModel *likeModel = [ZFCommunityStyleLikesModel yy_modelWithJSON:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLikeStatusChangeNotification object:likeModel];
        }
        if (complateHandle) {
            complateHandle();
        }
    } failure:^(NSError *error) {
        NSString *msgStr = ZFLocalizedString(@"Failed", nil);
        NSDictionary *infoDic = error.userInfo;
        if (ZFJudgeNSDictionary(infoDic)) {
            if (infoDic[@"msg"]) {
                msgStr = infoDic[@"msg"];
            }
        }
        self.message = msgStr;
        if (complateHandle) {
            complateHandle();
        }
    }];
}

- (void)requestCollect:(NSString *)reviewID complateHandle:(void(^)(BOOL success , BOOL state,NSString *msg))complateHandle {

    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.eventName = @"post_collect";
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = @{
                               @"type"        : @"7",
                               @"site"        : @"ZZZZZcommunity",
                               @"userId"      : USERID,
                               @"flag"        : [NSString stringWithFormat:@"%d", !self.detailModel.isCollected],  // 1收藏 0取消
                               @"reviewId"    : ZFToString(self.reviewID),
                               @"app_type"    : @"2"
                               };
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSInteger code     = [responseObject ds_integerForKey:@"code"];
        NSString  *message = [responseObject ds_stringForKey:@"msg"];
        
        BOOL tempSuccess = NO;
        if (code == 0) {
            tempSuccess = YES;
            self.detailModel.isCollected = !self.detailModel.isCollected;
            if (self.detailModel.isCollected) {
                self.detailModel.collectCount = [NSString stringWithFormat:@"%li",[self.detailModel.collectCount integerValue] + 1];
            } else {
                self.detailModel.collectCount = [NSString stringWithFormat:@"%li",[self.detailModel.collectCount integerValue] - 1];
            }
            
        }
        if (complateHandle) {
            complateHandle(tempSuccess,self.detailModel.isCollected,message);
        }
    } failure:^(NSError *error) {
        
        NSString *msgStr = ZFLocalizedString(@"Failed", nil);
        NSDictionary *infoDic = error.userInfo;
        if (ZFJudgeNSDictionary(infoDic)) {
            if (infoDic[@"msg"]) {
                msgStr = infoDic[@"msg"];
            }
        }
        self.message = msgStr;
        if (complateHandle) {
            complateHandle(NO,self.detailModel.isCollected,msgStr);
        }
    }];
}

- (void)requestFollowUserWithComplateHandle:(void(^)(void))complateHandle {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.eventName = @"follow";
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = @{
                               @"type"        : @"2",
                               @"site"        : @"ZZZZZcommunity",
                               @"loginUserId" : USERID,
                               @"flag"        : [NSString stringWithFormat:@"%d", !self.detailModel.isFollow],  // 1关注 0取消关注
                               @"followedUserId" : self.detailModel.userId,
                               @"app_type"        : @"2"
                               };
    self.isSuccess = NO;
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSInteger code     = [responseObject ds_integerForKey:@"code"];
        NSString  *message = [responseObject ds_stringForKey:@"msg"];
        self.message       = message;
        if (code == 0) {
            self.isSuccess = YES;
            self.detailModel.isFollow = !self.detailModel.isFollow;
            NSDictionary *dic = @{@"userId"   : self.detailModel.userId,
                                  @"isFollow" : @(!self.detailModel.isFollow),
                                  kIsCurrentVC : [NSString stringWithFormat:@"%d", YES]
                                  };
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
        }
        if (complateHandle) {
            complateHandle();
        }
    } failure:^(NSError *error) {
        
        NSString *msgStr = ZFLocalizedString(@"Failed", nil);
        NSDictionary *infoDic = error.userInfo;
        if (ZFJudgeNSDictionary(infoDic)) {
            if (infoDic[@"msg"]) {
                msgStr = infoDic[@"msg"];
            }
        }
        self.message = msgStr;
        if (complateHandle) {
            complateHandle();
        }
    }];
}

- (BOOL)isRequestSuccess {
    return self.isSuccess;
}

- (NSString *)tipMessage {
    return self.message;
}

#pragma mark - 布局数据
- (NSInteger)sectionCount {
    return self.sectionArray.count;
}

- (ZFCommunityTopicDetailBaseSection *)baseSectionWithSection:(NSInteger)section {
    if (section < self.sectionArray.count) {
        return [self.sectionArray objectAtIndex:section];
    }
    return nil;
}

- (CGSize)itemSizeWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    CGSize size = baseSection.itemSize;
    switch (baseSection.type) {
        case ZFTopicSectionTypePic: {
            ZFCommunityTopicDetailPicSection *picSection = (ZFCommunityTopicDetailPicSection *)baseSection;
            size = [picSection picSizeWithIndex:indexPath.item];
            break;
        }
        case ZFTopicSectionTypeRelated: {
            ZFCommunityTopicDetailRelateSection *relateSection = (ZFCommunityTopicDetailRelateSection *)baseSection;
            size = [relateSection goodsItemSizeWithIndex:indexPath.item];
            break;
        }
        case ZFTopicSectionTypeReview: {
            ZFCommunityTopicDetailCommentSection *commentSection = (ZFCommunityTopicDetailCommentSection *)baseSection;
            size = [commentSection commentItemSizeWithIndex:indexPath.item];
        }
        default:
            break;
    }
    return size;
}

- (NSString *)picURLInIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    if (baseSection.type == ZFTopicSectionTypePic) {
        ZFCommunityTopicDetailPicSection *picSection = (ZFCommunityTopicDetailPicSection *)baseSection;
        return [picSection picURLWithIndex:indexPath.item];
    }
    return nil;
}

- (ZFTopicSectionType)sectionTypeInSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    return baseSection.type;
}

#pragma mark - 内容数据
- (ZFCommunityTopicDetailDescripSection *)descripSectionWithSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    if (baseSection.type == ZFTopicSectionTypeDescrip) {
        ZFCommunityTopicDetailDescripSection *descripSection = (ZFCommunityTopicDetailDescripSection *)baseSection;
        return descripSection;
    }
    return nil;
}

- (ZFCommunityTopicDetailDescripSection *)descripSectionWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    if (baseSection.type == ZFTopicSectionTypeDescrip) {
        ZFCommunityTopicDetailDescripSection *descripSection = (ZFCommunityTopicDetailDescripSection *)baseSection;
        return descripSection;
    }
    return nil;
}

- (NSString *)descripContentInIndexPath:(NSIndexPath *)indexPath {
    return [self descripSectionWithIndexPath:indexPath].topicContentString;
}

- (NSArray *)descripTagArrayInIndexPath:(NSIndexPath *)indexPath {
    return [self descripSectionWithIndexPath:indexPath].tagArray;
}

- (NSString *)descripReadNumberInIndexPath:(NSIndexPath *)indexPath {
    return [self descripSectionWithIndexPath:indexPath].readNumberString;
}

- (NSString *)descripPublishTimeInIndexPath:(NSIndexPath *)indexPath {
    return [self descripSectionWithIndexPath:indexPath].publishTimeString;
}

#pragma mark - 用户数据
- (ZFCommunityTopicDetailUserInfoSection *)userInfoSectionWithSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    if (baseSection.type == ZFTopicSectionTypeUserInfo) {
        ZFCommunityTopicDetailUserInfoSection *userSection = (ZFCommunityTopicDetailUserInfoSection *)baseSection;
        return userSection;
    }
    return nil;
}

- (ZFCommunityTopicDetailCommentSection *)commentSectionWithSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    if (baseSection.type == ZFTopicSectionTypeReview) {
        ZFCommunityTopicDetailCommentSection *userSection = (ZFCommunityTopicDetailCommentSection *)baseSection;
        return userSection;
    }
    return nil;
}

- (ZFCommunityPostDetailReviewsListMode *)commentModelWithSection:(NSIndexPath *)indexPath {
    
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    if (baseSection.type == ZFTopicSectionTypeReview) {
        ZFCommunityTopicDetailCommentSection *userSection = (ZFCommunityTopicDetailCommentSection *)baseSection;
        if (userSection.lists.count > indexPath.item) {
            
            ZFCommunityPostDetailReviewsListMode *model = userSection.lists[indexPath.item];
            return model;
        }
    }
    return nil;
}


- (BOOL)userIsFollowURLInInIndexPath:(NSIndexPath *)indexPath {
    // FIXME:lk 优化
    return self.detailModel.isFollow;
}

- (NSString *)userNickName {
    return self.detailModel.nickname;
}

#pragma mark - 同款商品数据
- (ZFCommunityTopicDetailSimilarSection *)similarSectionWithSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    if (baseSection.type == ZFTopicSectionTypeSimilar) {
        ZFCommunityTopicDetailSimilarSection *similarSection = (ZFCommunityTopicDetailSimilarSection *)baseSection;
        return similarSection;
    }
    return nil;
}

#pragma mark - 相关帖子数据
- (ZFCommunityTopicDetailRelateSection *)relateSectionWithSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    if (baseSection.type == ZFTopicSectionTypeRelated) {
        ZFCommunityTopicDetailRelateSection *relateSection = (ZFCommunityTopicDetailRelateSection *)baseSection;
        return relateSection;
    }
    return nil;
}

#pragma mark - 公共数据
- (BOOL)isMyTopic {
    return [self.detailModel.userId isEqualToString:USERID];
}

- (NSString *)replyCount {
    return self.detailModel.replyCount > 0 ? self.detailModel.replyCount : 0;
}

- (NSString *)likeCount {
    return self.detailModel.likeCount > 0 ? self.detailModel.likeCount : 0;
}

- (NSInteger)reviewType {
    return self.detailModel.reviewType;
}

- (NSArray *)nextReviewIdsArray {
    if (ZFJudgeNSArray(self.detailModel.nextReviewIds)) {
        return self.detailModel.nextReviewIds;
    }
    return @[];
}

- (BOOL)isLiked {
    return self.detailModel.isLiked;
}

- (NSString *)collectCount {
    return self.detailModel.collectCount > 0 ? self.detailModel.collectCount : 0;
}

- (BOOL)isCollect {
    return self.detailModel.isCollected;
}

- (NSArray<YYPhotoGroupItem *> *)collectionView:(UICollectionView *)collectionView  picItemWithIndexPath:(NSIndexPath *)indexPath beginFrame:(CGRect)beginFrame {
    
    self.items = [NSMutableArray new];
    self.picViewArray = [NSMutableArray new];
    CGFloat offsetY = 0.0;

    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    if (baseSection.type == ZFTopicSectionTypePic) {
        ZFCommunityTopicDetailPicSection *picSection = (ZFCommunityTopicDetailPicSection *)baseSection;
        
        NSInteger rows = [collectionView numberOfItemsInSection:indexPath.section];
        for (int row = 0; row < rows; row++) {
            
            CGFloat width  = KScreenWidth;
            CGFloat height = 0.0;
            ZFCommunityPictureModel *model;
            if (picSection.pictureModelArray.count > row) {
                model = picSection.pictureModelArray[row];
                if ([model.bigPicWidth floatValue] != 0) {
                    height = width * [model.bigPicHeight floatValue] / [model.bigPicWidth floatValue];
                }
            }
            
            NSIndexPath *rowPath = [NSIndexPath indexPathForItem:row inSection:indexPath.section];
            ZFCommunityPostDetailPicCCell *picCCell = (ZFCommunityPostDetailPicCCell *)[collectionView cellForItemAtIndexPath:rowPath];
            
            //多个cell，cell还没有，复用问题
            if (!picCCell) {
                picCCell = [ZFCommunityPostDetailPicCCell picCellWithCollectionView:collectionView indexPath:rowPath];
                [picCCell configWithPicURL:model.bigPic];
                //没父类视图
                picCCell.imageView.frame = CGRectMake(0, offsetY, KScreenWidth + 50, beginFrame.size.height);
            }

            if (picCCell) {
                offsetY += height;
                [self.picViewArray addObject:picCCell.imageView];
                YYPhotoGroupItem *item = [YYPhotoGroupItem new];
                item.thumbView         = picCCell.imageView;
                NSURL *url             = [NSURL URLWithString:model.originPic];
                item.largeImageURL     = url;
                [self.items addObject:item];
            }
        }
    }
    return self.items;
    
}
//显示点击的默认图片
- (YYAnimatedImageView *)currentShowImageView:(NSIndexPath *)indexPath placeHolder:(UIImage *)placeImage{
    
    YYAnimatedImageView *imageV;
    if (self.items.count > indexPath.row) {
        
        YYPhotoGroupItem *item = self.items[indexPath.row];
        if ([item.thumbView isKindOfClass:[YYAnimatedImageView class]]) {
            
            imageV = (YYAnimatedImageView *)item.thumbView;
            [imageV yy_setImageWithURL:[NSURL URLWithString:ZFToString(item.largeImageURL)]
                           placeholder: placeImage ? placeImage : [UIImage imageNamed:@"loading_product"]
                               options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                              progress:nil
                             transform:nil
                            completion:nil];
        }
    }
    

    
    return imageV ? imageV : [[YYAnimatedImageView alloc] init];
}

- (NSArray *)picImageViewArray {
    return self.picViewArray;
}

- (NSString *)userID {
    return ZFToString(self.detailModel.userId);
}
- (NSString *)nickname {
    return ZFToString(self.detailModel.nickname);
}

- (ZFCommunityPostDetailModel *)communityDetailModel {
    return self.detailModel;
}

- (void)setSectionDataArray {
    self.sectionArray = [NSMutableArray new];
    if (self.detailModel.reviewPic.count > 0) {
        ZFCommunityTopicDetailPicSection *picSection = [[ZFCommunityTopicDetailPicSection alloc] init];
        picSection.pictureModelArray = self.detailModel.reviewPic;
        [self.sectionArray addObject:picSection];
    }
    
    // 用户信息栏
    if (self.detailModel) {
        ZFCommunityTopicDetailUserInfoSection *userInfoSection = [[ZFCommunityTopicDetailUserInfoSection alloc] init];
        userInfoSection.userAvatarURL = self.detailModel.avatar;
        userInfoSection.userNickName  = self.detailModel.nickname;
        userInfoSection.postNumber    = self.detailModel.reviewTotal;
        userInfoSection.likedNumber   = self.detailModel.beLikedTotal;
        userInfoSection.isFollow      = self.detailModel.isFollow;
        userInfoSection.identify_icon = self.detailModel.identify_icon;
        userInfoSection.identify_type = self.detailModel.identify_type;
        userInfoSection.identify_content = self.detailModel.identify_content;
        
        [self.sectionArray addObject:userInfoSection];
    }
    
    // 帖子描述栏
    if (self.detailModel) {
          ZFCommunityTopicDetailDescripSection *descripSection = [[ZFCommunityTopicDetailDescripSection alloc] init];
    
          [descripSection updateTitle:self.detailModel.title contentDesc:self.detailModel.content deeplinkUrl:ZFToString(self.detailModel.deeplinkUrl) deeplinkTitle:ZFToString(self.detailModel.deeplinkTitle) tags:self.detailModel.labelInfo readNumber:self.detailModel.viewNum publishTime:self.detailModel.addTime];
          [self.sectionArray addObject:descripSection];
    }
    
    if(self.detailModel) {
        
        ZFCommunityTopicDetailCommentSection *commentSection = [[ZFCommunityTopicDetailCommentSection alloc] init];
        commentSection.text = @"";
        commentSection.userImageUrl = ZFToString(self.detailModel.avatar);
        [self.sectionArray addObject:commentSection];
    }
    
    if (self.detailModel.goodsInfos.count > 0) {
        ZFCommunityTopicDetailSimilarSection *similarSection = [[ZFCommunityTopicDetailSimilarSection alloc] init];
        
        similarSection.goodsArray = self.detailModel.goodsInfos;
        [self.sectionArray addObject:similarSection];
        [self goodsAdGA];
    }
}

/**
 * 商品 GA 内推广告统计
 */
- (void)goodsAdGA {
    NSMutableString *goodsns = [[NSMutableString alloc] init];
    NSMutableArray <ZFGoodsModel *> *tempGoodsModelArray = [[NSMutableArray alloc] init];
    for (ZFCommunityGoodsInfosModel *model in self.detailModel.goodsInfos) {
        ZFGoodsModel *goodsModel = [self goodsInfoModelAdapterToGoodsModel:model];
        [tempGoodsModelArray addObject:goodsModel];
        [goodsns appendFormat:@"%@,", goodsModel.goods_sn];
    }
    
    if (tempGoodsModelArray.count > 0) {
        [ZFAnalytics showProductsWithProducts:tempGoodsModelArray position:1 impressionList:ZFGATopicGoodsList screenName:@"topic_detail" event:nil];

        //occ v3.7.0hacker 添加 ok
        self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                      impressionList:ZFGATopicGoodsList
                                                                                          screenName:@"topic_detail"
                                                                                               event:@""];
    }
    
    //这里要通过商品id获取一波商品的具体详情，因为 社区接口不能获取到商品的多级分类属性, 单独用于GIO统计
    @weakify(self)
    [ZFPiecingOrderViewModel requestHandpickGoodsList:goodsns completion:^(NSArray<ZFGoodsModel *> *goodsModelArray) {
        self.analyticsGoodsList = goodsModelArray;
        @strongify(self)
        @weakify(self)
        [goodsModelArray enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self)
            obj.postType = [self gainPostType];
            obj.af_rank = idx + 1;
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:@"TopicDetailList"];
        }];
        
        //v453 occ 有冲突的删掉
//        if (self.sourceType == ZFAppsflyerInSourceTypeZMeExploreid) {
//            [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray inSourceType:ZFAppsflyerInSourceTypeZMeExploreid sourceID:self.reviewID];
//        } else if (self.sourceType == ZFAppsflyerInSourceTypeZMeOutfitid) {
//            [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray inSourceType:ZFAppsflyerInSourceTypeZMeOutfitid sourceID:self.reviewID];
//        } else {
//            [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray inSourceType:ZFAppsflyerInSourceTypeZMeFollow sourceID:self.reviewID];
//        }
        
        [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray inSourceType:ZFAppsflyerInSourceTypeZMePostDetailRecommend sourceID:self.reviewID];

    }];
}

- (NSString *)gainPostType
{
    NSString *type = nil;
    if (self.sourceType == ZFAppsflyerInSourceTypeZMeExploreid) {
        type = GIOPostShows;
    }else if (self.sourceType == ZFAppsflyerInSourceTypeZMeVideoid) {
        type = GIOPostVideos;
    }else{
        type = GIOPostOutfits;
    }
    return type;
}

- (void)clickGoodsAdGAWithIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityGoodsInfosModel *infosModel = [self.detailModel.goodsInfos objectAtIndex:indexPath.item];
    ZFGoodsModel *goodsModel    = [self goodsInfoModelAdapterToGoodsModel:infosModel];
    [ZFAnalytics clickProductWithProduct:goodsModel position:1 actionList:ZFGATopicGoodsList];
    if (ZFJudgeNSArray(self.analyticsGoodsList) && indexPath.row < self.analyticsGoodsList.count) {
        //取一下统计代码保存的数据,因为后台取不到，所以客户端这里多做一步
        ZFGoodsModel *analyticsGoodsModel = self.analyticsGoodsList[indexPath.row];
        goodsModel = analyticsGoodsModel;
    }
    goodsModel.postType = [self gainPostType];
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:@"TopicDetailList" sourceParams:nil];
    ///点击增加growingIO 社区用户类型（转化变量）
    [Growing setEvarWithKey:GIOUserType_evar andStringValue:ZFgrowingToString(self.detailModel.userId)];
}

- (ZFGoodsModel *)goodsInfoModelAdapterToGoodsModel:(ZFCommunityGoodsInfosModel *)model {
    ZFGoodsModel *goodsModel = [ZFGoodsModel new];
    goodsModel.goods_id      = model.goodsId;
    goodsModel.goods_sn      = model.goods_sn;
    goodsModel.goods_title   = model.goodsTitle;
    return goodsModel;
}

#pragma mark - setter
- (void)setIsFollow:(BOOL)isFollow {
    self.detailModel.isFollow = isFollow;
}

- (void)setIsLike:(BOOL)isLike {
    self.detailModel.isLiked = isLike;
}

- (void)setLikeNumberWithChangeNumber:(NSInteger)changeNumber {
    self.detailModel.beLikedTotal = [NSString stringWithFormat:@"%ld", [self.detailModel.beLikedTotal integerValue] + changeNumber];
    self.detailModel.likeCount = [NSString stringWithFormat:@"%ld", [self.detailModel.likeCount integerValue] + changeNumber];
    [self setBeLikedTotal];
}

- (void)setBeLikedTotal {
    for (ZFCommunityTopicDetailBaseSection *section in self.sectionArray) {
        if (section.type == ZFTopicSectionTypeUserInfo) {
            ZFCommunityTopicDetailUserInfoSection *userSection = (ZFCommunityTopicDetailUserInfoSection *)section;
            userSection.likedNumber = self.detailModel.beLikedTotal;
        }
    }
}

- (void)setGoodsInfoArray:(NSArray *)goodsInfoArray {
    for (ZFCommunityTopicDetailBaseSection *section in self.sectionArray) {
        if (section.type == ZFTopicSectionTypeRelated) {
            ZFCommunityTopicDetailRelateSection *relateSection = (ZFCommunityTopicDetailRelateSection *)section;
            relateSection.topicArray = goodsInfoArray;
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
