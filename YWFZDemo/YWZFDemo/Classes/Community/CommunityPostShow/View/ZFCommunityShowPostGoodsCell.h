//
//  ZFCommunityShowPostGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

typedef void(^WishlistSelectBlock)(UIButton *btn);

@interface ZFCommunityShowPostGoodsCell : UITableViewCell

@property (nonatomic,copy) WishlistSelectBlock wishlistSelectBlock;

@property (nonatomic, strong) ZFGoodsModel *goodsListModel;

+ (ZFCommunityShowPostGoodsCell *)postGoodsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
