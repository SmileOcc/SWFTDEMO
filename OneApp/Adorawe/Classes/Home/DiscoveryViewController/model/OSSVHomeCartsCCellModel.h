//
//  OSSVHomeCartsCCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModelProtocol.h"
#import "OSSVScrollCCell.h"

@interface OSSVHomeCartsCCellModel : NSObject
<
    CollectionCellModelProtocol
>

///设置自定义尺寸大小
@property (nonatomic, assign) CGSize size;

@end
