//
//  OSSVCommonsManagers.m
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCommonsManagers.h"

@implementation OSSVCommonsManagers


+ (OSSVCommonsManagers *)sharedManager {
    static OSSVCommonsManagers *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

+ (NSString *)dateFormatString:(NSDateFormatter *)dateFormatter time:(NSString *)time{
    if (STLIsEmptyString(time)) {
        time = @"";
    }
    if (!dateFormatter) {
        dateFormatter = [OSSVCommonsManagers sharedManager].arDateFormatter;
    }
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[time integerValue]]];
    return currentDateStr;
}

- (NSDateFormatter *)arDateFormatter {
    if (!_arDateFormatter) {
        _arDateFormatter = [[NSDateFormatter alloc]init];
        _arDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_arDateFormatter setDateFormat:@"dd-MM-yyyy"];
        } else {
            [_arDateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
    }
    return _arDateFormatter;
}

-(NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [_dateFormatter setDateFormat:@"dd-MM-yyyy"];
//        } else {
            [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
//        }
    }
    return _dateFormatter;
}

- (NSDateFormatter *)arDateTimeFormatter {
    if (!_arDateTimeFormatter) {
        _arDateTimeFormatter = [[NSDateFormatter alloc]init];
        _arDateTimeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_arDateTimeFormatter setDateFormat:@"HH:mm dd-MM-yyyy"];
        } else {
            [_arDateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }
    }
    return _arDateTimeFormatter;
}

- (NSDateFormatter *)dateTimeFormatter {
    if (!_dateTimeFormatter) {
        _dateTimeFormatter = [[NSDateFormatter alloc]init];
        _dateTimeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [_dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return _dateTimeFormatter;
}


- (NSDateFormatter *)arReviewDateTimeFormatter {//临时统一一致
    if (!_arDateTimeFormatter) {
        _arDateTimeFormatter = [[NSDateFormatter alloc]init];
        _arDateTimeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_arDateTimeFormatter setDateFormat:@"MMM. dd yyyy HH:mm"];
        } else {
            [_arDateTimeFormatter setDateFormat:@"MMM. dd yyyy HH:mm"];
        }
    }
    return _arDateTimeFormatter;
}

- (NSDateFormatter *)reviewDateTimeFormatter {
    if (!_dateTimeFormatter) {
        _dateTimeFormatter = [[NSDateFormatter alloc]init];
        _dateTimeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [_dateTimeFormatter setDateFormat:@"MMM. dd yyyy HH:mm"];
    }
    return _dateTimeFormatter;
}

@end
