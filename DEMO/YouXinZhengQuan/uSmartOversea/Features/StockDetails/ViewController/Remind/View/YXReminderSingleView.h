//
//  YXReminderSingleView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXReminderModel;
NS_ASSUME_NONNULL_BEGIN


@interface YXReminderSingleCell : UITableViewCell

@property (nonatomic, strong) YXReminderModel *model;

@property (nonatomic, copy) void (^stChangeCallBack)(UISwitch *st);

@end

@interface YXReminderSingleView : UIView

@property (nonatomic, strong) YXReminderModel *model;

@property (nonatomic, copy) void (^stChangeCallBack)(UISwitch *st);

@property (nonatomic, assign) BOOL isMyRemind;

@end

NS_ASSUME_NONNULL_END
