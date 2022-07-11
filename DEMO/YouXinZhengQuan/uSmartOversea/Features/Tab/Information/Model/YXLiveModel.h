//
//  YXLiveModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveTagModel : NSObject
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@end


@interface YXLiveShowUrlSubModel : NSObject
@property (nonatomic, assign) int duration;
@end

@interface YXLiveShowUrlModel : NSObject
@property (nonatomic, strong) NSArray <YXLiveShowUrlSubModel *>*show_url;
@property (nonatomic, strong) NSString *finalTime;
@end


@interface YXLiveAnchorModel : NSObject

@property (nonatomic, strong) NSString *anchor_id;
@property (nonatomic, strong) NSString *anchor_uid;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *introduce;
@property (nonatomic, strong) NSString *nick_name;

@end

@interface YXLiveCoverImageModel : NSObject

@property (nonatomic, strong) NSArray *image;


@end

@interface YXLiveModel : NSObject

@property (nonatomic, strong) NSString *id;
// 主播
@property (nonatomic, strong) YXLiveAnchorModel *anchor;
// 封面图数组
@property (nonatomic, strong) YXLiveCoverImageModel *cover_images;
// 直播观看
@property (nonatomic, strong) YXLiveShowUrlModel *show_urls;
// 直播标题
@property (nonatomic, strong) NSString *title;
// 直播观看用户
@property (nonatomic, assign) NSInteger watch_user_count;
@property (nonatomic, strong) NSString *watchUserCountStr;
// 直播状态 0:全部 1:预告中 2:直播中 3:直播中止 4:直播已结束 5:直播已下线(删除)
@property (nonatomic, assign) NSInteger status;
// 直播预告时间，秒级时间戳
@property (nonatomic, assign) NSTimeInterval predict_show_time;

@property (nonatomic, strong) NSString *timeStr;

@property (nonatomic, assign) CGFloat height;

//@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) NSInteger view_count;

@property (nonatomic, strong) NSString *viewCountStr;

@property (nonatomic, strong) YXLiveTagModel *tag;

@property (nonatomic, assign) NSTimeInterval create_time;
@property (nonatomic, strong) NSString *replayTimeStr;

@end

@interface YXLiveCategoryModel: NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray <YXLiveModel *> *show_list;

@end

NS_ASSUME_NONNULL_END
