//
//  OSSVNormalHeadCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVCheckOutBaseCellModel.h"

#pragma mark - STLNormalHeadTableViewCell

@interface OSSVNormalHeadCell : UITableViewCell
<
OSSVTableViewCellProtocol
>
@end

#pragma mark - STLNormalHeadCellModel

@interface STLNormalHeadCellModel : OSSVCheckOutBaseCellModel

+(instancetype)initWithTitile:(NSString *)title;

@property (nonatomic, copy) NSString *titleContent;

@end
