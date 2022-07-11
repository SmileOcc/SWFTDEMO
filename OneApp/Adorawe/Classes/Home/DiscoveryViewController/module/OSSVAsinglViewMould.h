//
//  OSSVAsinglViewMould.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import "CustomerLayoutSectionModuleProtocol.h"
#import "CollectionCellModelProtocol.h"
#import "OSSVHomeAdvBannerCCell.h"

@interface OSSVAsinglViewMould : NSObject
<
    CustomerLayoutSectionModuleProtocol
>

@property (nonatomic, assign) BOOL   isNewBranch;

@end
