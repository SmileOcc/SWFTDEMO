//
//  ZFCommunityFavesItemModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityPictureModel.h"
#import <UIKit/UIKit.h>

//社区帖子瀑布刘底下白色区域高度
#define kFavesCellMaskHeight  44

@interface ZFCommunityFavesItemModel : NSObject <NSCoding,NSCopying,NSMutableCopying>
@property (nonatomic, copy) NSString *reviewId;//评论ID 、视频id
@property (nonatomic, copy) NSString *userId;//用户ID
@property (nonatomic, copy) NSString *avatar;//用户头像
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *addTime;//评论时间
@property (nonatomic, assign) BOOL isFollow;//是否关注
@property (nonatomic, copy) NSString *content;//评论内容
@property (nonatomic, strong) NSArray *topicList;//标签数组
@property (nonatomic, strong) NSArray<ZFCommunityPictureModel *> *reviewPic;//图片数组
@property (nonatomic, copy) NSString *likeCount;//点赞数
@property (nonatomic, assign) BOOL isLiked;//是否点赞
@property (nonatomic, copy) NSString *replyCount;//评论数

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;

///数据类型,1:帖子 2:话题 3:视频 4:banner
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *topicId;//评论ID
@property (nonatomic, assign) CGFloat ios_listpic_width;//话题图片宽度
@property (nonatomic, assign) CGFloat ios_listpic_height;//话题图片高
@property (nonatomic, copy) NSString *join_number;//话题views数
@property (nonatomic, copy) NSString *title;//话题title,lookbook title
@property (nonatomic, copy) NSString *ios_listpic;//话题图片

//视频相关
//@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *video_title;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *view_num;
@property (nonatomic, copy) NSString *duration;

//lookbook
@property (nonatomic, copy) NSString *ios_pic_url;
@property (nonatomic, assign) CGFloat ios_pic_width;
@property (nonatomic, assign) CGFloat ios_pic_height;
@property (nonatomic, copy) NSString *deeplink_url;
@property (nonatomic, copy) NSString *banner_id;


//自定义视频宽高
@property (nonatomic, assign) CGFloat video_width;
@property (nonatomic, assign) CGFloat video_height;

@property (nonatomic, copy) NSString *formatLikeCount;
@property (nonatomic, copy) NSString *formatReplyCount;
@property (nonatomic, copy) NSString *formatJoin_number;
@property (nonatomic, copy) NSString *formatView_num;

//自定义颜色
@property (nonatomic, strong) UIColor *randomColor;




//下面高度属性在社区瀑布流cell中用到 , <非服务器返回>

@property (nonatomic, assign) CGSize oneColumnCellSize;
@property (nonatomic, assign) CGFloat oneColumnImageHeight;
@property (nonatomic, assign) CGSize twoColumnCellSize;
@property (nonatomic, assign) CGFloat twoColumnImageHeight;
@property (nonatomic, strong) NSAttributedString *contentAttributedText;//帖子富文本
@property (nonatomic, copy) void (^touchTopicAttrTextBlcok)(NSString *topicName);

/**
 * 利用约束计算Cell大小
 */
- (void)calculateCellSize;

//修改更新单个对应数量，
- (void)updateLikeCont:(NSString *)likeCount;
- (void)updateReplyCount:(NSString *)replyCount;
- (void)updateJoinNumber:(NSString *)joinNumber;
- (void)updateViewNum:(NSString *)viewNum;

@property (nonatomic, assign) int is_top;

@end
