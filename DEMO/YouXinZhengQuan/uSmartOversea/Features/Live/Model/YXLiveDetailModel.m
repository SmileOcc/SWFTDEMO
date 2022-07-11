//
//  YXLiveDetailModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveDetailModel.h"
#import "uSmartOversea-Swift.h"

@implementation YXLiveDetailModel

- (void)setCreate_time:(NSTimeInterval)create_time {
    _create_time = create_time;
    if (create_time > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:create_time];
        NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
        dateFormatter.dateFormat = @"MM-dd HH:mm";
        self.replayTimeStr = [dateFormatter stringFromDate:date];
    }
}

- (void)setWatch_user_count:(NSInteger)watch_user_count {
    _watch_user_count = watch_user_count;
    if (watch_user_count > 1000) {
        self.watchUserCountChange = [NSString stringWithFormat:@"%.1fk", watch_user_count / 1000.0];
    } else {
        self.watchUserCountChange = [NSString stringWithFormat:@"%@", @(watch_user_count)];
    }
}


@end
