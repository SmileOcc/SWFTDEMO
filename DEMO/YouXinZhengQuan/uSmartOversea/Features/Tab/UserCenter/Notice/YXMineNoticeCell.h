//
//  YXMineNoticeCell.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXNoticeSettingModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXMineNoticeCell : UITableViewCell

@property (nonatomic, strong) YXNoticeSettingModel *model;

@property (nonatomic, strong) UISwitch *switchView;

@end



NS_ASSUME_NONNULL_END
