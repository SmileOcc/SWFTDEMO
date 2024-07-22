//
//  ZFCommunityShowPostOrderCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityPostShowOrderListModel.h"

typedef void(^OrderSelectBlock)(UIButton *button);

@interface ZFCommunityShowPostOrderCell : UITableViewCell

@property (nonatomic,copy) OrderSelectBlock orderSelectBlock;

@property (nonatomic, strong) ZFCommunityPostShowOrderListModel *goodsListModel;

+ (ZFCommunityShowPostOrderCell *)postOrderCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
