//
//  OSSVWishListsTableCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "MGSwipeTableCell.h"


@class OSSVAccountMysWishsModel;
@class OSSVWishListsTableCell;

@protocol WishListCellDelegate <NSObject>
@required
-(void)accountMyWishCell:(OSSVWishListsTableCell *)cell addToCart:(OSSVAccountMysWishsModel*)wishModel;
-(void)accountMyWishCell:(OSSVWishListsTableCell *)cell deleteModel:(OSSVAccountMysWishsModel*)wishModel;

@end

@interface OSSVWishListsTableCell : MGSwipeTableCell

+(OSSVWishListsTableCell*)accountMyWishCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) OSSVAccountMysWishsModel *model;

@property (weak,nonatomic) id<WishListCellDelegate> myDelegate;

-(void)showBottomLine:(BOOL)show;

@end
