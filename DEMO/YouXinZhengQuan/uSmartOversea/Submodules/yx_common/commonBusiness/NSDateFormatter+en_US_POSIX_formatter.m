//
//  NSDateFormatter+en_US_POSIX_formatter.m
//  uSmartOversea
//
//  Created by 覃明明 on 2022/5/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "NSDateFormatter+en_US_POSIX_formatter.h"

@implementation NSDateFormatter (en_US_POSIX_formatter)
+ (NSDateFormatter *)en_US_POSIXFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    return dateFormatter;
}
@end
