//
//  OSSVProductListCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBaseCellModelProtocol.h"
#import "RateModel.h"

@interface OSSVProductListCellModel : NSObject<OSSVBaseCellModelProtocol>

@property (nonatomic, strong) NSMutableArray    *productList;

@property (nonatomic, strong) NSObject          *dataSourceModel;
@property (nonatomic, strong) RateModel         *rateModel;

@end
