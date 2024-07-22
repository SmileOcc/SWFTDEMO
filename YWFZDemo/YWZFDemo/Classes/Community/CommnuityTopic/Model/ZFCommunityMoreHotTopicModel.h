//
//  ZFCommunityMoreHotTopicModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityMoreHotTopicModel : NSObject
@property (nonatomic, copy) NSString *topicId; //话题的id
@property (nonatomic, copy) NSString *siteVersion; //
@property (nonatomic, copy) NSString *title; //话题标题
@property (nonatomic, copy) NSString *content; //话题内容
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *labelStatus;
@property (nonatomic, copy) NSString *iosIndexpic;
@property (nonatomic, copy) NSString *iosListpic;
@property (nonatomic, copy) NSString *iosDetailpic;
@property (nonatomic, copy) NSString *addTime;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *virtualNumber;
@property (nonatomic, copy) NSString *readNumber;
@property (nonatomic, copy) NSString *orderby;
@property (nonatomic, copy) NSString *isTopic;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *joinNumber; //参加话题人数

///订单详情显示的url
@property (nonatomic, copy) NSString *ios_orderpic;
@end
