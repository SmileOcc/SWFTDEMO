//
//  OSSVShippingCellModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/8/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBaseCellModelProtocol.h"
#import "OSSVCartShippingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVShippingCellModel : NSObject<OSSVBaseCellModelProtocol>
@property (nonatomic, strong) OSSVCartShippingModel              *dataSourceModel;
@property (nonatomic, strong) NSMutableArray        *depenDentModelList;

@end

NS_ASSUME_NONNULL_END
