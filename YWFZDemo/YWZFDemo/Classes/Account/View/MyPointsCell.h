//
//  DRewardsCell.h
//  Dezzal
//
//  Created by 7FD75 on 16/7/28.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointsModel.h"
@interface MyPointsCell : UITableViewCell
+ (MyPointsCell *)pointCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) PointsModel * model;

@end
