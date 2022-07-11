//
//  YXNewCourseModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/7/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXNewCourseModel.h"
#import "uSmartOversea-Swift.h"

@implementation YXNewCourseTitleModel

@end

@implementation YXNewCourseEnterModel

@end

@implementation YXNewCourseVideoInfoSubExtraModel

- (void)setVideo_time:(NSString *)video_time {
    _video_time = video_time;
    int value = video_time.intValue;

    
    int hour = value / 3600;
    int min = (value % 3600) / 60;
    int sec = (value % 3600) % 60;
    if (hour > 0) {
        self.finalTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
    } else {
        self.finalTime = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }
}

- (void)setTimes:(NSString *)times {
    _times = times;
    NSInteger count = times.integerValue;
    
    if (count > 1000) {
        NSString *counStr = [NSString stringWithFormat:@"%.1fk", count / 1000.0];
        self.viewCountStr = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"play_times"], counStr];
    } else {
        self.viewCountStr = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"play_times"], @(count)];
    }
    
}

@end

// 合集
@implementation YXNewCourseSetVideoInfoSubModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"video_list": [YXNewCourseVideoInfoSubModel class]};
}


@end

@implementation YXNewCourseVideoInfoSubModel

- (void)setCreate_time:(NSTimeInterval)create_time {
    _create_time = create_time;
    if (create_time > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:create_time];
        NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
        dateFormatter.dateFormat = @"MM-dd";
        self.dateStr = [dateFormatter stringFromDate:date];
    }
}

- (void)setTitle:(YXNewCourseTitleModel *)title {
    _title = title;
    //    // 计算高度
    CGFloat width = 160;
    CGFloat titleH = [YXToolUtility getStringSizeWith:title.show andFont:[UIFont systemFontOfSize:14] andlimitWidth:width andLineSpace:3].height;
    if (titleH > 20) {
        titleH = 40;
    } else {
        titleH = 20;
    }
    
    CGFloat height = 9 / 16.0 * width + titleH + 8;
    
    self.height = height;
}


@end


@implementation YXNewCourseVideoInfoModel

@end

@implementation YXNewCourseTopicDetailModel

@end

@implementation YXNewCourseHomeManagerModel


+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"special_topic_video_json_info": [YXNewCourseVideoInfoModel class]};
}


@end
