//
//  ZFCommunityPostShowRecentCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

typedef void(^RecentSelectBlock)(UIButton *button);

@interface ZFCommunityPostShowRecentCell : UITableViewCell

@property (nonatomic,strong) ZFGoodsModel *goodsListModel;

@property (nonatomic,copy) RecentSelectBlock recentSelectBlock;

+ (ZFCommunityPostShowRecentCell *)postRecentCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
