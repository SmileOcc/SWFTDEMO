//
//  OSSVSettingsTablesCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVSettingsTablesCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentTitleLabel;
@property (nonatomic, strong) UILabel *remarkDetailLabel;

+ (OSSVSettingsTablesCell *)settingCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
