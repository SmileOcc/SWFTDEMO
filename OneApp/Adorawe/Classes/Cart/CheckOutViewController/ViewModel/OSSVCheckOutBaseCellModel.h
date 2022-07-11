//
//  OSSVCheckOutBaseCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBaseCellModelProtocol.h"

@interface OSSVCheckOutBaseCellModel : NSObject<OSSVBaseCellModelProtocol>

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
