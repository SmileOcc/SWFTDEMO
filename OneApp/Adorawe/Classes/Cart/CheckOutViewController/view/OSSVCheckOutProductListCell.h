//
//  OSSVCheckOutProductListCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  显示商品列表的cell

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVProductListCellModel.h"
#import "OSSVCheckOutProductCollectionCell.h"

@protocol OSSVCheckOutProductListCellDelegate <TableViewCellDelegate>

-(void)STL_CheckOutProductListDidClickCell:(OSSVProductListCellModel *)model;

@end

@interface OSSVCheckOutProductListCell : UITableViewCell
<
OSSVTableViewCellProtocol
>

@property (nonatomic, weak) id<OSSVCheckOutProductListCellDelegate>delegate;

@end
