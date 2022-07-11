//
//  OSSVEqlSquareMould.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  等分正方形视图布局类

#import "CustomerLayoutSectionModuleProtocol.h"

@interface OSSVEqlSquareMould : NSObject
<
    CustomerLayoutSectionModuleProtocol
>

/**
 *  自定义列
 *  默认 = 4
 */
@property (nonatomic, assign) NSInteger customerColumn;

@end
