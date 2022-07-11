//
//  YXRemindTool.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/11/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXReminderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXRemindTool : NSObject

+ (NSString *)getTitleWithType: (YXReminderType)type;

+ (NSString *)getImageNameWithType: (YXReminderType)type;

+ (NSString *)getUnitStrWithType: (YXReminderType)type;

+ (BOOL)isFormWithType: (YXReminderType)type;

+ (YXReminderType)getTypeWithReminderModel: (YXReminderModel *)model;

+ (NSString *)getPlaceHoldStrWithType: (YXReminderType)type;

+ (NSString *)getSimplifiedTitleWithType: (YXReminderType)type;

+ (int)getUnitWithType: (YXReminderType)type;

+ (NSString *)formatFloat:(double)value andType: (YXReminderType)type;

@end

NS_ASSUME_NONNULL_END
