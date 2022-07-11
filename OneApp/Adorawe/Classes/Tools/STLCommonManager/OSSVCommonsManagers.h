//
//  OSSVCommonsManagers.h
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCommonsManagers : NSObject

+ (OSSVCommonsManagers *)sharedManager;

@property (nonatomic, strong) NSDateFormatter *arDateFormatter;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDateFormatter *arDateTimeFormatter;

@property (nonatomic, strong) NSDateFormatter *dateTimeFormatter;

- (NSDateFormatter *)arReviewDateTimeFormatter;

- (NSDateFormatter *)reviewDateTimeFormatter;

+ (NSString *)dateFormatString:(NSDateFormatter *)dateFormatter time:(NSString *)time;

@end

NS_ASSUME_NONNULL_END
