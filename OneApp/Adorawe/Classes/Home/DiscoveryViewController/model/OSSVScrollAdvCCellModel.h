//
//  OSSVScrollAdvCCellModel.h
// XStarlinkProject
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVScrollAdvCCellModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) NSArray *backgroundConfig;

@end

NS_ASSUME_NONNULL_END
