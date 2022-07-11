//
//  OSSVCoinCellModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBaseCellModelProtocol.h"
#import "OSSVCoinModel.h"

@interface OSSVCoinCellModel : NSObject <OSSVBaseCellModelProtocol>

@property (nonatomic, strong) OSSVCoinModel  *coinModel;

@end

