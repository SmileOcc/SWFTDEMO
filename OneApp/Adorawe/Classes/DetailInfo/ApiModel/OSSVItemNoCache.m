//
//  OSSVItemNoCache.m
// XStarlinkProject
//
//  Created by fan wang on 2021/9/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVItemNoCache.h"

@implementation OSSVItemNoCache
+(NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"flash_sale":[OSSVNoCacheFlashSale class]};
}
@end
