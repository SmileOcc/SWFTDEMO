//
//  OSSVTimeDownCCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"
#import "ZJJTimeCountDown.h"

@interface OSSVTimeDownCCellModel : NSObject
<
    CollectionCellModelProtocol
>

@property (nonatomic, strong, readonly) ZJJTimeCountDown *countDown;

@end
