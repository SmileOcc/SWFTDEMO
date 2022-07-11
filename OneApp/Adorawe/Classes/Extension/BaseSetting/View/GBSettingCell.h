//
//  GBSettingCell.h
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBSettingItem;
@interface GBSettingCell : UITableViewCell
@property (nonatomic, strong) GBSettingItem *item;
@property (nonatomic, assign, getter = isLastRowInSection) BOOL lastRowInSection;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
