//
//  YXLiveDetailModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXLiveModel.h"

//NS_ASSUME_NONNULL_BEGIN

@interface YXLiveDetailModel : NSObject

@property (nonatomic, strong, nullable) YXLiveAnchorModel *anchor;
@property (nonatomic, strong, nullable) NSString *anchor_id;
@property (nonatomic, strong, nullable) NSString *id;
@property (nonatomic, strong, nullable) NSString *post_id;
@property (nonatomic, strong, nullable) NSString *push_url;
// 直播观看链接
@property (nonatomic, strong, nullable) NSString *show_url;
@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, assign) NSInteger watch_user_count;
@property (nonatomic, strong, nullable) NSString *watchUserCountChange;
// 直播状态 0:全部 1:预告中 2:直播中 3:直播中止 4:直播已结束 5:直播已下线(删除)"
@property (nonatomic, assign) NSInteger show_stocks_id;
@property (nonatomic, assign) NSInteger status;

// 封面图数组
@property (nonatomic, strong, nullable) YXLiveCoverImageModel *cover_images;
// 点赞数
@property (nonatomic, assign) NSInteger likeCount;

@property (nonatomic, strong, nullable) NSString *detail;

// 播放次数(回放)
@property (nonatomic, assign) int view_count;

@property (nonatomic, assign) NSTimeInterval create_time;
@property (nonatomic, strong, nullable) NSString *replayTimeStr;

// 回放的id, 如果生成回放, id > 0
@property (nonatomic, strong, nullable) NSString *demand_id;


@end

//NS_ASSUME_NONNULL_END
