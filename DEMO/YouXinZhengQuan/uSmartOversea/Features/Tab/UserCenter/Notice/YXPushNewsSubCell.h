//
//  YXPushNewsSubCell.h
//  YouXinZhengQuan
//
//  Created by suntao on 2021/4/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXNoticeSettingModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXPushNewsSubCell : UITableViewCell

@property (nonatomic, copy) void(^selectedBlock)(YXNoticeSettingModel * model);
@property (nonatomic, strong) YXNoticeSettingModel * model;

+(instancetype)cellWithTableView:(UITableView *)tableview;
@end

NS_ASSUME_NONNULL_END
