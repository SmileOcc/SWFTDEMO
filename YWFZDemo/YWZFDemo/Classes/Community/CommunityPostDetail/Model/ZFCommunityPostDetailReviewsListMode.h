//
//  ZFCommunityPostDetailReviewsListMode.h
//  Yoshop
//
//  Created by YW on 16/7/15.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityPostDetailReviewsListMode : NSObject

@property (nonatomic,copy) NSString *nickname;//昵称
@property (nonatomic,copy) NSString *content;//评论内容
@property (nonatomic,copy) NSString *userId;//评论用户ID
@property (nonatomic,copy) NSString *avatar;//用户头像
@property (nonatomic,copy) NSString *reviewId;//评论ID
@property (nonatomic,copy) NSString *isSecondFloorReply;//是否被回复
@property (nonatomic,copy) NSString *replyId;//回复ID
@property (nonatomic,copy) NSString *replyAvatar;//回复头像
@property (nonatomic,copy) NSString *replyUserId;//回复用户ID
@property (nonatomic,copy) NSString *replyNickName;//回复昵称

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;
@end
