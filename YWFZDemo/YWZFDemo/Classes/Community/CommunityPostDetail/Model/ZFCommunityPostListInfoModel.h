//
//  ZFCommunityPostListInfoModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZFCommunityPictureModel;

//填坑 与ZFCommunityPictureModel本可复用，但是对应值类型不同

@interface ZFCommunityPostListInfoModel : NSObject

@property (nonatomic, copy) NSString *addTime;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isFollow;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, copy) NSString *is_top;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, copy) NSString *reviewId;
@property (nonatomic, copy) NSArray<ZFCommunityPictureModel *> *reviewPic;
@property (nonatomic, assign) NSInteger reviewType;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *topicList;
@property (nonatomic, copy) NSString *userId;

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;

// 自定义
@property (nonatomic, strong) UIColor             *randomColor;

@end
