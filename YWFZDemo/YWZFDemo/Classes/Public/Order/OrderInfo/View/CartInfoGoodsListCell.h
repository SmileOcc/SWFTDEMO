//
//  CartInfoGoodsListCell.h
//  ZZZZZ
//
//  Created by YW on 2017/4/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckOutGoodListModel;
@interface CartInfoGoodsListCell : UITableViewCell
+ (CartInfoGoodsListCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) CheckOutGoodListModel *goodsModel;
@end
