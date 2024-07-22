//
//  ZFCommunityAccountShowsModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityPictureModel.h"
#import <UIKit/UIKit.h>

//瀑布刘底下白色区域高度
#define kFavesCellMaskHeight  44

@interface ZFCommunityAccountShowsModel : NSObject
@property (nonatomic,copy) NSString *addTime;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,assign) BOOL isFollow;
@property (nonatomic,assign) BOOL isLiked;
@property (nonatomic,copy) NSString *likeCount;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *replyCount;
@property (nonatomic,copy) NSString *reviewId;
@property (nonatomic,strong) NSArray *reviewPic;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,strong) NSArray *topicList;

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;

//下面高度属性在社区瀑布流cell中用到 , <非服务器返回>
@property (nonatomic, assign) CGSize twoColumnCellSize;
@property (nonatomic, assign) CGFloat twoColumnImageHeight;
@property (nonatomic, strong) NSAttributedString *contentAttributedText;//帖子富文本
@property (nonatomic, copy) void (^touchTopicAttrTextBlcok)(NSString *topicName);

//自定义颜色
@property (nonatomic, strong) UIColor *randomColor;

/**
 * 利用约束计算Cell大小
 */
- (void)calculateCellSize;

@end
