//
//  YXStareSignalModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareSignalModel.h"
#import <YYModel/YYModel.h>
#import "NSDateFormatter+en_US_POSIX_formatter.h"

@implementation YXStareSignalModel

- (void)setUnixTime:(long)unixTime {
    _unixTime = unixTime;
    
    if (unixTime > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime / 1000];
        NSDateFormatter *formatter = [NSDateFormatter en_US_POSIXFormatter];
        formatter.dateFormat = @"HH:mm:ss";
        NSString *dateStr = [formatter stringFromDate:date];
        self.unixTimeStr = dateStr;
    }
}

- (void)setDescribe:(NSString *)describe {
    _describe = describe;
    
    if (_describe.length > 0) {
        self.subModel = [YXStareSignalSubModel yy_modelWithJSON:describe];
    }
}

@end


@implementation YXStareSignalSubModel

@end

@implementation YXStareSignalSettingModel

@end


@implementation YXStarePushSettingSubModel

@end



@implementation YXStarePushSettingModel

// 声明自定义类参数类型
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"list" : [YXStarePushSettingSubModel class]};
}

@end




