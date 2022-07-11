//
//  OSSVShowErrorCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVBaseCellModelProtocol.h"

@interface OSSVShowErrorCell : UITableViewCell
<
OSSVTableViewCellProtocol
>
@end


@interface STLShowErrorCellModel : NSObject
<
OSSVBaseCellModelProtocol
>
@property (nonatomic, copy) NSString *errorMessage;

@end
