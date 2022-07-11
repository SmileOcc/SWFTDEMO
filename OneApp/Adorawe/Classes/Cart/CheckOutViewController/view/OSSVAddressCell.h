//
//  OSSVAddressCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  选择地址视图

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVCheckOutAdressCellModel.h"

@protocol OSSVAddressCellDelegate <TableViewCellDelegate>

-(void)STL_DidClickAddressCell:(OSSVCheckOutAdressCellModel *)model;

@end

@interface OSSVAddressCell : UITableViewCell
<
OSSVTableViewCellProtocol
>

@property (nonatomic, weak) id<OSSVAddressCellDelegate>delegate;

@end
