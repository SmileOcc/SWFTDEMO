//
//  ZFCommunityTopicDetailListModel.h
//  ZZZZZ
//
//  Created by DBP on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZFCommunityPictureModel;

static CGFloat kTopicDetailBottomHeight = 40.0;

@interface ZFCommunityTopicDetailListModel : NSObject

@property (nonatomic, copy) NSString *addTime;//评论时间
@property (nonatomic, copy) NSString *avatar;//用户头像
@property (nonatomic, copy) NSString *content;//评论内容
@property (nonatomic, assign) BOOL isFollow;//是否关注
@property (nonatomic, assign) BOOL isLiked;//是否点赞
@property (nonatomic, copy) NSString *likeCount;//点赞数
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *replyCount;//评论数
@property (nonatomic, copy) NSString *reviewsId;//评论ID
@property (nonatomic, strong) NSArray<ZFCommunityPictureModel *> *reviewPic;//图片
@property (nonatomic, strong) NSArray *topicList;//话题标签
@property (nonatomic, copy) NSString *userId;//当前回复用户的ID
// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;

//自定义
@property (nonatomic, assign) CGFloat    commentHeight;
@property (nonatomic, assign) NSInteger  positionIndex;
@property (nonatomic, assign) BOOL       isShowMark;



//下面高度属性在社区瀑布流cell中用到 , <非服务器返回>

@property (nonatomic, assign) BOOL                 isABBigCell;
@property (nonatomic, assign) CGSize               oneColumnCellSize;
@property (nonatomic, assign) CGFloat              oneColumnImageHeight;

@property (nonatomic, assign) CGSize               twoColumnCellSize;
@property (nonatomic, assign) CGFloat              twoColumnImageHeight;
@property (nonatomic, strong) NSAttributedString   *contentAttributedText;//帖子富文本
@property (nonatomic, copy) void (^touchTopicAttrTextBlcok)(NSString *topicName);

@property (nonatomic, strong) UIColor             *randomColor;

/**
 * 计算瀑布流Cell高度
 */
- (void)calculateWaterFlowCellSize;


/**
 * 计算普通Cell高度
 */
- (void)calculateCommonFlowCellSize;
@end
