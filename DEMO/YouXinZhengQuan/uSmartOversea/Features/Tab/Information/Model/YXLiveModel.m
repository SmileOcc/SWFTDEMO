//
//  YXLiveModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveModel.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"

@implementation YXLiveTagModel


@end


@implementation YXLiveShowUrlSubModel


@end

@implementation YXLiveShowUrlModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"show_url": [YXLiveShowUrlSubModel class]};
}


- (void)setShow_url:(NSArray<YXLiveShowUrlSubModel *> *)show_url {
    _show_url = show_url;
    
    int value = 0;
    for (YXLiveShowUrlSubModel *model in show_url) {
        value += model.duration;
    }
    
    value = value / 1000;
    
    int hour = value / 3600;
    int min = (value % 3600) / 60;
    int sec = (value % 3600) % 60;
    if (hour > 0) {
        self.finalTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
    } else {
        self.finalTime = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }

}

@end

@implementation YXLiveAnchorModel

@end

@implementation YXLiveCoverImageModel

@end


@implementation YXLiveModel

- (void)setPredict_show_time:(NSTimeInterval)predict_show_time {
    _predict_show_time = predict_show_time;
    if (predict_show_time > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:predict_show_time];
        NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
        dateFormatter.dateFormat = @"MM-dd HH:mm";
        self.timeStr = [dateFormatter stringFromDate:date];
    }
}

- (void)setCreate_time:(NSTimeInterval)create_time {
    _create_time = create_time;
    if (create_time > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:create_time];
        NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
        dateFormatter.dateFormat = @"MM-dd";
        self.replayTimeStr = [dateFormatter stringFromDate:date];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
//    // 计算高度
    CGFloat width = 160;
    CGFloat titleH = [YXToolUtility getStringSizeWith:title andFont:[UIFont systemFontOfSize:14] andlimitWidth:width andLineSpace:3].height;
    if (titleH > 20) {
        titleH = 40;
    } else {
        titleH = 20;
    }
    
    CGFloat height = 9 / 16.0 * width + titleH + 8;
    
    self.height = height;
}

- (void)setWatch_user_count:(NSInteger)watch_user_count {
    _watch_user_count = watch_user_count;
    if (watch_user_count > 1000) {
        self.watchUserCountStr = [NSString stringWithFormat:@"%.1fk %@", watch_user_count / 1000.0, [YXLanguageUtility kLangWithKey:@"common_person_unit"]];
    } else {
        self.watchUserCountStr = [NSString stringWithFormat:@"%@ %@", @(watch_user_count), [YXLanguageUtility kLangWithKey:@"common_person_unit"]];
    }
}

- (void)setView_count:(NSInteger)view_count {
    _view_count = view_count;
    
    if (view_count > 1000) {
        NSString *counStr = [NSString stringWithFormat:@"%.1fk", view_count / 1000.0];
        self.viewCountStr = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"play_times"], counStr];
    } else {
        self.viewCountStr = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"play_times"], @(view_count)];
    }
}

@end


@implementation YXLiveCategoryModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"show_list": [YXLiveModel class]};
}


@end
