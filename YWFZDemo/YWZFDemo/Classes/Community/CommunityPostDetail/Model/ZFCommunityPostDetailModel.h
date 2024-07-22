//
//  ZFCommunityPostDetailModel.h
//  Yoshop
//
//  Created by YW on 16/7/14.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZFCommunityPictureModel, ZFCommunityGoodsInfosModel;
@interface ZFCommunityPostDetailModel : NSObject

@property (nonatomic, copy) NSString *avatar;//用户头像
@property (nonatomic, copy) NSString *userId;//当前回复用户的ID
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *addTime;//评论时间
@property (nonatomic, assign) BOOL isFollow;//是否关注
@property (nonatomic, copy) NSString *content;//评论内容
@property (nonatomic, strong) NSArray <ZFCommunityPictureModel *> *reviewPic;//图片
@property (nonatomic, strong) NSArray *likeUsers;//被关注
@property (nonatomic, copy) NSString *likeCount;//点赞数
@property (nonatomic, assign) BOOL isLiked;//是否点赞
@property (nonatomic, copy) NSString *replyCount;//评论数
@property (nonatomic, strong) NSArray *labelInfo;//标签数组
@property (nonatomic, strong) NSArray <ZFCommunityGoodsInfosModel *> *goodsInfos;//商品推荐
@property (nonatomic, copy) NSString *type;//类型
@property (nonatomic, copy) NSString *sort;//热榜
@property (nonatomic, copy) NSString *viewNum;      // 阅读数
@property (nonatomic, copy) NSString *reviewTotal;  // 作者发帖总数
@property (nonatomic, copy) NSString *beLikedTotal; // 作者所有帖子被点赞总和
@property (nonatomic, assign) NSInteger reviewType; // 0普通帖， 1穿搭帖
@property (nonatomic, copy) NSString *title;
/** 相关帖子id*/
@property (nonatomic, strong) NSArray *nextReviewIds;

/** 跳转链接*/
@property (nonatomic, copy) NSString *deeplinkUrl;
@property (nonatomic, copy) NSString *deeplinkTitle;

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;
@property (nonatomic, copy) NSString *identify_content;

@property (nonatomic, copy) NSString *collectCount;// 收藏数量
@property (nonatomic, assign) BOOL isCollected;// 是否收藏

/*
 *
 *   -> 未返回这个字段 -> 这个字段是自己添加的
 *  从首页获取 发通知需要到
 *
 */
@property (nonatomic, copy) NSString *reviewsId;//评论ID

@property (nonatomic, strong) NSArray <UIImage *> *previewImages;//图片

@end
