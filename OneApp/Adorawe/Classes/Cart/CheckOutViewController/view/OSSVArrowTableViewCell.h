//
//  OSSVArrowTableViewCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  选择物流方式cell

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVArrowCellModel.h"

@protocol STLArrowCellDelegate <TableViewCellDelegate>

-(void)STL_ArrowDidClick:(OSSVArrowCellModel *)model;

-(void)STL_ArrowDidClickQuestionMarkButton:(OSSVArrowCellModel *)model;
-(void)STL_coinButtonDidClickQuestionMarkButton:(OSSVArrowCellModel *)model;
-(void)STL_coinSelectPayDidClickButton:(BOOL )isUserCoin;

@end

@interface OSSVArrowTableViewCell : UITableViewCell
<
OSSVTableViewCellProtocol
>
@property (nonatomic, weak) id<STLArrowCellDelegate>delegate;

@end
