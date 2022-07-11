//
//  OSSVPayMentCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVPayMentCellModel.h"

typedef NS_ENUM(NSInteger) {
    PayMentCellStatusUnEable,
    PayMentCellStatusSelected,
    PayMentCellStatusUnSelect,
}PayMentCellStatus;

@protocol OSSVPayMentCellDelegate <TableViewCellDelegate>

-(void)STL_PayMentCellDidClick:(OSSVPayMentCellModel *)model;

@end

@interface OSSVPayMentCell : UITableViewCell<OSSVTableViewCellProtocol>

@property (nonatomic, strong) UIView      *cellBgView; //用于V站 选中时候的 边框
@property (nonatomic, weak) id<OSSVPayMentCellDelegate>delegate;

@end
