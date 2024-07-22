//
//  ZFCommunityMessageModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityPostDetailReviewsListMode.h"

// 社区消息类型
typedef NS_ENUM(NSInteger, MessageListType) {
    /** 1.关注 */
    MessageListFollowTag = 1,
    /** 2.评论 */
    MessageListCommendTag,
    /** 3.点赞 */
    MessageListLikeTag,
    /** 4.置顶 */
    MessageListGainedPoints,
    /** 5.发帖 */
    MessageListTypePost,
    /** 7.认证消息 */
    MessageListTypeCertified = 7,
    /** 8.收藏帖子 */
    MessageListTypeCollect = 8,
    /** 9.参与官方活动', */
    MessageListTypeJoinTopic = 9,
};

@interface ZFCommunityMessageModel : NSObject
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *review_id;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, copy) NSString *pic_src;
@property (nonatomic, copy) NSString *is_read;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, assign) MessageListType message_type;
@property (nonatomic, assign) BOOL is_delete;
@property (nonatomic, strong) ZFCommunityPostDetailReviewsListMode   *review_data;

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;

@property (nonatomic, copy) NSString *topic_id;

@end
