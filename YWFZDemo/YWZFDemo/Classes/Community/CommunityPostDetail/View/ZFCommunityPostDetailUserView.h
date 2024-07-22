//
//  ZFCommunityPostDetailUserView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 社区帖子详情悬浮的用户信息
 */
typedef void(^TopicDetailUserBlock)(void);
@interface ZFCommunityPostDetailUserView : UICollectionReusableView

@property (nonatomic, assign) BOOL isMyTopic;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, copy) TopicDetailUserBlock followActionHandle;
@property (nonatomic, copy) TopicDetailUserBlock userAvarteActionHandle;
+ (ZFCommunityPostDetailUserView *)userHeaderViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)showSepareteView;
- (void)setUserWithAvarteURL:(NSString *)avarteURL;
- (void)setUserWithNickName:(NSString *)nickName;
- (void)setUserWithPost:(NSString *)postNum totalLiked:(NSString *)likedNum;
- (void)setUserWithRank:(NSInteger )vRank imgUrl:(NSString *)vRankUrl content:(NSString *)vRankContent;

/// 用于预览显示
- (void)setPreviewNickName:(NSString *)nickName;

- (void)hideFollowView;
@end
