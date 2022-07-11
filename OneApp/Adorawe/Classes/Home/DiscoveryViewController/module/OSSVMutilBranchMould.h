//
//  OSSVMutilBranchMould.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.


#import "CustomerLayoutSectionModuleProtocol.h"

//  多分馆布局
@interface OSSVMutilBranchMould : NSObject
<
    CustomerLayoutSectionModuleProtocol
>

@property (nonatomic, assign) BOOL   isNewBranch;
@end
