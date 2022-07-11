//
//  OSSVCycleSysCCellModel.h
// XStarlinkProject
//
//  Created by odd on 2020/10/16.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCycleSysCCellModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;

@end

NS_ASSUME_NONNULL_END
