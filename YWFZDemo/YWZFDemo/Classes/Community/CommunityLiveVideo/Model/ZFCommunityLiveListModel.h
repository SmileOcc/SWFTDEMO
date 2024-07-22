//
//  ZFCommunityLiveListModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>
#import "ZFCommunityLiveVideoRedNetModel.h"
#import "ZFCommunityLiveRouteModel.h"

typedef NS_ENUM(NSInteger,ZFCommunityLiveState) {
    /** 未开始*/
    ZFCommunityLiveStateReady = 1,
    /** 直播中*/
    ZFCommunityLiveStateLiving,
    /** 已结束*/
    ZFCommunityLiveStateEnd
};

/** 直播平台 1Facebook 2YouTube 3Zego 4第三方流*/
typedef NS_ENUM(NSInteger,ZFCommunityLivePlatform) {
    ZFCommunityLivePlatformUnknow,
    ZFCommunityLivePlatformFacebook = 1,
    ZFCommunityLivePlatformYouTube,
    ZFCommunityLivePlatformZego,
    ZFCommunityLivePlatformThirdStream,
};

@interface ZFCommunityLiveListModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *idx;
/** 标题*/
@property (nonatomic, copy) NSString *title;
/** 主播昵称*/
@property (nonatomic, copy) NSString *anchor_nickname;
/** 主播头像*/
@property (nonatomic, copy) NSString *anchor_headimg;
/** 简介*/
@property (nonatomic, copy) NSString *content;
/** 直播地址*/
@property (nonatomic, copy) NSString *live_address;
/** 直播平台 1Facebook 2YouTube 3Zego 4第三方流*/
@property (nonatomic, copy) NSString *live_platform;
/** 直播优惠券code*/
@property (nonatomic, copy) NSString *live_code;
@property (nonatomic, copy) NSString *ios_pic_url;
/** 播放量*/
@property (nonatomic, copy) NSString *view_num;
/** 离开播时间，单位秒*/
@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSString *start_time;
@property (nonatomic, copy) NSString *end_time;
/** 红人*/
@property (nonatomic, copy) NSArray<ZFCommunityLiveVideoRedNetModel *> *ios_hot;
/** 1待直播 2直播中 3已结束*/
@property (nonatomic, copy) NSString *type;
/** 1已经看过 0未看过*/
@property (nonatomic, copy) NSString *state;
/** 多个用英文逗号","隔开*/
@property (nonatomic, copy) NSString *skus;


@property (nonatomic, copy) NSString *ios_pic_width;
@property (nonatomic, copy) NSString *ios_pic_height;

@property (nonatomic, copy) NSString *file;

/**cdn 第三方*/
@property (nonatomic, copy) NSString *cdn_link;

@property (nonatomic, strong) NSArray<ZFCommunityLiveRouteModel *> *spare_channel_id;



//zego直播
@property (nonatomic, copy) NSString *like_num;
@property (nonatomic, copy) NSString *live_activity_code;
@property (nonatomic, copy) NSString *live_anchor_id;
@property (nonatomic, copy) NSString *live_token;
@property (nonatomic, copy) NSString *live_token_status;
@property (nonatomic, copy) NSString *room_id;
@property (nonatomic, copy) NSString *stream_id;
/// zego直播录播地址
@property (nonatomic, copy) NSString *live_replay_url;
// 1 横屏，2全屏
@property (nonatomic, assign) NSInteger pattern;

@property (nonatomic, copy) NSString *virtual_view_num;


// 默认全屏
@property (nonatomic, assign) BOOL isFull;










// 自定义
@property (nonatomic, copy) NSString *format_view_num;

@property (nonatomic, assign) NSInteger            section;


@property (nonatomic, strong) NSArray              *topicList;
@property (nonatomic, assign) CGFloat              commentHeight;

@property (nonatomic, assign) CGSize               oneColumnCellSize;
@property (nonatomic, assign) CGFloat              oneColumnImageHeight;

//内容富文本
@property (nonatomic, strong) NSAttributedString   *contentAttributedText;
//直播状态富文本
@property (nonatomic, strong) NSAttributedString   *liveStateAttributedText;

@property (nonatomic, copy) void (^touchTopicAttrTextBlcok)(NSString *topicName);

- (void)calculateCommonFlowCellSize;

- (ZFCommunityLivePlatform)currentLivePlatform;

@end
