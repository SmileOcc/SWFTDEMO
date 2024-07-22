//
//  ZFCommunityPostListModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFCommunityPictureModel;

@interface ZFCommunityPostListModel : NSObject
@property (nonatomic, copy) NSString *addTime;//评论时间
@property (nonatomic, copy) NSString *avatar;//用户头像
@property (nonatomic, copy) NSString *content;//评论内容
@property (nonatomic, assign) BOOL isFollow;//是否关注
@property (nonatomic, assign) BOOL isLiked;//是否点赞
@property (nonatomic, copy) NSString *likeCount;//点赞数
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *replyCount;//评论数
@property (nonatomic, copy) NSString *reviewId;//评论ID
@property (nonatomic, strong) NSArray<ZFCommunityPictureModel *> *reviewPic;//图片
@property (nonatomic, strong) NSArray *topicList;//话题标签
@property (nonatomic, copy) NSString *userId;//当前回复用户的ID

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;
@end
