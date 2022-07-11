//
//  YXDateModel.h
//  LIne
//
//  Created by Kelvin on 2019/4/4.
//  Copyright © 2019年 Kelvin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXDateModel : NSObject

@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, copy) NSString *day;
@property (nonatomic, copy) NSString *hour;
@property (nonatomic, copy) NSString *minute;
@property (nonatomic, copy) NSString *second;
@property (nonatomic, copy) NSString *week;

@end

NS_ASSUME_NONNULL_END
