//
//  YXNewCourseModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/7/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXNewCourseTitleModel : NSObject

@property (nonatomic, strong) NSString *cn;
@property (nonatomic, strong) NSString *en;
@property (nonatomic, strong) NSString *tw;
@property (nonatomic, strong) NSString *show;

@end

@interface YXNewCourseEnterModel : NSObject

@property (nonatomic, strong) YXNewCourseTitleModel *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSString *biz_id;

@end

@interface YXNewCourseVideoInfoSubExtraModel : NSObject
// 时长
@property (nonatomic, strong) NSString *video_time;
// 换算的时间
@property (nonatomic, strong) NSString *finalTime;
// 次数
@property (nonatomic, strong) NSString *times;
// 换算后的次数
@property (nonatomic, strong) NSString *viewCountStr;

@end


@interface YXNewCourseVideoInfoSubModel : NSObject

@property (nonatomic, strong) YXNewCourseTitleModel *title;
@property (nonatomic, strong) YXNewCourseTitleModel *sub_title;
@property (nonatomic, strong) YXNewCourseTitleModel *picture_url;
@property (nonatomic, strong) NSString *video_url;
@property (nonatomic, assign) BOOL hot_flag;
@property (nonatomic, strong) NSString *video_id;
@property (nonatomic, strong) NSString *corner_mark;
@property (nonatomic, strong) YXNewCourseVideoInfoSubExtraModel *video_extra_info;
@property (nonatomic, assign) NSTimeInterval create_time;
@property (nonatomic, strong) NSString *dateStr;

@property (nonatomic, assign) CGFloat height;

@end

// 合集
@interface YXNewCourseSetVideoInfoSubModel : NSObject

@property (nonatomic, strong) YXNewCourseTitleModel *title;
@property (nonatomic, strong) YXNewCourseTitleModel *sub_title;
@property (nonatomic, strong) YXNewCourseTitleModel *picture_url;
@property (nonatomic, assign) BOOL hot_flag;
@property (nonatomic, strong) NSString *corner_mark;
// 合集id
@property (nonatomic, strong) NSString *set_id;

@property (nonatomic, strong) NSArray <YXNewCourseVideoInfoSubModel *>*video_list;

@end

//set_video_info

@interface YXNewCourseVideoInfoModel : NSObject

// 1 视频 2 合集
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *id;

// 视频的数据
@property (nonatomic, strong) YXNewCourseVideoInfoSubModel *video_info;
// 合集的数据
@property (nonatomic, strong) YXNewCourseSetVideoInfoSubModel *set_video_info;


@end


@interface YXNewCourseTopicDetailModel : NSObject
@property (nonatomic, strong) NSString *special_topic_id;
@property (nonatomic, strong) YXNewCourseTitleModel *title;
@end

@interface YXNewCourseHomeManagerModel : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) YXNewCourseTopicDetailModel *special_topic_video_info;

@property (nonatomic, assign) BOOL isRecommend;

@property (nonatomic, strong) NSArray <YXNewCourseVideoInfoModel *>*special_topic_video_json_info;

@end








NS_ASSUME_NONNULL_END
