//
//  OSSVCartCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartBaseGoodsCell.h"

@interface OSSVCartCell : OSSVCartBaseGoodsCell

+ (OSSVCartCell *)cartCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UIView                         *lineView;
/** 市场价格*/
@property (nonatomic, strong) UILabel                        *markePriceLabel;

- (void)updateCartModel:(CartModel *)cartModel freeGift:(BOOL)isFreeGift;

- (void)updateCartModel:(CartModel *)cartModel isFullActive:(NSInteger)isFullActive;

@end
