//
//  YXKlineSubIndexCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXKlineSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXKlineSubIndexCell : UITableViewCell

@property (nonatomic, strong) YXKlineSubConfigModel *model;

@property (nonatomic, copy) void (^changeCycleCallBack)(void);

@end

NS_ASSUME_NONNULL_END
