//
//  OSSVTableViewCellProtocol.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBaseCellModelProtocol.h"
#import "UITableViewCell+STLBottomLine.h"

#define CheckOutCellLeftPadding  12
#define CheckOutCellNormalHeight 45

@protocol TableViewCellDelegate <NSObject>

@end

@protocol OSSVTableViewCellProtocol <NSObject>

@property (nonatomic, weak) id <TableViewCellDelegate> delegate;
@property (nonatomic, strong) id <OSSVBaseCellModelProtocol> model;

@end
