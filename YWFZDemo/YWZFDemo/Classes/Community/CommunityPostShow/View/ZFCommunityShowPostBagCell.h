//
//  ZFCommunityShowPostBagCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodListModel.h"

typedef void(^BagSelectBlock)(UIButton *button);

@interface ZFCommunityShowPostBagCell : UITableViewCell

@property (nonatomic,copy) BagSelectBlock bagSelectBlock;

@property (nonatomic,strong) GoodListModel *goodListModel;

+ (ZFCommunityShowPostBagCell *)postBagCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
