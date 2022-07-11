//
//  OSSVAsingleCCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"

@interface OSSVAsingleCCellModel : NSObject
<
    CollectionCellModelProtocol
>

///可直接设置size大小
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) UIColor *customBackgorundColor;

@end
