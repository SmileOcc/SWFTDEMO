//
//  OSSVSwitchCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import <UIKit/UIKit.h>
#import "OSSVSwitchCellModel.h"
#import "OSSVTableViewCellProtocol.h"

@protocol OSSVSwitchCellDelegate <TableViewCellDelegate>

-(void)STL_DidClickSwitch:(OSSVSwitchCellModel *)model;
-(void)STL_DidClickQuestionMarkButton:(OSSVSwitchCellModel *)model;

@end

@interface OSSVSwitchCell : UITableViewCell
<
OSSVTableViewCellProtocol
>

@property (nonatomic, weak) id<OSSVSwitchCellDelegate>delegate;

@end
