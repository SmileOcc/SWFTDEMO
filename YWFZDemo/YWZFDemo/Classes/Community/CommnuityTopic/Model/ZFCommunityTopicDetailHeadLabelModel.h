//
//  ZFCommunityTopicDetailHeadLabelModel.h
//  ZZZZZ
//
//  Created by DBP on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFCommunityTopicDetailListModel.h"

typedef NS_ENUM(NSInteger, TopicDetailActivityType) {
    /**话题：综合*/
    TopicDetailActivityTypeComplex = 0,
    /**话题：普通*/
    TopicDetailActivityTypeNormal = 1,
    /**话题：穿搭*/
    TopicDetailActivityTypeOutfit = 2,
};

@interface TopicDetailHeadActivityModel : NSObject

/** 开始*/
@property (nonatomic, copy) NSString *start_time;
/** 结束*/
@property (nonatomic, copy) NSString *end_time;
/** 倒计时秒*/
@property (nonatomic, copy) NSString *time;
/** 显示活动：状态:1显示,0不显示(默认) */
@property (nonatomic, copy) NSString *status;
/** 活动文案*/
@property (nonatomic, copy) NSString *content;
/** 话题类型：状态:1普通帖,2穿搭帖,0综合帖*/
@property (nonatomic, copy) NSString *type;
/** 配置的deeplink链接*/
@property (nonatomic, copy) NSString *link_url;
/** 配置的deeplink的对应名称*/
@property (nonatomic, copy) NSString *link_name;

@end



@interface ZFCommunityTopicDetailHeadLabelModel : NSObject

@property (nonatomic, strong) TopicDetailHeadActivityModel *activity;

@property (nonatomic, copy) NSString *topicLabelId;//话题标签Id
@property (nonatomic, copy) NSString *content;//内容
@property (nonatomic, copy) NSString *topicLabel;//话题标签
@property (nonatomic, copy) NSString *labelStatus;//标签状态
@property (nonatomic, copy) NSString *number;//
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *virtualNumber;//评论ID
@property (nonatomic, copy) NSString *joinNumber;//参与人数
@property (nonatomic, copy) NSString *type;//当前回复用户的ID
@property (nonatomic, copy) NSString *iosDetailpic;
/**精选标签*/
@property (nonatomic, copy) NSString *tab_name;
/**点赞数据*/
@property (nonatomic, copy) NSString *liked_num;

/**置顶帖子*/
@property (nonatomic, strong) ZFCommunityTopicDetailListModel *top_review;



//自定义
@property (nonatomic, assign) BOOL                      isShowAllContent;
@property (nonatomic, copy) NSAttributedString        *contentAttributedText;//帖子富文本
@property (nonatomic, copy) NSAttributedString        *likedNumAttributedText;

@property (nonatomic, copy) void (^topicDetailBlock)(NSString *labName);

/**
 * 开启秒杀倒计时key: 返回固定默认值
 */
@property (nonatomic, copy) NSString   *countDownTimerKey;


+ (CGFloat)iphoneTopSpace;

@end
